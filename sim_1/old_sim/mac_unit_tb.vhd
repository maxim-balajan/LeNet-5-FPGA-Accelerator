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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity mac_unit_tb is
end entity mac_unit_tb;

architecture bench of mac_unit_tb is

	-- Clock period
	constant clk_period : time := 10 ns;
	-- Generics
	constant vector_length : integer := 8;
	-- Ports
	signal clk            : std_logic := '0';
	signal reset          : std_logic;
	signal valid          : std_logic;
	signal input_vector   : std_logic_vector(vector_length - 1 downto 0);
	signal weight_vector  : std_logic_vector(vector_length - 1 downto 0);
	signal partial_sum    : std_logic_vector(3 * vector_length - 1 downto 0);
	signal input_delay    : std_logic_vector(vector_length - 1 downto 0);
	signal partial_result : std_logic_vector(3 * vector_length - 1 downto 0);

begin

	mac_unit_inst : entity work.mac_unit
		generic map (
			vector_length => vector_length
		)
		port map (
			clk            => clk,
			reset          => reset,
			valid          => valid,
			input_vector   => input_vector,
			weight_vector  => weight_vector,
			partial_sum    => partial_sum,
			valid_delay    => open,
			input_delay    => input_delay,
			partial_result => partial_result
		);

	clk <= not clk after clk_period / 2;

	valid         <= '1';
	reset         <= '1' after 0 ns, '0' after 10 ns;
	input_vector  <= x"08" after 0 ns, x"FF" after 20 ns;
	weight_vector <= x"06" after 0 ns, x"0A" after 20 ns;
	partial_sum   <= x"000020" after 0 ns, x"00000F" after 20 ns;

	clk_process : process is
	begin

		wait for 40 ns;
		finish;

	end process clk_process;

end architecture bench;
