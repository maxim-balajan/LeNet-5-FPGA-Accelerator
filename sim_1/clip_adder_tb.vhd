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

entity clip_adder_tb is
end entity clip_adder_tb;

architecture bench of clip_adder_tb is

	-- Clock period
	constant clk_period : time := 5 ns;
	-- Generics
	constant vector_length : natural := 8;
	-- Ports
	signal din0 : std_logic_vector(vector_length - 1 downto 0);
	signal din1 : std_logic_vector(vector_length - 1 downto 0);
	signal dout : std_logic_vector(vector_length - 1 downto 0);

begin

	clip_adder_inst : entity work.clip_adder
		generic map (
			vector_length => vector_length
		)
		port map (
			din0 => din0,
			din1 => din1,
			dout => dout
		);

	din0 <= x"05" after 0 ns, x"7F" after clk_period, x"80" after 2 * clk_period, x"FF"  after 3 * clk_period;
	din1 <= x"20" after 0 ns, x"05" after clk_period, x"FC" after 2 * clk_period, x"7F" after 3 * clk_period;

	TB : process is
	begin

		wait for 4 * clk_period;
		finish;

	end process TB;

end architecture bench;
