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

entity bram_streaming_fifo_tb is
end entity bram_streaming_fifo_tb;

architecture bench of bram_streaming_fifo_tb is

	-- Clock period
	constant clk_period : time := 10 ns;
	-- Generics
	constant vector_length : natural := 8;
	constant depth         : natural := 5;
	-- Ports
	signal clk         : std_logic                                    := '0';
	signal reset       : std_logic;
	signal wr_en       : std_logic;
	signal rd_en       : std_logic;
	signal full        : std_logic;
	signal empty       : std_logic;
	signal wrap_around : std_logic;
	signal waiting     : std_logic;
	signal dout_valid  : std_logic;
	signal din         : std_logic_vector(vector_length - 1 downto 0) := (others => '0');
	signal dout        : std_logic_vector(vector_length - 1 downto 0);

begin

	bram_streaming_fifo_inst : entity work.bram_streaming_fifo
		generic map (
			vector_length => vector_length,
			depth         => depth
		)
		port map (
			clk         => clk,
			reset       => reset,
			wr_en       => wr_en,
			rd_en       => rd_en,
			full        => full,
			empty       => empty,
			wrap_around => wrap_around,
			waiting     => waiting,
			dout_valid  => dout_valid,
			din         => din,
			dout        => dout
		);

	clk   <= not clk after clk_period / 2;
	reset <= '1' after 0 ns, '0' after 10 ns,
	-- second part
	         '1' after 140 ns, '0' after 150 ns,
	-- third part
	         '1' after 250 ns, '0' after 260 ns;
	wr_en <= '0' after 0 ns, '1' after 10 ns, '0' after 60 ns,
	-- second part
	         '1' after 140 ns, '0' after 200 ns,
	-- third part
	         '1' after 290 ns, '0' after 330 ns, '1' after 390 ns, '0' after 430 ns;
	rd_en <= '0' after 0 ns, '1' after 10 ns, '0' after 80 ns, '1' after 90 ns,
	-- second part
	         '0' after 140 ns, '1' after 170 ns,
	-- third part
	         '1' after 260 ns, '0' after 280 ns, '1' after 350 ns, '0' after 400 ns;

	process is
	begin

		wait for 10 ns;
		din <= std_logic_vector(unsigned(din) + 1);

	end process;

	TB : process is
	begin

		wait for 450 ns;
		finish;

	end process TB;

end architecture bench;
