------------------------------------------------------------------------------
-- SPDX-License-Identifier: GPL-3.0-only
--
-- A hardware accelerated LeNet-5 architecture integrated to be accessible
-- by the processing system (CPU) of an FPGA.
-- Copyright (C) 2025  Markus Elias Gerber
-- Copyright (C) 2025  Maxim Balajan
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
USE work.libmemory.ALL;

ENTITY dense_layer_tb IS
END ENTITY dense_layer_tb;

ARCHITECTURE bench OF dense_layer_tb IS

	-- Constants
	CONSTANT clk_period      : TIME    := 10 ns;
	CONSTANT scale_file_name : STRING  := "../data/scale_values.data";
	CONSTANT scale_row       : NATURAL := 3;
	-- Generics
	CONSTANT vector_length     : NATURAL              := 8;
	CONSTANT max_weight_width  : NATURAL              := 400;
	CONSTANT max_weight_height : NATURAL              := 120;
	CONSTANT enable_shift      : INTEGER RANGE 0 TO 1 := 1;
	CONSTANT weight_width_0    : NATURAL              := 400;
	CONSTANT weight_width_1    : NATURAL              := 120;
	CONSTANT weight_width_2    : NATURAL              := 84;
	CONSTANT weight_height_0   : NATURAL              := 120;
	CONSTANT weight_height_1   : NATURAL              := 84;
	CONSTANT weight_height_2   : NATURAL              := 10;
	CONSTANT total_width       : NATURAL              := weight_width_0 + weight_width_1 + weight_width_2;
	CONSTANT weight_prefix     : STRING               := "../data/output/dense_weights_row";
	-- Ports
	SIGNAL clk                  : STD_LOGIC := '0';
	SIGNAL rst                  : STD_LOGIC;
	SIGNAL en                   : STD_LOGIC;
	SIGNAL actual_weight_width  : STD_LOGIC_VECTOR(integer(ceil(log2(real(max_weight_width)))) DOWNTO 0);
	SIGNAL actual_weight_height : STD_LOGIC_VECTOR(integer(ceil(log2(real(max_weight_height)))) DOWNTO 0);
	SIGNAL input                : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL base_addr            : STD_LOGIC_VECTOR(integer(ceil(log2(real(total_width)))) - 1 DOWNTO 0);
	SIGNAL results              : STD_LOGIC_VECTOR(max_weight_height * 3 * vector_length - 1 DOWNTO 0);

	TYPE t_wide IS ARRAY(0 TO max_weight_height - 1) OF STD_LOGIC_VECTOR(3 * vector_length - 1 DOWNTO 0);

	TYPE t_narrow IS ARRAY(0 TO max_weight_height - 1) OF STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	TYPE t_input IS ARRAY(0 TO weight_width_1 - 1) OF STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	FUNCTION f_unpack_input (
		packed : STD_LOGIC_VECTOR
	) RETURN t_input IS

		VARIABLE v : t_input;

	BEGIN

		FOR i IN v'RANGE LOOP

			v(i) := packed((i + 1) * (vector_length) - 1 DOWNTO i * (vector_length));

		END LOOP;

		RETURN v;

	END FUNCTION f_unpack_input;

	SIGNAL actual_results_shifted : t_wide;
	SIGNAL actual_results_clipped : t_narrow;
	SIGNAL comp_complete          : STD_LOGIC;

	CONSTANT c_input_data_file_name : STRING  := "../data/example_layer_data/6_dense_1.data";
	CONSTANT input_stream           : t_input := f_unpack_input(init_from_file(c_input_data_file_name, vector_length, weight_width_1));
	SIGNAL   read_pointer           : INTEGER;
	SIGNAL   invalid_delay          : INTEGER RANGE 0 TO 3;

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	dense_layer_inst : ENTITY work.dense_layer
		GENERIC MAP (
			G_BIT_WIDTH          => vector_length,
			G_OUT_BIT_WIDTH      => 3 * vector_length,
			G_MAX_WEIGHT_WIDTH   => max_weight_width,
			G_MAX_WEIGHT_HEIGHT  => max_weight_height,
			G_WEIGHT_WIDTH_0     => weight_width_0,
			G_WEIGHT_WIDTH_1     => weight_width_1,
			G_WEIGHT_WIDTH_2     => weight_width_2,
			G_WEIGHT_PATH_PREFIX => weight_prefix
		)
		PORT MAP (
			clk                    => clk,
			rst                    => rst,
			i_en                   => en,
			i_vector               => input,
			i_actual_weight_width  => actual_weight_width,
			i_actual_weight_height => actual_weight_height,
			i_base_addr            => base_addr,
			o_results              => results,
			o_comp_complete        => comp_complete
		);

	CLK_PROC : PROCESS IS
	BEGIN

		WHILE s_sim_done = '0' LOOP

			clk <= '0';
			WAIT FOR clk_period / 2;
			clk <= '1';
			WAIT FOR clk_period / 2;

		END LOOP;

		WAIT;

	END PROCESS CLK_PROC;

	rst                  <= '1' AFTER 0 ns, '0' AFTER 2 * clk_period;
	actual_weight_width  <= std_logic_vector(to_unsigned(weight_width_1, actual_weight_width'LENGTH));
	actual_weight_height <= std_logic_vector(to_unsigned(weight_height_1, actual_weight_height'LENGTH));
	base_addr            <= std_logic_vector(to_unsigned(weight_width_0, base_addr'LENGTH));

	INPUT_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				input         <= (OTHERS => '0');
				read_pointer  <= 0;
				en            <= '0';
				invalid_delay <= 0;
			ELSE
				IF invalid_delay = 0 THEN
					input <= input_stream(read_pointer);
					en    <= '1';
					IF read_pointer >= weight_width_1 - 1 THEN
						read_pointer <= 0;
					ELSE
						read_pointer <= read_pointer + 1;
					END IF;
				ELSE
					input <= (OTHERS => '1');
					en    <= '0';
				END IF;
				IF invalid_delay >= 3 THEN
					invalid_delay <= 0;
				ELSE
					invalid_delay <= invalid_delay + 1;
				END IF;
			END IF;
		END IF;

	END PROCESS INPUT_PROC;

	OUTPUT_GEN : FOR i IN actual_results_shifted'RANGE GENERATE
		actual_results_shifted(i) <= std_logic_vector(shift_right(signed(results((i + 1) * 3 * vector_length - 1 DOWNTO i * 3 * vector_length)), 9));

		actual_results_clipped(i) <= std_logic_vector(to_signed(2 ** (vector_length - 1) - 1, actual_results_clipped(i)'LENGTH))
	                             WHEN signed(actual_results_shifted(i)) > 2 ** (vector_length - 1) - 1 ELSE
	                             std_logic_vector(to_signed(- 2 ** (vector_length - 1), actual_results_clipped(i)'LENGTH))
	                             WHEN signed(actual_results_shifted(i)) < - 2 ** (vector_length - 1) ELSE
	                             actual_results_shifted(i)(vector_length - 1 DOWNTO 0);
	END GENERATE OUTPUT_GEN;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 1000 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
