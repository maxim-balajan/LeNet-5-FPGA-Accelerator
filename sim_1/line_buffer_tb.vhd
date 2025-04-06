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

entity line_buffer_tb is
end entity line_buffer_tb;

architecture bench of line_buffer_tb is

	-- Clock period
	constant clk_period : time := 10 ns;
	-- Generics
	constant vector_length : integer := 8;
	constant depth         : integer := 5;
	-- Ports
	signal clk   : std_logic := '0';
	signal reset : std_logic;
	signal wr_en : std_logic;
	signal full  : std_logic;
	signal din   : std_logic_vector(vector_length - 1 downto 0);
	signal dout  : std_logic_vector(vector_length - 1 downto 0);

begin

	line_buffer_inst : entity work.line_buffer
		generic map (
			vector_length => vector_length,
			depth         => depth
		)
		port map (
			clk   => clk,
			reset => reset,
			en    => '1',
			wr_en => wr_en,
			full  => full,
			din   => din,
			dout  => dout
		);

	clk   <= not clk after clk_period / 2;
	reset <= '1' after 0 ns, '0' after 10 ns;
	wr_en <= '1' after 0 ns;

	din <= x"00" after 0 ns, x"01" after 10 ns, x"02" after 20 ns, x"03" after 30 ns, x"04" after 40 ns, x"05" after 50 ns,
	       x"06" after 60 ns, x"07" after 70 ns;

	TB : process is
	begin

		wait for 90 ns;
		finish;

	end process TB;

end architecture bench;
