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

ENTITY conv_pool_pipeline_tb IS
END ENTITY conv_pool_pipeline_tb;

ARCHITECTURE bench OF conv_pool_pipeline_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT vector_length              : NATURAL              := 8;
	CONSTANT input_width                : NATURAL              := 14;
	CONSTANT input_height               : NATURAL              := 14;
	CONSTANT kernel_size                : NATURAL              := 5;
	CONSTANT pooling_size               : INTEGER RANGE 2 TO 2 := 2;
	CONSTANT enable_weights             : INTEGER RANGE 0 TO 1 := 1;
	CONSTANT total_input_channel        : NATURAL              := 1;
	CONSTANT total_output_channel       : NATURAL              := 1;
	CONSTANT current_channel            : NATURAL              := 1;
	CONSTANT init_type                  : INTEGER RANGE 0 TO 1 := 0;
	CONSTANT weight_prefix              : STRING               := "../data/output/conv_1_weights_ch";
	CONSTANT current_scale              : NATURAL              := 1;
	CONSTANT scale_path                 : STRING               := "../data/test_scale.data";
	CONSTANT enable_multiplication_line : INTEGER RANGE 0 TO 1 := 1;
	CONSTANT enable_shift               : INTEGER RANGE 0 TO 1 := 1;
	-- ReLU is disabled for test purposes, but behavior should be "the same" (just without the ReLU)
	CONSTANT enable_relu : INTEGER RANGE 0 TO 1 := 0;

	CONSTANT output_length : INTEGER RANGE 0 TO ((3 ** enable_multiplication_line)) * vector_length := 8;
	-- Ports
	SIGNAL clk               : STD_LOGIC := '1';
	SIGNAL rst               : STD_LOGIC;
	SIGNAL activations       : STD_LOGIC_VECTOR(kernel_size ** 2 * vector_length - 1 DOWNTO 0);
	SIGNAL kernel_en         : STD_LOGIC;
	SIGNAL kernel_complete   : STD_LOGIC;
	SIGNAL weights_valid     : STD_LOGIC;
	SIGNAL new_pixel         : STD_LOGIC_VECTOR(output_length - 1 DOWNTO 0);
	SIGNAL valid_pixel       : STD_LOGIC;
	SIGNAL comp_complete     : STD_LOGIC;
	SIGNAL start_valid_pixel : STD_LOGIC;

	SIGNAL s_pixel_stream : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

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

	PIXEL_PROC : PROCESS IS
	BEGIN

		s_pixel_stream    <= x"FF";
		start_valid_pixel <= '1';
		WAIT FOR clk_period;
		s_pixel_stream    <= (OTHERS => '0');
		start_valid_pixel <= '0';
		WAIT FOR clk_period;
		s_pixel_stream    <= (OTHERS => '0');
		start_valid_pixel <= '0';
		WAIT FOR clk_period;
		s_pixel_stream    <= x"01";
		start_valid_pixel <= '1';
		WAIT FOR clk_period;
		s_pixel_stream    <= (OTHERS => '0');
		start_valid_pixel <= '0';
		WAIT FOR clk_period;

	END PROCESS PIXEL_PROC;

	CONV_SLIDER : ENTITY work.convolution_slider
		GENERIC MAP (
			G_BIT_WIDTH    => vector_length,
			G_INPUT_WIDTH  => input_width,
			G_INPUT_HEIGHT => input_height,
			G_KERNEL_SIZE  => kernel_size
		)
		PORT MAP (
			clk                  => clk,
			rst                  => rst,
			i_pixel_stream       => s_pixel_stream,
			i_valid_pixel        => start_valid_pixel,
			o_kernel_complete    => kernel_complete,
			o_kernel_en          => kernel_en,
			o_kernel_activations => activations
		);

	conv_pool_pipeline_inst : ENTITY work.conv_pool_pipeline
		GENERIC MAP (
			G_BIT_WIDTH            => vector_length,
			G_INPUT_WIDTH          => input_width,
			G_INPUT_HEIGHT         => input_height,
			G_KERNEL_SIZE          => kernel_size,
			G_POOLING_SIZE         => pooling_size,
			G_ENABLE_WEIGHTS       => enable_weights,
			G_TOTAL_INPUT_CHANNEL  => total_input_channel,
			G_TOTAL_OUTPUT_CHANNEL => total_output_channel,
			G_CURRENT_CHANNEL      => current_channel,
			G_INIT_TYPE            => init_type,
			G_WEIGHT_PATH_PREFIX   => weight_prefix,
			G_SCALE_ID             => current_scale,
			G_SCALE_FILE_PATH      => scale_path,
			G_ENABLE_CLIP_ADDER    => 1,
			G_ENABLE_MUL_LINE      => enable_multiplication_line,
			G_ENABLE_SHIFT         => enable_shift,
			G_ENABLE_RELU          => enable_relu,
			G_OUT_BIT_WIDTH        => output_length
		)
		PORT MAP (
			clk               => clk,
			rst               => rst,
			i_activations     => activations,
			i_kernel_en       => kernel_en,
			i_kernel_complete => kernel_complete,
			i_base_addr       => (OTHERS => '0'),
			o_weights_valid   => weights_valid,
			o_pixel           => new_pixel,
			o_valid_pixel     => valid_pixel,
			o_comp_complete   => comp_complete
		);

	TB : PROCESS IS
	BEGIN

		WAIT FOR 1000 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
