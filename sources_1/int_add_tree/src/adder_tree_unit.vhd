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

ENTITY adder_tree_unit IS
	GENERIC (
		G_BIT_WIDTH           : NATURAL  := 8;
		G_BIT_WIDTH_EXTENDED  : NATURAL  := 0;
		G_OUT_BIT_WIDTH       : INTEGER  := 8;
		G_INIT_PIPELINE_STEPS : POSITIVE := 2;
		G_INPUT_AMOUNT        : NATURAL  := 25;
		G_CONTROL_AMOUNT      : NATURAL  := 1;
		-- enables the multiplication line in the beginning
		G_ENABLE_MUL_LINE : INTEGER RANGE 0 TO 1 := 1;
		--! 1 => every adder saturates via clip_adder instead of wrapping around, and the
		--! result is clipped instead of truncated when narrowing to G_OUT_BIT_WIDTH
		G_CLIP_ADDER : NATURAL RANGE 0 TO 1 := 0;
		--! 1 => an arithmetic shift right by i_shamt is applied behind the tree
		G_ENABLE_SHIFT : NATURAL RANGE 0 TO 1 := 0;
		--! 1 => a single ReLU stage is appended behind the whole tree
		G_ENABLE_RELU : NATURAL RANGE 0 TO 1 := 0
	);
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		-- Global enable: If set to 0, stall entire unit and hold outputs
		i_en : IN STD_LOGIC := '1';
		--
		i_vec0 : IN STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
		i_vec1 : IN STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
		--! amount of bits the sum is shifted right by; only used for G_ENABLE_SHIFT = 1
		i_shamt : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
		--
		i_control_signals : IN STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);
		--
		o_vec             : OUT STD_LOGIC_VECTOR(G_OUT_BIT_WIDTH - 1 DOWNTO 0);
		o_control_signals : OUT STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0)
	);
END ENTITY adder_tree_unit;

ARCHITECTURE rtl OF adder_tree_unit IS

	--------------------------------------
	-- FUNCTIONs
	--------------------------------------

	IMPURE FUNCTION f_get_layer_bit_width RETURN INTEGER IS

		VARIABLE v_current_bit_width : INTEGER := G_BIT_WIDTH;

	BEGIN

		-- If layer starts with multiplier, then tripple bit width to accommodate adders
		IF G_ENABLE_MUL_LINE = 1 THEN
			v_current_bit_width := 2 * v_current_bit_width;
		END IF;

		RETURN v_current_bit_width + G_BIT_WIDTH_EXTENDED;

	END FUNCTION f_get_layer_bit_width;

	FUNCTION f_clip (
		value : SIGNED
	) RETURN STD_LOGIC_VECTOR IS

		VARIABLE v_max : SIGNED(value'LENGTH - 1 DOWNTO 0) := (OTHERS => '0');
		VARIABLE v_min : SIGNED(value'LENGTH - 1 DOWNTO 0) := (OTHERS => '0');

	BEGIN

		IF G_CLIP_ADDER = 0 OR G_OUT_BIT_WIDTH >= value'LENGTH OR G_OUT_BIT_WIDTH < 2 THEN
			RETURN std_logic_vector(resize(value, G_OUT_BIT_WIDTH));
		END IF;

		-- Set v_max to INT_MAX and v_min to INT_MIN
		v_max(v_max'HIGH - 1 downto 0) := (OTHERS => '1');
		v_min(v_max'HIGH)              := '1';

		IF value > v_max THEN
			RETURN std_logic_vector(resize(v_max, G_OUT_BIT_WIDTH));
		ELSIF value < v_min THEN
			RETURN std_logic_vector(resize(v_min, G_OUT_BIT_WIDTH));
		END IF;

		RETURN std_logic_vector(resize(value, G_OUT_BIT_WIDTH));

	END FUNCTION f_clip;

	--------------------------------------
	-- CONSTANTs
	--------------------------------------

	-- This constant stores the amount of pipeline steps that are needed
	CONSTANT C_PIPELINE_STEP_AMOUNT : INTEGER := integer(ceil(log2(real(G_INPUT_AMOUNT))));
	CONSTANT C_LAYER_BIT_WIDTH      : NATURAL := f_get_layer_bit_width;

	--------------------------------------
	-- TYPEs
	--------------------------------------

	TYPE t_std_logic_array IS ARRAY(0 TO C_PIPELINE_STEP_AMOUNT) OF STD_LOGIC_VECTOR(G_INPUT_AMOUNT * C_LAYER_BIT_WIDTH - 1 DOWNTO 0);

	-- These are just the pipelined control signals

	TYPE t_control_signals_array IS ARRAY(0 TO C_PIPELINE_STEP_AMOUNT) OF STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

	TYPE t_vec_pipeline IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);

	TYPE t_in_con_sig_pipeline IS ARRAY(G_INIT_PIPELINE_STEPS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

	--------------------------------------
	-- SIGNALs
	--------------------------------------

	-- This signal is for all pipelined values that are used for the convolution computation
	-- it also contains double the amount of signals because it is easier to write that way and shouldn't result in more HW
	SIGNAL s_pipeline_values : t_std_logic_array;
	ALIAS  s_pipeline_end    IS s_pipeline_values(s_pipeline_values'HIGH)(C_LAYER_BIT_WIDTH - 1 DOWNTO 0);
	-- This signal contains all multiplications or all start values of vec0
	SIGNAL s_pipeline_start : STD_LOGIC_VECTOR(G_INPUT_AMOUNT * C_LAYER_BIT_WIDTH - 1 DOWNTO 0);

	SIGNAL s_control_signals_line : t_control_signals_array;

	-- Initial pipelining of input signals
	SIGNAL s_vec0_line           : t_vec_pipeline;
	SIGNAL s_vec1_line           : t_vec_pipeline;
	SIGNAL s_con_sig_line        : t_in_con_sig_pipeline;
	SIGNAL s_res_control_signals : STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

	-- Optional shift and ReLU stages behind the tree
	SIGNAL s_shift_value   : STD_LOGIC_VECTOR(C_LAYER_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_shift_control : STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);
	SIGNAL s_shifted       : SIGNED(C_LAYER_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_shifted_ctrl  : STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);
	SIGNAL s_clipped       : STD_LOGIC_VECTOR(G_OUT_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_relu_value    : STD_LOGIC_VECTOR(G_OUT_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_relu_control  : STD_LOGIC_VECTOR(G_CONTROL_AMOUNT - 1 DOWNTO 0);

BEGIN

	-- Delay of input signals to achieve registering of initial inputs

	INPUT_DELAY_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_vec0_line(s_vec0_line'low)       <= (OTHERS => '0');
				s_vec1_line(s_vec1_line'low)       <= (OTHERS => '0');
				s_con_sig_line(s_con_sig_line'low) <= (OTHERS => '0');
			ELSIF i_en = '1' THEN
				s_vec0_line(s_vec0_line'low)       <= i_vec0;
				s_vec1_line(s_vec1_line'low)       <= i_vec1;
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
					s_vec1_line(s_vec1_line'high downto s_vec1_line'low + 1)          <= (OTHERS => (OTHERS => '0'));
					s_con_sig_line(s_con_sig_line'high downto s_con_sig_line'low + 1) <= (OTHERS => (OTHERS => '0'));
				ELSIF i_en = '1' THEN
					s_vec0_line(s_vec0_line'high downto s_vec0_line'low + 1)          <= s_vec0_line(s_vec0_line'HIGH - 1 DOWNTO s_vec0_line'LOW);
					s_vec1_line(s_vec1_line'high downto s_vec1_line'low + 1)          <= s_vec1_line(s_vec1_line'HIGH - 1 DOWNTO s_vec1_line'LOW);
					s_con_sig_line(s_con_sig_line'high downto s_con_sig_line'low + 1) <= s_con_sig_line(s_con_sig_line'HIGH - 1 DOWNTO s_con_sig_line'LOW);
				END IF;
			END IF;

		END PROCESS PIPELINE_PROC;

	END GENERATE PIPELINE_GEN;

	PIPELINE_START_GEN : FOR i IN 0 TO G_INPUT_AMOUNT - 1 GENERATE

		SUBTYPE st_vec_range IS NATURAL RANGE (i + 1) * G_BIT_WIDTH - 1       DOWNTO i * G_BIT_WIDTH;

		SUBTYPE st_map_range IS NATURAL RANGE (i + 1) * C_LAYER_BIT_WIDTH - 1 DOWNTO i * C_LAYER_BIT_WIDTH;

	BEGIN

		MULT_GEN : IF G_ENABLE_MUL_LINE = 1 GENERATE
			s_pipeline_start(st_map_range) <= std_logic_vector(resize(signed(s_vec0_line(s_vec0_line'HIGH)(st_vec_range)) * signed(s_vec1_line(s_vec1_line'HIGH)(st_vec_range)), C_LAYER_BIT_WIDTH));
		END GENERATE MULT_GEN;

		NO_MULT_GEN : IF G_ENABLE_MUL_LINE = 0 GENERATE
			s_pipeline_start(st_map_range) <= std_logic_vector(resize(signed(s_vec0_line(s_vec0_line'HIGH)(st_vec_range)), C_LAYER_BIT_WIDTH));
		END GENERATE NO_MULT_GEN;

	END GENERATE PIPELINE_START_GEN;

	-- Set inputs of pipeline
	s_pipeline_values(s_pipeline_values'low)           <= s_pipeline_start;
	s_control_signals_line(s_control_signals_line'low) <= s_con_sig_line(s_con_sig_line'HIGH);

	-- Generate all convolutions/pooling steps that are necessary for the addition/comparison of all input values
	-- Basically works like the "Divide by 2"-Algorithm

	PIPELINE_STEP_GEN : FOR i IN 0 TO C_PIPELINE_STEP_AMOUNT - 1 GENERATE
		CONSTANT C_LAYER_INPUT_AMOUNT : INTEGER := integer(ceil(real(G_INPUT_AMOUNT) / real(2 ** i)));
		CONSTANT C_LAYER_BIT_WIDTH    : INTEGER := f_get_layer_bit_width;

		CONSTANT C_NEXT_LAYER_INPUT_AMOUNT : INTEGER := integer(ceil(real(G_INPUT_AMOUNT) / real(2 ** (i + 1))));

	BEGIN

		-- set all other pipeline steps values not set by the adder trees to 0 for additions or to 1 for multiplications to let the tool optimize this
		s_pipeline_values(i + 1)(s_pipeline_values(i + 1)'high downto C_NEXT_LAYER_INPUT_AMOUNT * C_LAYER_BIT_WIDTH) <= (OTHERS => '0');

		adder_tree_step_inst : ENTITY work.adder_tree_step
			GENERIC MAP (
				G_BIT_WIDTH           => C_LAYER_BIT_WIDTH,
				G_OUT_BIT_WIDTH       => C_LAYER_BIT_WIDTH,
				G_INIT_PIPELINE_STEPS => G_INIT_PIPELINE_STEPS,
				G_INPUT_AMOUNT        => C_LAYER_INPUT_AMOUNT,
				G_CONTROL_AMOUNT      => G_CONTROL_AMOUNT,
				G_CLIP_ADDER          => G_CLIP_ADDER
			)
			PORT MAP (
				clk => clk,
				rst => rst,
				--
				i_en => i_en,
				--
				i_vector          => s_pipeline_values(i)(C_LAYER_INPUT_AMOUNT * C_LAYER_BIT_WIDTH - 1 DOWNTO 0),
				i_control_signals => s_control_signals_line(i),
				o_vector          => s_pipeline_values(i + 1)(C_NEXT_LAYER_INPUT_AMOUNT * C_LAYER_BIT_WIDTH - 1 DOWNTO 0),
				o_control_signals => s_control_signals_line(i + 1)
			);

	END GENERATE PIPELINE_STEP_GEN;

	-------------------
	-- Optional shift stage behind the tree
	-------------------

	SHIFT_GEN : IF G_ENABLE_SHIFT = 1 GENERATE

		SHIFT_DELAY_PROC : PROCESS (clk) IS
		BEGIN

			IF rising_edge(clk) THEN
				IF rst = '1' THEN
					s_shift_value   <= (OTHERS => '0');
					s_shift_control <= (OTHERS => '0');
				ELSIF i_en = '1' THEN
					s_shift_value   <= s_pipeline_end;
					s_shift_control <= s_control_signals_line(s_control_signals_line'HIGH);
				END IF;
			END IF;

		END PROCESS SHIFT_DELAY_PROC;

		-- The values only ever get smaller, so an arithmetic shift right is enough
		s_shifted      <= shift_right(signed(s_shift_value), to_integer(unsigned(i_shamt)));
		s_shifted_ctrl <= s_shift_control;

	END GENERATE SHIFT_GEN;

	NO_SHIFT_GEN : IF G_ENABLE_SHIFT = 0 GENERATE
		s_shifted      <= signed(s_pipeline_end);
		s_shifted_ctrl <= s_control_signals_line(s_control_signals_line'HIGH);
	END GENERATE NO_SHIFT_GEN;

	s_clipped <= f_clip(s_shifted);

	-------------------
	-- One single ReLU stage behind the whole tree
	-------------------

	RELU_GEN : IF G_ENABLE_RELU = 1 GENERATE

		RELU_DELAY_PROC : PROCESS (clk) IS
		BEGIN

			IF rising_edge(clk) THEN
				IF rst = '1' THEN
					s_relu_value   <= (OTHERS => '0');
					s_relu_control <= (OTHERS => '0');
				ELSIF i_en = '1' THEN
					s_relu_value   <= s_clipped;
					s_relu_control <= s_shifted_ctrl;
				END IF;
			END IF;

		END PROCESS RELU_DELAY_PROC;

		o_vec                 <= (OTHERS => '0') WHEN signed(s_relu_value) < 0 ELSE s_relu_value;
		s_res_control_signals <= s_relu_control;

	END GENERATE RELU_GEN;

	NO_RELU_GEN : IF G_ENABLE_RELU = 0 GENERATE
		o_vec                 <= s_clipped;
		s_res_control_signals <= s_shifted_ctrl;
	END GENERATE NO_RELU_GEN;

	-------------------
	-- Set OUTPUTs
	-------------------
	-- Extra step over signal to achieve same delta cycle for o_vec and o_control_signals
	o_control_signals <= s_res_control_signals;

END ARCHITECTURE rtl;
