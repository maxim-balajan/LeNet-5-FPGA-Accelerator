------------------------------------------------------------------------------
-- SPDX-License-Identifier: GPL-3.0-only
--
-- A hardware accelerated exp2 calculation aimed for FPGAs.
--
-- Copyright (C) 2026 Maxim Balajan (maxim.balajan@fau.de)
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY comparator_tree_step IS
	GENERIC (
		G_BIT_WIDTH           : NATURAL  := 8;
		G_INIT_PIPELINE_STEPS : POSITIVE := 2;
		G_INPUT_AMOUNT        : NATURAL;
		G_CONTROL_AMOUNT      : NATURAL;
		--! 1 => compare the values as signed, 0 => compare them as unsigned
		G_SIGNED : INTEGER RANGE 0 TO 1 := 0;
		--! 1 => track an index alongside every value, so that an argmax can be built
		G_ENABLE_INDEX : INTEGER RANGE 0 TO 1 := 0;
		--! bit width of one tracked index; only relevant for G_ENABLE_INDEX = 1
		G_INDEX_WIDTH : POSITIVE := 1
	);
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		-- Global enable: If set to 0, stall entire unit and hold outputs
		i_en : IN STD_LOGIC := '1';
		--
		i_vector          : IN STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
		i_index_vector    : IN STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_INDEX_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
		i_control_signals : IN STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);
		o_vector          : OUT STD_LOGIC_VECTOR(integer(ceil(real(G_INPUT_AMOUNT) / 2.0)) * G_BIT_WIDTH - 1 DOWNTO 0);
		o_index_vector    : OUT STD_LOGIC_VECTOR(integer(ceil(real(G_INPUT_AMOUNT) / 2.0)) * G_INDEX_WIDTH - 1 DOWNTO 0);
		o_control_signals : OUT STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0)
	);
END ENTITY comparator_tree_step;

ARCHITECTURE rtl OF comparator_tree_step IS

	--------------------------------------
	-- CONSTANTs
	--------------------------------------

	CONSTANT C_OUTPUT_AMOUNT : NATURAL := integer(ceil(real(G_INPUT_AMOUNT) / 2.0));

	--------------------------------------
	-- FUNCTIONs
	--------------------------------------

	--! Neutral element of the comparison. The padding slot that exists for uneven input
	--! amounts keeps this value forever, so it can never win a comparison.
	--! For unsigned comparisons that is 0, for signed comparisons the most negative value.

	FUNCTION f_neutral_value RETURN STD_LOGIC_VECTOR IS

		VARIABLE v_value : STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

	BEGIN

		IF G_SIGNED = 1 THEN
			v_value(v_value'high) := '1';
		END IF;

		RETURN v_value;

	END FUNCTION f_neutral_value;

	--------------------------------------
	-- TYPEs
	--------------------------------------

	-- increase s_input_matrix size by 1 in order to deal with uneven vector lengths correctly and to make HW more maintainable

	TYPE t_in_std_logic_array IS ARRAY(G_INPUT_AMOUNT DOWNTO 0) OF STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

	TYPE t_in_std_logic_matrix IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF t_in_std_logic_array;

	TYPE t_out_std_logic_array IS ARRAY(C_OUTPUT_AMOUNT - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

	TYPE t_in_index_array IS ARRAY(G_INPUT_AMOUNT DOWNTO 0) OF STD_LOGIC_VECTOR(G_INDEX_WIDTH - 1 DOWNTO 0);

	TYPE t_in_index_matrix IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF t_in_index_array;

	TYPE t_out_index_array IS ARRAY(C_OUTPUT_AMOUNT - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_INDEX_WIDTH - 1 DOWNTO 0);

	TYPE t_control_signals_array IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

	--------------------------------------
	-- SIGNALs
	--------------------------------------

	SIGNAL s_in_vector : t_in_std_logic_matrix;

	SIGNAL s_out_vector : t_out_std_logic_array;

	SIGNAL s_in_index : t_in_index_matrix;

	SIGNAL s_out_index : t_out_index_array;

	-- '1' when the left (lower indexed) operand of a comparison wins
	SIGNAL s_select : STD_LOGIC_VECTOR(C_OUTPUT_AMOUNT - 1 DOWNTO 0);

	SIGNAL s_control_signals : t_control_signals_array;

BEGIN

	DELAY_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_in_vector(s_in_vector'low)             <= (OTHERS => f_neutral_value);
				s_control_signals(s_control_signals'low) <= (OTHERS => '0');
			ELSIF i_en = '1' THEN
				-- For loop to map all input vector to first
				FOR i IN 0 TO G_INPUT_AMOUNT - 1 LOOP

					s_in_vector(s_in_vector'low)(i) <= i_vector((i + 1) * G_BIT_WIDTH - 1 DOWNTO i * G_BIT_WIDTH);

				END LOOP;

				s_control_signals(s_control_signals'low) <= i_control_signals;
			END IF;
		END IF;

	END PROCESS DELAY_PROC;

	PIPELINE_GEN : IF G_INIT_PIPELINE_STEPS > 1 GENERATE

		PIPELINE_PROC : PROCESS (clk) IS
		BEGIN

			IF rising_edge(clk) THEN
				IF rst = '1' THEN
					s_in_vector(s_in_vector'high downto s_in_vector'low + 1)                   <= (OTHERS => (OTHERS => f_neutral_value));
					s_control_signals(s_control_signals'high downto s_control_signals'low + 1) <= (OTHERS => (OTHERS => '0'));
				ELSIF i_en = '1' THEN
					s_in_vector(s_in_vector'high downto s_in_vector'low + 1)                   <= s_in_vector(s_in_vector'HIGH - 1 DOWNTO s_in_vector'LOW);
					s_control_signals(s_control_signals'high downto s_control_signals'low + 1) <= s_control_signals(s_control_signals'HIGH - 1 DOWNTO s_control_signals'LOW);
				END IF;
			END IF;

		END PROCESS PIPELINE_PROC;

	END GENERATE PIPELINE_GEN;

	-- The index line is only built when it is actually requested, so the pooling
	-- instantiations do not pay for the additional registers.

	INDEX_GEN : IF G_ENABLE_INDEX = 1 GENERATE

		INDEX_DELAY_PROC : PROCESS (clk) IS
		BEGIN

			IF rising_edge(clk) THEN
				IF rst = '1' THEN
					s_in_index(s_in_index'low) <= (OTHERS => (OTHERS => '0'));
				ELSIF i_en = '1' THEN

					FOR i IN 0 TO G_INPUT_AMOUNT - 1 LOOP

						s_in_index(s_in_index'low)(i) <= i_index_vector((i + 1) * G_INDEX_WIDTH - 1 DOWNTO i * G_INDEX_WIDTH);

					END LOOP;

				END IF;
			END IF;

		END PROCESS INDEX_DELAY_PROC;

		INDEX_PIPELINE_GEN : IF G_INIT_PIPELINE_STEPS > 1 GENERATE

			INDEX_PIPELINE_PROC : PROCESS (clk) IS
			BEGIN

				IF rising_edge(clk) THEN
					IF rst = '1' THEN
						s_in_index(s_in_index'high downto s_in_index'low + 1) <= (OTHERS => (OTHERS => (OTHERS => '0')));
					ELSIF i_en = '1' THEN
						s_in_index(s_in_index'high downto s_in_index'low + 1) <= s_in_index(s_in_index'HIGH - 1 DOWNTO s_in_index'LOW);
					END IF;
				END IF;

			END PROCESS INDEX_PIPELINE_PROC;

		END GENERATE INDEX_PIPELINE_GEN;

	END GENERATE INDEX_GEN;

	NO_INDEX_GEN : IF G_ENABLE_INDEX = 0 GENERATE
		s_in_index <= (OTHERS => (OTHERS => (OTHERS => '0')));
	END GENERATE NO_INDEX_GEN;

	-- This generates an extra comparator for all steps with uneven input sizes.
	-- These will result in comparators that that needs to be computed with a static -MAX_INT, so that the synthesis tool
	-- can optimize the resulting netlist to remove this extra HW!

	SIGNED_SELECT_GEN : IF G_SIGNED = 1 GENERATE

		SELECT_GEN : FOR i IN s_select'RANGE GENERATE
			s_select(i) <= '1' WHEN signed(s_in_vector(s_in_vector'HIGH)(2 * i)) >= signed(s_in_vector(s_in_vector'HIGH)(2 * i + 1)) ELSE '0';
		END GENERATE SELECT_GEN;

	END GENERATE SIGNED_SELECT_GEN;

	UNSIGNED_SELECT_GEN : IF G_SIGNED = 0 GENERATE

		SELECT_GEN : FOR i IN s_select'RANGE GENERATE
			s_select(i) <= '1' WHEN unsigned(s_in_vector(s_in_vector'HIGH)(2 * i)) >= unsigned(s_in_vector(s_in_vector'HIGH)(2 * i + 1)) ELSE '0';
		END GENERATE SELECT_GEN;

	END GENERATE UNSIGNED_SELECT_GEN;

	-- Ties are won by the left operand, which carries the lower index. This is exactly
	-- what the argmax definition of the accelerator requires.

	MAP_GEN : FOR i IN s_out_vector'RANGE GENERATE

		s_out_vector(i) <= s_in_vector(s_in_vector'HIGH)(2 * i) WHEN s_select(i) = '1' ELSE
	                   s_in_vector(s_in_vector'HIGH)(2 * i + 1);

		s_out_index(i) <= s_in_index(s_in_index'HIGH)(2 * i) WHEN s_select(i) = '1' ELSE
	                  s_in_index(s_in_index'HIGH)(2 * i + 1);

	END GENERATE MAP_GEN;

	-------------------
	-- Set OUTPUTs
	-------------------

	OUTPUT_GEN : FOR i IN s_out_vector'RANGE GENERATE
		o_vector((i + 1) * G_BIT_WIDTH - 1 downto i * G_BIT_WIDTH)           <= s_out_vector(i);
		o_index_vector((i + 1) * G_INDEX_WIDTH - 1 downto i * G_INDEX_WIDTH) <= s_out_index(i);
	END GENERATE OUTPUT_GEN;

	o_control_signals <= s_control_signals(s_control_signals'HIGH);

END ARCHITECTURE rtl;
