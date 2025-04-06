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
----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/03/2024 04:41:02 PM
-- Design Name:
-- Module Name: max_pooling - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.libmatrix.all;

entity max_pooling is
	-- TODO add assertions for variable
	generic (
		number_width : natural := 8;
		width        : natural := 2;
		height       : natural := 2;
		channels     : natural := 2;
		--! kernel_size is required to be square
		kernel_size : natural := 2
	);
	port (
		clk      : in std_logic;
		reset    : in std_logic;
		en       : in std_logic;
		input    : in matrix_3d(0 to channels - 1)(0 to width - 1)(0 to height - 1)(number_width - 1 downto 0);
		output   : out matrix_3d(0 to channels - 1)(0 to width / kernel_size - 1)(0 to height / kernel_size - 1)(number_width - 1 downto 0);
		finished : out std_logic
	);
end entity max_pooling;

architecture Behavioral of max_pooling is

	signal s_finished         : std_logic_vector(0 to channels * (width / kernel_size) * (height / kernel_size) - 1);
	signal s_output           : matrix_3d(0 to channels - 1)(0 to width / kernel_size - 1)(0 to height / kernel_size - 1)(number_width - 1 downto 0);
	signal s_en               : std_logic;

begin

	MAIN_PROCESS : process (clk) is
	begin

		if rising_edge(clk) then
			if reset = '1' then
				s_en <= '0';
			else
				s_en <= en;
			end if;
		end if;

	end process MAIN_PROCESS;

	gen_outputs : for x in 0 to (width / kernel_size) - 1 generate

		gen_outputs2 : for y in 0 to (height / kernel_size) - 1 generate

			gen_outputs3 : for channel in 0 to channels - 1 generate

				max_pooling_kernel_inst : entity work.max_pooling_kernel
					generic map (
						number_width => number_width,
						width        => width,
						height       => height,
						kernel_size  => kernel_size,
						x            => x,
						y            => y
					)
					port map (
						clk      => clk,
						reset    => reset,
						en       => s_en,
						input    => input(channel),
						output   => s_output(channel)(x)(y),
						finished => s_finished(channel * (width / kernel_size) * (height / kernel_size) + x * (height / kernel_size) + y)
					);

			end generate gen_outputs3;

		end generate gen_outputs2;

	end generate gen_outputs;

	finished <= and s_finished;
	output   <= s_output;

end architecture Behavioral;
