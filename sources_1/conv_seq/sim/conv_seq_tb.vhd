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
USE ieee.math_real.ALL;

ENTITY conv_seq_tb IS
END ENTITY conv_seq_tb;

ARCHITECTURE bench OF conv_seq_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT vector_length        : NATURAL              := 8;
	CONSTANT accumulator_length   : NATURAL              := 24;
	CONSTANT input_width          : NATURAL              := 14;
	CONSTANT input_height         : NATURAL              := 14;
	CONSTANT kernel_size          : NATURAL              := 5;
	CONSTANT pooling_size         : INTEGER RANGE 2 TO 2 := 2;
	CONSTANT enable_clip_adder    : INTEGER RANGE 0 TO 1 := 1;
	CONSTANT total_input_channel  : NATURAL              := 6;
	CONSTANT total_output_channel : NATURAL              := 16;
	CONSTANT weight_prefix        : STRING               := "../data/output/conv_2_weights_ch";
	CONSTANT current_scale        : NATURAL              := 2;
	CONSTANT scale_path           : STRING               := "../data/scale_values.data";
	CONSTANT input_path           : STRING               := "../data/example_layer_data/2_max_pool_1.data";
	-- Ports
	SIGNAL clk               : STD_LOGIC := '0';
	SIGNAL rst               : STD_LOGIC;
	SIGNAL pixel_stream      : STD_LOGIC_VECTOR(total_input_channel * vector_length - 1 DOWNTO 0);
	SIGNAL valid_pixel       : STD_LOGIC;
	SIGNAL new_pixels_stream : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	-- the flat vectors coming out of init_from_file are unpacked so that they can be
	-- indexed with a signal

	TYPE t_stream IS ARRAY(0 TO total_input_channel * input_width * input_height - 1) OF STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	FUNCTION f_unpack_stream (
		packed : STD_LOGIC_VECTOR
	) RETURN t_stream IS

		VARIABLE v : t_stream;

	BEGIN

		FOR i IN v'RANGE LOOP

			v(i) := packed((i + 1) * vector_length - 1 DOWNTO i * vector_length);

		END LOOP;

		RETURN v;

	END FUNCTION f_unpack_stream;

	CONSTANT s_input_stream : t_stream                                        := f_unpack_stream(init_from_file(input_path, vector_length, total_input_channel * input_width * input_height, vector_length));
	SIGNAL   s_read_pointer : INTEGER RANGE 0 TO (input_width * input_height) := 0;

	SIGNAL s_write_pointer : INTEGER RANGE 0 TO (5 ** 2 - 1) := 0;

	TYPE t_channel IS ARRAY(0 TO 5 ** 2 - 1) OF STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	TYPE t_output IS ARRAY(0 TO total_output_channel - 1) OF t_channel;

	SIGNAL s_output_values : t_output;

	SIGNAL s_new_pixel_complete, s_new_valid_pixel : STD_LOGIC;
	SIGNAL s_pixel_output_channel                  : STD_LOGIC_VECTOR(integer(ceil(log2(real(total_output_channel)))) - 1 DOWNTO 0);

	-- expected output of the first convolution
	CONSTANT expected_result_path : STRING := "../data/example_layer_data/4_max_pool_2.data";

	TYPE t_expected IS ARRAY(0 TO total_output_channel * 5 ** 2 - 1) OF STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	FUNCTION f_unpack_expected (
		packed : STD_LOGIC_VECTOR
	) RETURN t_expected IS

		VARIABLE v : t_expected;

	BEGIN

		FOR i IN v'RANGE LOOP

			v(i) := packed((i + 1) * vector_length - 1 DOWNTO i * vector_length);

		END LOOP;

		RETURN v;

	END FUNCTION f_unpack_expected;

	CONSTANT expected_output : t_expected := f_unpack_expected(init_from_file(expected_result_path, vector_length, total_output_channel * (5 ** 2)));

	SIGNAL s_invalid_delay : INTEGER RANGE 0 TO 3;

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

						FOR i IN 0 TO total_input_channel - 1 LOOP

							pixel_stream((i + 1) * vector_length - 1 downto i * vector_length) <= s_input_stream(i * input_width * input_height + s_read_pointer);

						END LOOP;

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

	conv_seq_inst : ENTITY work.conv_seq
		GENERIC MAP (
			G_BIT_WIDTH             => vector_length,
			G_ACCUMULATOR_BIT_WIDTH => accumulator_length,
			G_INPUT_WIDTH           => input_width,
			G_INPUT_HEIGHT          => input_height,
			G_KERNEL_SIZE           => kernel_size,
			G_POOLING_SIZE          => pooling_size,
			G_ENABLE_CLIP_ADDER     => enable_clip_adder,
			G_TOTAL_INPUT_CHANNEL   => total_input_channel,
			G_TOTAL_OUTPUT_CHANNEL  => total_output_channel,
			G_WEIGHT_PATH_PREFIX    => weight_prefix,
			G_SCALE_ID              => current_scale,
			G_SCALE_FILE_PATH       => scale_path
		)
		PORT MAP (
			clk                    => clk,
			rst                    => rst,
			i_pixel_stream         => pixel_stream,
			i_valid_pixel          => valid_pixel,
			o_pixels_stream        => new_pixels_stream,
			o_valid_pixel          => s_new_valid_pixel,
			o_pixel_complete       => s_new_pixel_complete,
			o_pixel_output_channel => s_pixel_output_channel
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

	rst <= '1' AFTER 0 ns, '0' AFTER 2 * clk_period, '1' AFTER 5000 * clk_period, '0' AFTER 5010 * clk_period;

	READ_AND_CHECK_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_write_pointer <= 0;
			ELSIF (s_new_valid_pixel AND not s_new_pixel_complete) = '1' THEN
				-- Read and Write to output signal
				s_output_values(to_integer(unsigned(s_pixel_output_channel)))(s_write_pointer) <= new_pixels_stream;

				IF s_write_pointer >= 5 ** 2 - 1 THEN
					s_write_pointer <= 0;
				ELSE
					s_write_pointer <= s_write_pointer + 1;
				END IF;

				-- Compare with expected result

				ASSERT new_pixels_stream = expected_output(to_integer(unsigned(s_pixel_output_channel)) * 5 ** 2 + s_write_pointer)
					REPORT "Expected: " & integer'IMAGE(to_integer(unsigned(s_pixel_output_channel)) * 5 ** 2 + s_write_pointer) & " | Got: " & integer'IMAGE(to_integer(signed(new_pixels_stream)))
					SEVERITY FAILURE;
			END IF;
		END IF;

	END PROCESS READ_AND_CHECK_PROC;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 5000 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
