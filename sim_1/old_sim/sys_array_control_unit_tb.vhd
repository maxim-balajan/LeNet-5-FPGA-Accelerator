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

entity sys_array_control_unit_tb is
end entity sys_array_control_unit_tb;

architecture bench of sys_array_control_unit_tb is

	-- Clock period
	constant clk_period : time := 5 ns;
	-- Generics
	constant weight_width  : integer := 4;
	constant weight_height : integer := 5;
	constant input_width   : integer := 6;
	-- Ports
	signal clk         : std_logic := '1';
	signal reset       : std_logic;
	signal enable_bits : std_logic_vector(maximum(weight_width, weight_height) - 1 downto 0);

begin

	sys_array_control_unit_inst : entity work.sys_array_control_unit
		generic map (
			weight_width  => weight_width,
			weight_height => weight_height,
			input_width   => input_width
		)
		port map (
			clk         => clk,
			reset       => reset,
			enable_bits => enable_bits
		);

	clk   <= not clk after clk_period / 2;
	reset <= '1' after 0 ns, '0' after 1.5 * clk_period;

	TB : process is
	begin

		wait for 13 * clk_period;
		finish;

	end process TB;

end architecture bench;
