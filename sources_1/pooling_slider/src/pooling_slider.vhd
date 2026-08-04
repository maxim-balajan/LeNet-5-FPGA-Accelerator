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

ENTITY pooling_slider IS
	GENERIC (
		G_BIT_WIDTH             : NATURAL              := 8;
		G_ORIGINAL_INPUT_WIDTH  : NATURAL              := 32;
		G_ORIGINAL_INPUT_HEIGHT : NATURAL              := 32;
		G_KERNEL_SIZE           : NATURAL              := 5;
		G_POOLING_SIZE          : INTEGER RANGE 2 TO 2 := 2
	);
	PORT (
		clk               : IN STD_LOGIC;
		rst               : IN STD_LOGIC;
		i_pixel_stream    : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		i_valid_pixel     : IN STD_LOGIC;
		o_kernel_complete : OUT STD_LOGIC;
		o_kernel_en       : OUT STD_LOGIC;
		--! G_POOLING_SIZE**2 values, element i occupies ((i + 1) * G_BIT_WIDTH - 1 downto i * G_BIT_WIDTH)
		o_kernel_activations : OUT STD_LOGIC_VECTOR(G_POOLING_SIZE ** 2 * G_BIT_WIDTH - 1 DOWNTO 0)
	);
END ENTITY pooling_slider;

ARCHITECTURE rtl OF pooling_slider IS

	-- Image dimensions of input (in first convolution this would be 28x28)
	CONSTANT C_OLD_IMAGE_WIDTH  : REAL := real(G_ORIGINAL_INPUT_WIDTH - G_KERNEL_SIZE + 1);
	CONSTANT C_OLD_IMAGE_HEIGHT : REAL := real(G_ORIGINAL_INPUT_HEIGHT - G_KERNEL_SIZE + 1);
	-- Image dimensions of output (in first convolution this would be 14x14)
	CONSTANT C_NEW_IMAGE_WIDTH  : REAL := real(G_ORIGINAL_INPUT_WIDTH - G_KERNEL_SIZE + 1) / 2.0;
	CONSTANT C_NEW_IMAGE_HEIGHT : REAL := real(G_ORIGINAL_INPUT_HEIGHT - G_KERNEL_SIZE + 1) / 2.0;

	-- pixel locations of input stream (in first convolution this would be 28x28)
	SIGNAL s_pixel_input_x : UNSIGNED(integer(ceil(log2(C_OLD_IMAGE_WIDTH))) - 1 DOWNTO 0);
	SIGNAL s_pixel_input_y : UNSIGNED(integer(ceil(log2(C_OLD_IMAGE_HEIGHT))) DOWNTO 0);
	-- pixel x_coordinate delayed by one cycle; used for keeping control logic in check
	SIGNAL s_pixel_old_input_x : UNSIGNED(integer(ceil(log2(C_OLD_IMAGE_WIDTH))) - 1 DOWNTO 0);
	-- pixel locations of output stream (in first convolution this would be 14x14)
	SIGNAL s_pixel_output_x : UNSIGNED(integer(ceil(log2(C_NEW_IMAGE_WIDTH))) - 1 DOWNTO 0);
	SIGNAL s_pixel_output_y : UNSIGNED(integer(ceil(log2(C_NEW_IMAGE_HEIGHT))) DOWNTO 0);

	-- Current pixel to be pipelined
	SIGNAL s_current_pixel : STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_current_valid : STD_LOGIC;

	-- Helper signals to determine which kernels are valid and when computation needs to end
	SIGNAL s_init_complete   : STD_LOGIC;
	SIGNAL s_kernel_en       : STD_LOGIC;
	SIGNAL s_kernel_complete : STD_LOGIC;

BEGIN

	GET_PIXEL_ADDR_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_pixel_input_x <= (OTHERS => '0');
				s_pixel_input_y <= (OTHERS => '0');
				-- old x coordinate has to be set to -1 because otherwise control logic will break
				s_pixel_old_input_x <= (OTHERS => '1');
				s_current_pixel     <= (OTHERS => '0');
				s_kernel_complete   <= '0';
				s_current_valid     <= '0';
			ELSE
				IF i_valid_pixel = '1' THEN
					-- Get current pixel
					s_current_pixel <= i_pixel_stream;
					s_current_valid <= i_valid_pixel;
				ELSE
					s_current_valid <= '0';
				END IF;

				-- after init is finished just iterate other the image; disregard overflows by s_pixel_input_y
				IF s_init_complete = '1' AND s_current_valid = '1' THEN
					s_pixel_input_x <= s_pixel_input_x + 1;
					IF s_pixel_input_x = integer(C_OLD_IMAGE_WIDTH) - 1 THEN
						s_pixel_input_x <= (OTHERS => '0');
						s_pixel_input_y <= s_pixel_input_y + 1;
					END IF;
				END IF;

				-- This will most likely break for other pooling sizes
				-- after final pixel has been reached, set complete flag;
				-- This has to be written exactly like this because otherwise undefined behavior of HW after completion will mess with this flag
				IF s_pixel_output_x = integer(C_NEW_IMAGE_WIDTH) - 1 AND s_pixel_output_y = integer(C_NEW_IMAGE_HEIGHT) - 1 AND s_kernel_en = '1' THEN
					s_kernel_complete <= '1';
				END IF;
				-- This stores the old coordinates in order because otherwise the control signals will be wrong
				IF s_init_complete = '1' THEN
					s_pixel_old_input_x <= s_pixel_input_x;
				END IF;
			END IF;
		END IF;

	END PROCESS GET_PIXEL_ADDR_PROC;

	-- Instantiation of main component that gets all valid (and invalid) kernels

	KERNEL_SLIDER_INST : ENTITY work.kernel_slider
		GENERIC MAP (
			G_BIT_WIDTH   => G_BIT_WIDTH,
			G_INPUT_WIDTH => integer(C_OLD_IMAGE_WIDTH),
			G_KERNEL_SIZE => G_POOLING_SIZE
		)
		PORT MAP (
			clk                  => clk,
			rst                  => rst,
			i_en                 => s_current_valid,
			i_pixel_stream       => s_current_pixel,
			o_init_complete      => s_init_complete,
			o_kernel_activations => o_kernel_activations
		);

	-- These signals are important for the actual pooling unit directly followed after this unit

	s_kernel_en <= '1' WHEN s_init_complete = '1'
	                        AND s_kernel_complete = '0'
	                        AND s_pixel_input_x(s_pixel_input_x'LOW) = '0'
	                        AND s_pixel_input_y(s_pixel_input_y'LOW) = '0'
	                        AND s_pixel_old_input_x(s_pixel_old_input_x'LOW) /= s_pixel_input_x(s_pixel_input_x'LOW) ELSE
	               '0';

	o_kernel_en <= s_kernel_en;

	-- Set destination of new pooled value
	s_pixel_output_x <= resize(shift_right(s_pixel_input_x, 1), s_pixel_output_x'LENGTH);
	s_pixel_output_y <= resize(shift_right(s_pixel_input_y, 1), s_pixel_output_y'LENGTH);

	o_kernel_complete <= s_kernel_complete;

END ARCHITECTURE rtl;
