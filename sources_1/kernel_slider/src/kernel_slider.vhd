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

ENTITY kernel_slider IS
	GENERIC (
		G_BIT_WIDTH   : NATURAL := 8;
		G_INPUT_WIDTH : NATURAL := 32;
		G_KERNEL_SIZE : NATURAL := 5
	);
	PORT (
		clk             : IN STD_LOGIC;
		rst             : IN STD_LOGIC;
		i_en            : IN STD_LOGIC;
		i_pixel_stream  : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_init_complete : OUT STD_LOGIC;
		--! G_KERNEL_SIZE**2 values, element i occupies ((i + 1) * G_BIT_WIDTH - 1 downto i * G_BIT_WIDTH)
		o_kernel_activations : OUT STD_LOGIC_VECTOR(G_KERNEL_SIZE ** 2 * G_BIT_WIDTH - 1 DOWNTO 0)
	);
END ENTITY kernel_slider;

ARCHITECTURE rtl OF kernel_slider IS

	--! One column of the kernel window

	TYPE t_kernel_column IS ARRAY(0 TO G_KERNEL_SIZE - 1) OF STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

	--! "Kernel matrix" + 1 because we have to take inputs into consideration

	TYPE t_kernel_matrix IS ARRAY(0 TO G_KERNEL_SIZE) OF t_kernel_column;

	SIGNAL s_kernel_matrix : t_kernel_matrix;
	-- Line Buffer wr_en line
	SIGNAL s_line_buffer_wr_en : STD_LOGIC_VECTOR(0 TO G_KERNEL_SIZE - 1);

	-- Helper signal to determine when initialization of pipeline is finished
	SIGNAL s_full_delay : STD_LOGIC_VECTOR(0 TO G_KERNEL_SIZE);

BEGIN

	-- This process sifts all control values and all kernel values through the pipeline

	BUFFER_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				-- Is set to one because initial buffer should always write
				s_line_buffer_wr_en(s_line_buffer_wr_en'low)            <= '1';
				s_full_delay(s_full_delay'low + 1 to s_full_delay'high) <= (OTHERS => '0');
			ELSIF i_en = '1' THEN
				-- Shift values through kernel window
				s_kernel_matrix(s_kernel_matrix'low + 1 to s_kernel_matrix'high) <= s_kernel_matrix(s_kernel_matrix'LOW TO s_kernel_matrix'HIGH - 1);

				-- Shift full delay line by one
				s_full_delay(s_full_delay'low + 1 to s_full_delay'high) <= s_full_delay(s_full_delay'LOW TO s_full_delay'HIGH - 1);
			END IF;
		END IF;

	END PROCESS BUFFER_PROC;

	-- set current pixel to start of pipeline
	s_kernel_matrix(s_kernel_matrix'low)(0) <= i_pixel_stream;

	-- Map full signal of last FIFO to full delay line
	s_full_delay(s_full_delay'low) <= s_line_buffer_wr_en(s_line_buffer_wr_en'HIGH);

	-- only G_KERNEL_SIZE - 1 many line_buffer need to be created

	LINE_BUFFER_GEN : FOR j IN 0 TO G_KERNEL_SIZE - 2 GENERATE

		LINE_BUFF : ENTITY work.line_buffer
			GENERIC MAP (
				G_BIT_WIDTH => G_BIT_WIDTH,
				-- unga-bunga -1 to solve the timing problem
				-- (I don't think you can solve this differently with BRAM blocks and without considerable amount of HW)
				G_DEPTH => G_INPUT_WIDTH - 1
			)
			PORT MAP (
				clk                   => clk,
				rst                   => rst,
				i_en                  => i_en,
				i_wr_en               => s_line_buffer_wr_en(j),
				o_full                => open,
				o_full_read_and_write => s_line_buffer_wr_en(j + 1),
				i_din                 => s_kernel_matrix(s_kernel_matrix'low)(j),
				o_dout                => s_kernel_matrix(s_kernel_matrix'low)(j + 1)
			);

	END GENERATE LINE_BUFFER_GEN;

	-- Mirror output elements in x and y direction and write them to output
	-- Assumption is kernel is quadratic (which it always should be regardless)
	-- s_kernel_matrix(x + 1) is the column that used to be s_kernel_activations(x)

	Y_GEN : FOR y IN 0 TO G_KERNEL_SIZE - 1 GENERATE

		X_GEN : FOR x IN 0 TO G_KERNEL_SIZE - 1 GENERATE

			o_kernel_activations(((G_KERNEL_SIZE - 1 - y) * G_KERNEL_SIZE + G_KERNEL_SIZE - x) * G_BIT_WIDTH - 1 downto
			((G_KERNEL_SIZE - 1 - y) * G_KERNEL_SIZE + G_KERNEL_SIZE - 1 - x) * G_BIT_WIDTH) <= s_kernel_matrix(x + 1)(y);

		END GENERATE X_GEN;

	END GENERATE Y_GEN;

	-- This is important so that Pooling and Convolution know when they have valid kernel
	o_init_complete <= s_full_delay(s_full_delay'HIGH);

END ARCHITECTURE rtl;
