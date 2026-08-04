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

ENTITY matrix_vector_mem_interconnect_tb IS
END ENTITY matrix_vector_mem_interconnect_tb;

ARCHITECTURE bench OF matrix_vector_mem_interconnect_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT vector_length     : NATURAL := 8;
	CONSTANT max_weight_width  : NATURAL := 400;
	CONSTANT max_weight_height : NATURAL := 120;
	CONSTANT weight_width_0    : NATURAL := 400;
	CONSTANT weight_width_1    : NATURAL := 120;
	CONSTANT weight_width_2    : NATURAL := 84;
	CONSTANT weight_height_0   : NATURAL := 120;
	CONSTANT weight_height_1   : NATURAL := 84;
	CONSTANT weight_height_2   : NATURAL := 10;
	CONSTANT total_width       : NATURAL := weight_width_0 + weight_width_1 + weight_width_2;
	CONSTANT weight_prefix     : STRING  := "../data/output/dense_weights_row";
	-- Ports
	SIGNAL clk              : STD_LOGIC := '0';
	SIGNAL rst              : STD_LOGIC;
	SIGNAL bram_enable_line : STD_LOGIC_VECTOR(0 TO max_weight_height - 1);
	SIGNAL base_addr        : STD_LOGIC_VECTOR(integer(ceil(log2(real(total_width)))) - 1 DOWNTO 0);
	SIGNAL weights          : STD_LOGIC_VECTOR(max_weight_height * vector_length - 1 DOWNTO 0);

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	matrix_vector_mem_interconnect_inst : ENTITY work.matrix_vector_mem_interconnect
		GENERIC MAP (
			G_BIT_WIDTH          => vector_length,
			G_MAX_WEIGHT_WIDTH   => max_weight_width,
			G_MAX_WEIGHT_HEIGHT  => max_weight_height,
			G_WEIGHT_WIDTH_0     => weight_width_0,
			G_WEIGHT_WIDTH_1     => weight_width_1,
			G_WEIGHT_WIDTH_2     => weight_width_2,
			G_WEIGHT_PATH_PREFIX => weight_prefix
		)
		PORT MAP (
			clk                => clk,
			rst                => rst,
			i_bram_enable_line => bram_enable_line,
			i_base_addr        => base_addr,
			o_weights          => weights
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

	rst              <= '1' AFTER 0 ns, '0' AFTER 2 * clk_period;
	base_addr        <= (OTHERS => '0');
	bram_enable_line <= (OTHERS => '0');

	TB : PROCESS IS
	BEGIN

		WAIT FOR 20 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
