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

ENTITY convolution_slider_tb IS
END ENTITY convolution_slider_tb;

ARCHITECTURE bench OF convolution_slider_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT vector_length : INTEGER := 16;
	CONSTANT input_width   : INTEGER := 10;
	CONSTANT input_height  : INTEGER := 10;
	CONSTANT kernel_size   : INTEGER := 5;
	-- Ports
	SIGNAL clk                : STD_LOGIC := '1';
	SIGNAL rst                : STD_LOGIC;
	SIGNAL pixel_stream       : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL kernel_comp        : STD_LOGIC;
	SIGNAL kernel_en          : STD_LOGIC;
	SIGNAL kernel_activations : STD_LOGIC_VECTOR(kernel_size ** 2 * vector_length - 1 DOWNTO 0);
	SIGNAL valid_pixel        : STD_LOGIC;

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	conv_slider_inst : ENTITY work.convolution_slider
		GENERIC MAP (
			G_BIT_WIDTH    => vector_length,
			G_INPUT_WIDTH  => input_width,
			G_INPUT_HEIGHT => input_height,
			G_KERNEL_SIZE  => kernel_size
		)
		PORT MAP (
			clk                  => clk,
			rst                  => rst,
			i_pixel_stream       => pixel_stream,
			i_valid_pixel        => valid_pixel,
			o_kernel_complete    => kernel_comp,
			o_kernel_en          => kernel_en,
			o_kernel_activations => kernel_activations
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

	PIXEL_STREAM_PROC : PROCESS IS
	BEGIN

		WAIT FOR 2 * clk_period;

		y : FOR j IN 0 TO input_height - 1 LOOP

			x : FOR i IN 0 TO input_width - 1 LOOP

				pixel_stream <= std_logic_vector(to_unsigned(i + input_width * j + 1, pixel_stream'LENGTH));
				valid_pixel  <= '1';
				WAIT FOR clk_period;

				IF i mod 3 = 0 THEN
					pixel_stream <= (OTHERS => '1');
					valid_pixel  <= '0';
					WAIT FOR clk_period;
					WAIT FOR clk_period;
					WAIT FOR clk_period;
				END IF;

			END LOOP x;

		END LOOP y;

	END PROCESS PIXEL_STREAM_PROC;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 300 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
