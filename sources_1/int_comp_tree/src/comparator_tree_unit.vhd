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

ENTITY comparator_tree_unit IS
	GENERIC (
		G_BIT_WIDTH           : NATURAL  := 8;
		G_INIT_PIPELINE_STEPS : POSITIVE := 2;
		G_INPUT_AMOUNT        : NATURAL  := 25;
		G_CONTROL_AMOUNT      : NATURAL  := 1;
		--! 1 => compare the values as signed, 0 => compare them as unsigned
		G_SIGNED : INTEGER RANGE 0 TO 1 := 0;
		--! 1 => o_index reports the position of the maximum inside i_vec0 (argmax)
		G_ENABLE_INDEX : INTEGER RANGE 0 TO 1 := 0
	);
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		-- Global enable: If set to 0, stall entire unit and hold outputs
		i_en : IN STD_LOGIC := '1';
		--
		i_vec0 : IN STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
		--
		i_control_signals : IN STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);
		--
		o_vec : OUT STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		--! index of the maximum value; only driven when G_ENABLE_INDEX = 1
		o_index           : OUT STD_LOGIC_VECTOR(integer(ceil(log2(real(G_INPUT_AMOUNT)))) - 1 DOWNTO 0);
		o_control_signals : OUT STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0)
	);
END ENTITY comparator_tree_unit;

ARCHITECTURE rtl OF comparator_tree_unit IS

	--------------------------------------
	-- CONSTANTs
	--------------------------------------

	-- This constant stores the amount of pipeline steps that are needed
	CONSTANT C_PIPELINE_STEP_AMOUNT : INTEGER := integer(ceil(log2(real(G_INPUT_AMOUNT))));
	-- Amount of bits needed to address every input value
	CONSTANT C_INDEX_WIDTH : POSITIVE := integer(ceil(log2(real(G_INPUT_AMOUNT))));

	--------------------------------------
	-- FUNCTIONs
	--------------------------------------

	--! Builds the constant vector (0, 1, 2, ... G_INPUT_AMOUNT - 1) that seeds the index tree.
	--! It is time invariant, so it does not need to run through the input delay line.

	FUNCTION f_init_indices RETURN STD_LOGIC_VECTOR IS

		VARIABLE v_indices : STD_LOGIC_VECTOR(G_INPUT_AMOUNT * C_INDEX_WIDTH - 1 DOWNTO 0);

	BEGIN

		FOR i IN 0 TO G_INPUT_AMOUNT - 1 LOOP

			v_indices((i + 1) * C_INDEX_WIDTH - 1 downto i * C_INDEX_WIDTH) := std_logic_vector(to_unsigned(i, C_INDEX_WIDTH));

		END LOOP;

		RETURN v_indices;

	END FUNCTION f_init_indices;

	--------------------------------------
	-- TYPEs
	--------------------------------------

	TYPE t_std_logic_array IS ARRAY(0 TO C_PIPELINE_STEP_AMOUNT) OF STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);

	TYPE t_index_array IS ARRAY(0 TO C_PIPELINE_STEP_AMOUNT) OF STD_LOGIC_VECTOR(G_INPUT_AMOUNT * C_INDEX_WIDTH - 1 DOWNTO 0);

	-- These are just the pipelined control signals

	TYPE t_control_signals_array IS ARRAY(0 TO C_PIPELINE_STEP_AMOUNT)        OF STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

	TYPE t_vec_pipeline IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);

	TYPE t_in_con_sig_pipeline IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

	--------------------------------------
	-- CONSTANTs (depending on the functions above)
	--------------------------------------

	CONSTANT C_INIT_INDICES : STD_LOGIC_VECTOR(G_INPUT_AMOUNT * C_INDEX_WIDTH - 1 DOWNTO 0) := f_init_indices;

	--------------------------------------
	-- SIGNALs
	--------------------------------------

	-- This signal is for all pipelined values that are used for the convolution computation
	-- it also contains double the amount of signals because it is easier to write that way and shouldn't result in more HW
	SIGNAL s_pipeline_values : t_std_logic_array;
	-- Index tree that runs in lockstep with s_pipeline_values
	SIGNAL s_pipeline_indices : t_index_array;
	-- This signal contains all multiplications or all start values of vec0
	SIGNAL s_pipeline_start : STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);

	SIGNAL s_control_signals_line : t_control_signals_array;

	-- Initial pipelining of input signals
	SIGNAL s_vec0_line           : t_vec_pipeline;
	SIGNAL s_con_sig_line        : t_in_con_sig_pipeline;
	SIGNAL s_res_control_signals : STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

BEGIN

	-- Delay of input signals to achieve registering of initial inputs

	INPUT_DELAY_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_vec0_line(s_vec0_line'low)       <= (OTHERS => '0');
				s_con_sig_line(s_con_sig_line'low) <= (OTHERS => '0');
			ELSIF i_en = '1' THEN
				s_vec0_line(s_vec0_line'low)       <= i_vec0;
				s_con_sig_line(s_con_sig_line'low) <= i_control_signals;
			END IF;
		END IF;

	END PROCESS INPUT_DELAY_PROC;

	PIPELINE_GEN : IF G_INIT_PIPELINE_STEPS > 1 GENERATE

		PIPELINE_PROC : PROCESS (clk) IS
		BEGIN

			IF rising_edge(clk) THEN
				IF rst = '1' THEN
					s_vec0_line(s_vec0_line'high downto s_vec0_line'low + 1)          <= (OTHERS => (OTHERS => '0'));
					s_con_sig_line(s_con_sig_line'high downto s_con_sig_line'low + 1) <= (OTHERS => (OTHERS => '0'));
				ELSIF i_en = '1' THEN
					s_vec0_line(s_vec0_line'high downto s_vec0_line'low + 1)          <= s_vec0_line(s_vec0_line'HIGH - 1 DOWNTO s_vec0_line'LOW);
					s_con_sig_line(s_con_sig_line'high downto s_con_sig_line'low + 1) <= s_con_sig_line(s_con_sig_line'HIGH - 1 DOWNTO s_con_sig_line'LOW);
				END IF;
			END IF;

		END PROCESS PIPELINE_PROC;

	END GENERATE PIPELINE_GEN;

	PIPELINE_START_GEN : FOR i IN 0 TO G_INPUT_AMOUNT - 1 GENERATE
		s_pipeline_start((i + 1) * G_BIT_WIDTH - 1 downto i * G_BIT_WIDTH) <= s_vec0_line(s_vec0_line'HIGH)((i + 1) * G_BIT_WIDTH - 1 DOWNTO i * G_BIT_WIDTH);
	END GENERATE PIPELINE_START_GEN;

	-- Set inputs of pipeline
	s_pipeline_values(s_pipeline_values'low)           <= s_pipeline_start;
	s_pipeline_indices(s_pipeline_indices'low)         <= C_INIT_INDICES;
	s_control_signals_line(s_control_signals_line'low) <= s_con_sig_line(s_con_sig_line'HIGH);

	-- Generate all convolutions/pooling steps that are necessary for the addition/comparison of all input values
	-- Basically works like the "Divide by 2"-Algorithm

	PIPELINE_STEP_GEN : FOR i IN 0 TO C_PIPELINE_STEP_AMOUNT - 1 GENERATE

		CONSTANT C_NEXT_LAYER_INPUT_AMOUNT : INTEGER := integer(ceil(real(G_INPUT_AMOUNT) / real(2 ** (i + 1))));

		CONSTANT C_LAYER_INPUT_AMOUNT : INTEGER := integer(ceil(real(G_INPUT_AMOUNT) / real(2 ** i)));

	BEGIN

		-- set all other pipeline steps values not set by the comparators trees to
		-- zero for comparison to let the tool optimize this
		s_pipeline_values(i + 1)(s_pipeline_values(i + 1)'high downto C_NEXT_LAYER_INPUT_AMOUNT * G_BIT_WIDTH)     <= (OTHERS => '0');
		s_pipeline_indices(i + 1)(s_pipeline_indices(i + 1)'high downto C_NEXT_LAYER_INPUT_AMOUNT * C_INDEX_WIDTH) <= (OTHERS => '0');

		comparator_tree_step_inst : ENTITY work.comparator_tree_step
			GENERIC MAP (
				G_BIT_WIDTH           => G_BIT_WIDTH,
				G_INIT_PIPELINE_STEPS => G_INIT_PIPELINE_STEPS,
				G_INPUT_AMOUNT        => C_LAYER_INPUT_AMOUNT,
				G_CONTROL_AMOUNT      => G_CONTROL_AMOUNT,
				G_SIGNED              => G_SIGNED,
				G_ENABLE_INDEX        => G_ENABLE_INDEX,
				G_INDEX_WIDTH         => C_INDEX_WIDTH
			)
			PORT MAP (
				clk => clk,
				rst => rst,
				--
				i_en => i_en,
				--
				i_vector          => s_pipeline_values(i)(C_LAYER_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0),
				i_index_vector    => s_pipeline_indices(i)(C_LAYER_INPUT_AMOUNT * C_INDEX_WIDTH - 1 DOWNTO 0),
				i_control_signals => s_control_signals_line(i),
				o_vector          => s_pipeline_values(i + 1)(C_NEXT_LAYER_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0),
				o_index_vector    => s_pipeline_indices(i + 1)(C_NEXT_LAYER_INPUT_AMOUNT * C_INDEX_WIDTH - 1 DOWNTO 0),
				o_control_signals => s_control_signals_line(i + 1)
			);

	END GENERATE PIPELINE_STEP_GEN;

	-------------------
	-- Set OUTPUTs
	-------------------
	o_vec   <= s_pipeline_values(s_pipeline_values'HIGH)(G_BIT_WIDTH - 1 DOWNTO 0);
	o_index <= s_pipeline_indices(s_pipeline_indices'HIGH)(C_INDEX_WIDTH - 1 DOWNTO 0);
	-- Extra step over signal to achieve same delta cycle for o_vec and o_control_signals
	s_res_control_signals <= s_control_signals_line(s_control_signals_line'HIGH);
	o_control_signals     <= s_res_control_signals;

END ARCHITECTURE rtl;
