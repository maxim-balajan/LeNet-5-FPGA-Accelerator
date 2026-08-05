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

ENTITY conv_combined_tb IS
END ENTITY conv_combined_tb;

ARCHITECTURE bench OF conv_combined_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 5 ns;
	-- Generics
	CONSTANT vector_length               : NATURAL              := 8;
	CONSTANT accumulator_length          : NATURAL              := 24;
	CONSTANT input_width                 : NATURAL              := 32;
	CONSTANT input_height                : NATURAL              := 32;
	CONSTANT kernel_size                 : NATURAL              := 5;
	CONSTANT pooling_size                : INTEGER RANGE 2 TO 2 := 2;
	CONSTANT enable_clip_adder           : INTEGER RANGE 0 TO 1 := 1;
	CONSTANT total_input_channel_conv_1  : NATURAL              := 1;
	CONSTANT total_input_channel_conv_2  : NATURAL              := 6;
	CONSTANT total_output_channel_conv_2 : NATURAL              := 16;
	CONSTANT weight_prefix_conv_1        : STRING               := "../data/output/conv_1_weights_ch";
	CONSTANT weight_prefix_conv_2        : STRING               := "../data/output/conv_2_weights_ch";
	CONSTANT scale_id_conv_1             : NATURAL              := 1;
	CONSTANT scale_id_conv_2             : NATURAL              := 2;
	CONSTANT scale_path                  : STRING               := "../data/scale_values.data";
	-- Ports
	SIGNAL clk                : STD_LOGIC := '0';
	SIGNAL rst                : STD_LOGIC;
	SIGNAL pixel_stream       : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL valid_pixel        : STD_LOGIC;
	SIGNAL new_pixel_stream   : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL new_valid_pixel    : STD_LOGIC;
	SIGNAL new_pixel_complete : STD_LOGIC;

	CONSTANT input_path : STRING := "../data/example_layer_data/0_input.data";

	-- the flat vector coming out of init_from_file is unpacked so that it can be
	-- indexed with a signal

	TYPE t_image IS ARRAY(0 TO input_width * input_height - 1) OF STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	FUNCTION f_unpack_image (
		packed : STD_LOGIC_VECTOR
	) RETURN t_image IS

		VARIABLE v : t_image;

	BEGIN

		FOR i IN v'RANGE LOOP

			v(i) := packed((i + 1) * vector_length - 1 DOWNTO i * vector_length);

		END LOOP;

		RETURN v;

	END FUNCTION f_unpack_image;

	CONSTANT s_input_stream : t_image := f_unpack_image(init_from_file(input_path, vector_length, input_width * input_height, vector_length));
	SIGNAL   s_read_pointer : INTEGER RANGE 0 TO (input_width * input_height);

	SIGNAL s_write_pointer : INTEGER;

	-- expected output of the first convolution
	CONSTANT expected_result_path : STRING := "../data/example_layer_data/5_flatten.data";

	TYPE t_result IS ARRAY(0 TO total_output_channel_conv_2 * kernel_size ** 2 - 1) OF STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	SIGNAL actual_output : t_result;

	FUNCTION f_unpack_result (
		packed : STD_LOGIC_VECTOR
	) RETURN t_result IS

		VARIABLE v : t_result;

	BEGIN

		FOR i IN v'RANGE LOOP

			v(i) := packed((i + 1) * vector_length - 1 DOWNTO i * vector_length);

		END LOOP;

		RETURN v;

	END FUNCTION f_unpack_result;

	CONSTANT expected_output : t_result := f_unpack_result(init_from_file(expected_result_path, vector_length, 16 * (5 ** 2)));

	SIGNAL s_invalid_delay : INTEGER RANGE 0 TO 3;
	SIGNAL s_comp_counter  : INTEGER RANGE 0 TO 2 := 0;

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	STREAM_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				pixel_stream    <= (OTHERS => '0');
				valid_pixel     <= '0';
				s_invalid_delay <= 0;
				s_read_pointer  <= 0;
			ELSE
				IF s_read_pointer < (input_width * input_height) THEN
					IF s_invalid_delay = 0 THEN
						pixel_stream   <= s_input_stream(s_read_pointer);
						s_read_pointer <= s_read_pointer + 1;
						valid_pixel    <= '1';
					ELSE
						valid_pixel <= '0';
					END IF;

					IF s_invalid_delay /= 3 THEN
						s_invalid_delay <= s_invalid_delay + 1;
					ELSE
						s_invalid_delay <= 0;
					END IF;
				ELSE
					pixel_stream <= (OTHERS => '0');
					valid_pixel  <= '0';
				END IF;
			END IF;
		END IF;

	END PROCESS STREAM_PROC;

	conv_combined_inst : ENTITY work.conv_combined
		GENERIC MAP (
			G_BIT_WIDTH                   => vector_length,
			G_ACCUMULATOR_BIT_WIDTH       => accumulator_length,
			G_INPUT_WIDTH                 => input_width,
			G_INPUT_HEIGHT                => input_height,
			G_KERNEL_SIZE                 => kernel_size,
			G_POOLING_SIZE                => pooling_size,
			G_ENABLE_CLIP_ADDER           => enable_clip_adder,
			G_TOTAL_INPUT_CHANNEL_CONV_1  => total_input_channel_conv_1,
			G_TOTAL_INPUT_CHANNEL_CONV_2  => total_input_channel_conv_2,
			G_TOTAL_OUTPUT_CHANNEL_CONV_2 => total_output_channel_conv_2,
			G_WEIGHT_PREFIX_CONV_1        => weight_prefix_conv_1,
			G_WEIGHT_PREFIX_CONV_2        => weight_prefix_conv_2,
			G_SCALE_ID_CONV_1             => scale_id_conv_1,
			G_SCALE_ID_CONV_2             => scale_id_conv_2,
			G_SCALE_FILE_PATH             => scale_path
		)
		PORT MAP (
			clk              => clk,
			rst              => rst,
			i_pixel_stream   => pixel_stream,
			i_valid_pixel    => valid_pixel,
			o_pixel_stream   => new_pixel_stream,
			o_valid_pixel    => new_valid_pixel,
			o_pixel_complete => new_pixel_complete
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

	rst <= '1' AFTER 0 ns, '0' AFTER 2 * clk_period, '1' AFTER 7500 * clk_period, '0' AFTER 7510 * clk_period;

	READ_AND_CHECK_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_write_pointer <= 0;
			ELSIF (new_valid_pixel AND not new_pixel_complete) = '1' THEN
				-- Read and Write to output signal
				actual_output(s_write_pointer) <= new_pixel_stream;

				IF s_write_pointer >= total_output_channel_conv_2 * kernel_size ** 2 - 1 THEN
					s_write_pointer <= 0;
				ELSE
					s_write_pointer <= s_write_pointer + 1;
				END IF;

				-- Compare with expected result

				ASSERT new_pixel_stream = expected_output(s_write_pointer)
					REPORT "Expected: " & integer'IMAGE(to_integer(unsigned(expected_output(s_write_pointer)))) &
					       " | Got: " & integer'IMAGE(to_integer(signed(actual_output(s_write_pointer))))
					SEVERITY FAILURE;
			END IF;
		END IF;

	END PROCESS READ_AND_CHECK_PROC;

	TB : PROCESS (new_pixel_complete) IS
	BEGIN

		IF rising_edge(new_pixel_complete) THEN
			IF s_comp_counter = 1 THEN
				s_sim_done <= '1';
			ELSE
				s_comp_counter <= s_comp_counter + 1;
			END IF;
		END IF;

	END PROCESS TB;

END ARCHITECTURE bench;
