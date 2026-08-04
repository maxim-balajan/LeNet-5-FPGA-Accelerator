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

ENTITY convolution_slider IS
	GENERIC (
		G_BIT_WIDTH    : NATURAL := 8;
		G_INPUT_WIDTH  : NATURAL := 32;
		G_INPUT_HEIGHT : NATURAL := 32;
		G_KERNEL_SIZE  : NATURAL := 5
	);
	PORT (
		clk               : IN STD_LOGIC;
		rst               : IN STD_LOGIC;
		i_pixel_stream    : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		i_valid_pixel     : IN STD_LOGIC;
		o_kernel_complete : OUT STD_LOGIC;
		o_kernel_en       : OUT STD_LOGIC;
		--! G_KERNEL_SIZE**2 values, element i occupies ((i + 1) * G_BIT_WIDTH - 1 downto i * G_BIT_WIDTH)
		o_kernel_activations : OUT STD_LOGIC_VECTOR(G_KERNEL_SIZE ** 2 * G_BIT_WIDTH - 1 DOWNTO 0)
	);
END ENTITY convolution_slider;

ARCHITECTURE rtl OF convolution_slider IS

	-- Values in order to retrieve pixels from input stream
	SIGNAL s_pixel_input_x : UNSIGNED(integer(ceil(log2(real(G_INPUT_WIDTH)))) - 1 DOWNTO 0);
	SIGNAL s_pixel_input_y : UNSIGNED(integer(ceil(log2(real(G_INPUT_HEIGHT)))) DOWNTO 0);
	-- X Coordinate delayed by one cycle; similar control logic as in pooling slider
	SIGNAL s_old_pixel_input_x : UNSIGNED(integer(ceil(log2(real(G_INPUT_WIDTH)))) - 1 DOWNTO 0);
	-- Current pixel to be pipelined
	SIGNAL s_current_pixel : STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_current_valid : STD_LOGIC;

	-- Helper signals to determine which kernels are valid and when computation needs to end
	SIGNAL s_line_x          : UNSIGNED(integer(ceil(log2(real(G_INPUT_WIDTH)))) - 1 DOWNTO 0);
	SIGNAL s_init_complete   : STD_LOGIC;
	SIGNAL s_kernel_en       : STD_LOGIC;
	SIGNAL s_kernel_complete : STD_LOGIC;
	SIGNAL s_valid_kernel    : STD_LOGIC;

BEGIN

	-- This process computes the current pixel
	-- And also sets a few control signal wether the kernel provided is valid or if all pixels were processed

	GET_PIXEL_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_pixel_input_x     <= (OTHERS => '0');
				s_pixel_input_y     <= (OTHERS => '0');
				s_old_pixel_input_x <= (OTHERS => '1');
				s_current_pixel     <= (OTHERS => '0');
				s_line_x            <= (OTHERS => '0');
				s_kernel_complete   <= '0';
			ELSE
				IF i_valid_pixel = '1' THEN
					-- Get current pixel
					s_current_pixel <= i_pixel_stream;
					s_current_valid <= i_valid_pixel;
				ELSE
					s_current_valid <= '0';
				END IF;

				-- Compute current pixel coordinate
				IF s_init_complete = '1' AND s_current_valid = '1' THEN
					s_pixel_input_x <= s_pixel_input_x + 1;
					IF s_pixel_input_x = G_INPUT_WIDTH - 1 THEN
						s_pixel_input_x <= (OTHERS => '0');
						s_pixel_input_y <= s_pixel_input_y + 1;
					END IF;
				END IF;

				-- And if s_pixel_input_y is OOB, then finish computation
				IF s_pixel_input_y = G_INPUT_HEIGHT - G_KERNEL_SIZE AND s_pixel_input_x = G_INPUT_WIDTH - G_KERNEL_SIZE THEN
					s_kernel_complete <= '1';
				END IF;

				-- Delay old pixel for layer use of kernel_en
				IF s_init_complete = '1' THEN
					s_old_pixel_input_x <= s_pixel_input_x;
				END IF;
			END IF;
		END IF;

	END PROCESS GET_PIXEL_PROC;

	-- Instantiation of main component that gets all valid (and invalid) kernels

	KERNEL_SLIDER_INST : ENTITY work.kernel_slider
		GENERIC MAP (
			G_BIT_WIDTH   => G_BIT_WIDTH,
			G_INPUT_WIDTH => G_INPUT_WIDTH,
			G_KERNEL_SIZE => G_KERNEL_SIZE
		)
		PORT MAP (
			clk                  => clk,
			rst                  => rst,
			i_en                 => s_current_valid,
			i_pixel_stream       => s_current_pixel,
			o_init_complete      => s_init_complete,
			o_kernel_activations => o_kernel_activations
		);

	-- This is a helper signal that stores wether a kernel is definitely valid or not (but is not the sole criteria)
	s_valid_kernel <= '1' WHEN s_pixel_input_x < G_INPUT_WIDTH - G_KERNEL_SIZE + 1 ELSE '0';

	-- These signals are important for the computation and pooling unit directly followed after this unit
	s_kernel_en <= '1' WHEN s_init_complete = '1'
	                        AND s_valid_kernel = '1'
	                        AND s_kernel_complete = '0'
	                        AND s_old_pixel_input_x /= s_pixel_input_x ELSE
	               '0';

	o_kernel_en <= s_kernel_en;

	o_kernel_complete <= s_kernel_complete;

END ARCHITECTURE rtl;
