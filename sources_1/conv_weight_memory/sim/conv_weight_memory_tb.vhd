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

--! Instantiates the weight memory of every channel of both convolutions and lets each of
--! them copy its weights out of its own generated BRAM file.

ENTITY conv_weight_memory_tb IS
END ENTITY conv_weight_memory_tb;

ARCHITECTURE bench OF conv_weight_memory_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT vector_length : NATURAL := 8;
	CONSTANT kernel_size   : NATURAL := 5;
	CONSTANT input_amount  : NATURAL := kernel_size ** 2;

	-- the first convolution holds one kernel per output channel, the second one holds
	-- one kernel per output channel for its own input channel
	CONSTANT channel_amount : NATURAL := 6;
	CONSTANT depth_1        : NATURAL := input_amount;
	CONSTANT depth_2        : NATURAL := input_amount * 16;

	CONSTANT weight_prefix_1 : STRING := "../data/output/conv_1_weights_ch";
	CONSTANT weight_prefix_2 : STRING := "../data/output/conv_2_weights_ch";

	CONSTANT addr_width_1 : NATURAL := integer(ceil(log2(real(depth_1))));
	CONSTANT addr_width_2 : NATURAL := integer(ceil(log2(real(depth_2))));

	-- Ports
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC;

	SIGNAL base_addr_1 : STD_LOGIC_VECTOR(addr_width_1 - 1 DOWNTO 0) := (OTHERS => '0');
	-- the second convolution starts at the second output channel to check the offset
	SIGNAL base_addr_2 : STD_LOGIC_VECTOR(addr_width_2 - 1 DOWNTO 0) := std_logic_vector(to_unsigned(input_amount, addr_width_2));

	TYPE t_weights IS ARRAY(0 TO channel_amount - 1) OF STD_LOGIC_VECTOR(input_amount * vector_length - 1 DOWNTO 0);

	SIGNAL weights_first_conv  : t_weights;
	SIGNAL weights_second_conv : t_weights;

	SIGNAL mem_valid_1 : STD_LOGIC_VECTOR(1 TO channel_amount);
	SIGNAL mem_valid_2 : STD_LOGIC_VECTOR(1 TO channel_amount);

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	FIRST_CONV_MEMORYS : FOR i IN 1 TO channel_amount GENERATE

		conv_weight_memory_inst : ENTITY work.conv_weight_memory
			GENERIC MAP (
				G_BIT_WIDTH      => vector_length,
				G_INPUT_AMOUNT   => input_amount,
				G_DEPTH          => depth_1,
				G_DATA_FILE_PATH => bram_path(weight_prefix_1, i - 1)
			)
			PORT MAP (
				clk         => clk,
				rst         => rst,
				i_base_addr => base_addr_1,
				o_mem_valid => mem_valid_1(i),
				o_weights   => weights_first_conv(i - 1)
			);

	END GENERATE FIRST_CONV_MEMORYS;

	SECOND_CONV_MEMORYS : FOR i IN 1 TO channel_amount GENERATE

		conv_weight_memory_inst : ENTITY work.conv_weight_memory
			GENERIC MAP (
				G_BIT_WIDTH      => vector_length,
				G_INPUT_AMOUNT   => input_amount,
				G_DEPTH          => depth_2,
				G_DATA_FILE_PATH => bram_path(weight_prefix_2, i - 1)
			)
			PORT MAP (
				clk         => clk,
				rst         => rst,
				i_base_addr => base_addr_2,
				o_mem_valid => mem_valid_2(i),
				o_weights   => weights_second_conv(i - 1)
			);

	END GENERATE SECOND_CONV_MEMORYS;

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

	rst <= '1' AFTER 0 ns, '0' AFTER clk_period;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 40 * clk_period;

		-- every memory has to be done copying its weights into the registers by now
		FOR i IN 1 TO channel_amount LOOP

			ASSERT mem_valid_1(i) = '1'
				REPORT "first convolution memory " & integer'IMAGE(i) & " did not finish"
				SEVERITY failure;
			ASSERT mem_valid_2(i) = '1'
				REPORT "second convolution memory " & integer'IMAGE(i) & " did not finish"
				SEVERITY failure;

		END LOOP;

		REPORT "conv_weight_memory_tb PASSED";

		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
