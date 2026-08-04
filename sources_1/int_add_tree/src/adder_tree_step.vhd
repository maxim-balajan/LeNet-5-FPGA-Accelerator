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

ENTITY adder_tree_step IS
	GENERIC (
		G_BIT_WIDTH           : NATURAL  := 8;
		G_OUT_BIT_WIDTH       : NATURAL  := 8;
		G_INIT_PIPELINE_STEPS : POSITIVE := 2;
		G_INPUT_AMOUNT        : NATURAL;
		G_CONTROL_AMOUNT      : NATURAL;
		--! 1 => the adders saturate via clip_adder instead of wrapping around
		G_CLIP_ADDER : NATURAL RANGE 0 TO 1 := 0
	);
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		-- Global enable: If set to 0, stall entire unit and hold outputs
		i_en : IN STD_LOGIC := '1';
		--
		i_vector          : IN STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
		i_control_signals : IN STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);
		o_vector          : OUT STD_LOGIC_VECTOR(INTEGER(ceil(REAL(G_INPUT_AMOUNT) / 2.0)) * G_OUT_BIT_WIDTH - 1 DOWNTO 0);
		o_control_signals : OUT STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0)
	);
END ENTITY adder_tree_step;

ARCHITECTURE rtl OF adder_tree_step IS

	--------------------------------------
	-- TYPEs
	--------------------------------------

	-- increase s_input_matrix size by 1 in order to deal with uneven vector lengths correctly and to make HW more maintainable

	TYPE t_in_std_logic_array IS ARRAY(G_INPUT_AMOUNT DOWNTO 0) OF STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

	TYPE t_in_std_logic_matrix IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF t_in_std_logic_array;

	TYPE t_out_std_logic_array IS ARRAY(INTEGER(ceil(REAL(G_INPUT_AMOUNT) / 2.0)) - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_OUT_BIT_WIDTH - 1 DOWNTO 0);

	TYPE t_control_signals_array IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

	SIGNAL s_in_vector : t_in_std_logic_matrix;

	SIGNAL s_out_vector : t_out_std_logic_array;

	SIGNAL s_control_signals : t_control_signals_array;

BEGIN

	DELAY_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_in_vector(s_in_vector'LOW)             <= (OTHERS => (OTHERS => '0'));
				s_control_signals(s_control_signals'LOW) <= (OTHERS => '0');
			ELSIF i_en = '1' THEN
				-- For loop to map all input vector to first
				FOR i IN 0 TO G_INPUT_AMOUNT - 1 LOOP

					s_in_vector(s_in_vector'LOW)(i) <= i_vector((i + 1) * G_BIT_WIDTH - 1 DOWNTO i * G_BIT_WIDTH);

				END LOOP;

				s_control_signals(s_control_signals'LOW) <= i_control_signals;
			END IF;
		END IF;

	END PROCESS DELAY_PROC;

	PIPELINE_GEN : IF G_INIT_PIPELINE_STEPS > 1 GENERATE

		PIPELINE_PROC : PROCESS (clk) IS
		BEGIN

			IF rising_edge(clk) THEN
				IF rst = '1' THEN
					s_in_vector(s_in_vector'HIGH DOWNTO s_in_vector'LOW + 1)                   <= (OTHERS => (OTHERS => (OTHERS => '0')));
					s_control_signals(s_control_signals'HIGH DOWNTO s_control_signals'LOW + 1) <= (OTHERS => (OTHERS => '0'));
				ELSIF i_en = '1' THEN
					s_in_vector(s_in_vector'HIGH DOWNTO s_in_vector'LOW + 1)                   <= s_in_vector(s_in_vector'HIGH - 1 DOWNTO s_in_vector'LOW);
					s_control_signals(s_control_signals'HIGH DOWNTO s_control_signals'LOW + 1) <= s_control_signals(s_control_signals'HIGH - 1 DOWNTO s_control_signals'LOW);
				END IF;
			END IF;

		END PROCESS PIPELINE_PROC;

	END GENERATE PIPELINE_GEN;

	-- This generates an extra adder/multiplier for all steps with uneven input sizes.
	-- These will result in multipliers/adders that are calculated with a constant 0, meaning the synthesis tool
	-- should optimize the resulting netlist to remove this extra HW!

	MAP_GEN : FOR i IN s_out_vector'RANGE GENERATE

		CLIP_GEN : IF G_CLIP_ADDER = 1 GENERATE

			CLIP_ADDER_INST : ENTITY work.clip_adder
				GENERIC MAP (
					G_BIT_WIDTH => G_BIT_WIDTH
				)
				PORT MAP (
					i_din0 => s_in_vector(s_in_vector'HIGH)(2 * i),
					i_din1 => s_in_vector(s_in_vector'HIGH)(2 * i + 1),
					o_dout => s_out_vector(i)
				);

		END GENERATE CLIP_GEN;

		NO_CLIP_GEN : IF G_CLIP_ADDER = 0 GENERATE
			s_out_vector(i) <= STD_LOGIC_VECTOR(SIGNED(s_in_vector(s_in_vector'HIGH)(2 * i)) + SIGNED(s_in_vector(s_in_vector'HIGH)(2 * i + 1)));
		END GENERATE NO_CLIP_GEN;

	END GENERATE MAP_GEN;

	-------------------
	-- Set OUTPUTs
	-------------------

	OUTPUT_GEN : FOR i IN s_out_vector'RANGE GENERATE

		SUBTYPE st_vec_range IS NATURAL RANGE (i + 1) * G_BIT_WIDTH - 1 DOWNTO i * G_BIT_WIDTH;

	BEGIN

		o_vector(st_vec_range) <= s_out_vector(i)(G_OUT_BIT_WIDTH - 1 DOWNTO 0);

	END GENERATE OUTPUT_GEN;

	o_control_signals <= s_control_signals(s_control_signals'HIGH);

END ARCHITECTURE rtl;
