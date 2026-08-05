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
USE work.libmemory.ALL;

ENTITY dense_layer_combined_tb IS
END ENTITY dense_layer_combined_tb;

ARCHITECTURE bench OF dense_layer_combined_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT vector_length     : NATURAL := 8;
	CONSTANT max_weight_width  : NATURAL := 400;
	CONSTANT max_weight_height : NATURAL := 120;
	CONSTANT shift_path        : STRING  := "../data/scale_values.data";
	CONSTANT scale_id_0        : NATURAL := 3;
	CONSTANT scale_id_1        : NATURAL := 4;
	CONSTANT scale_id_2        : NATURAL := 5;
	CONSTANT weight_width_0    : NATURAL := 400;
	CONSTANT weight_width_1    : NATURAL := 120;
	CONSTANT weight_width_2    : NATURAL := 84;
	CONSTANT weight_height_0   : NATURAL := 120;
	CONSTANT weight_height_1   : NATURAL := 84;
	CONSTANT weight_height_2   : NATURAL := 10;
	CONSTANT total_width       : NATURAL := weight_width_0 + weight_width_1 + weight_width_2;
	CONSTANT weight_prefix     : STRING  := "../data/output/dense_weights_row";
	-- Ports
	SIGNAL clk           : STD_LOGIC := '0';
	SIGNAL rst           : STD_LOGIC;
	SIGNAL en            : STD_LOGIC;
	SIGNAL input         : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL results       : STD_LOGIC_VECTOR(weight_height_2 * vector_length - 1 DOWNTO 0);
	SIGNAL comp_complete : STD_LOGIC;

	CONSTANT c_input_data_file_name : STRING := "../data/example_layer_data/5_flatten.data";

	TYPE t_input IS ARRAY(0 TO max_weight_width - 1) OF STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

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

	CONSTANT input_stream  : t_input := f_unpack_input(init_from_file(c_input_data_file_name, vector_length, max_weight_width, vector_length));
	SIGNAL   read_pointer  : INTEGER;
	SIGNAL   invalid_delay : INTEGER RANGE 0 TO 3;

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	dense_layer_combined_inst : ENTITY work.dense_layer_combined
		GENERIC MAP (
			G_BIT_WIDTH          => vector_length,
			G_MAX_WEIGHT_WIDTH   => max_weight_width,
			G_MAX_WEIGHT_HEIGHT  => max_weight_height,
			G_SCALE_FILE_PATH    => shift_path,
			G_SCALE_ID_0         => scale_id_0,
			G_SCALE_ID_1         => scale_id_1,
			G_SCALE_ID_2         => scale_id_2,
			G_WEIGHT_WIDTH_0     => weight_width_0,
			G_WEIGHT_WIDTH_1     => weight_width_1,
			G_WEIGHT_WIDTH_2     => weight_width_2,
			G_WEIGHT_HEIGHT_0    => weight_height_0,
			G_WEIGHT_HEIGHT_1    => weight_height_1,
			G_WEIGHT_HEIGHT_2    => weight_height_2,
			G_WEIGHT_PATH_PREFIX => weight_prefix
		)
		PORT MAP (
			clk             => clk,
			rst             => rst,
			i_en            => en,
			i_vector        => input,
			o_results       => results,
			o_comp_complete => comp_complete
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

	rst <= '1' AFTER 0 ns, '0' AFTER 2 * clk_period;

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
					IF read_pointer >= max_weight_width - 1 THEN
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

	TB : PROCESS IS
	BEGIN

		WAIT FOR 3000 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
