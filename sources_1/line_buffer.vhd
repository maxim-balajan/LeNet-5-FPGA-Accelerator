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
use ieee.math_real.all;
use work.libmatrix.all;

entity line_buffer is
	generic (
		vector_length : natural := 8;
		depth         : natural := 32
	);
	port (
		clk                 : in std_logic;
		reset               : in std_logic;
		en                  : in std_logic;
		wr_en               : in std_logic;
		full                : out std_logic; -- this signal can be omitted but is here for legacy purposes
		full_read_and_write : out std_logic; -- this signal is necessary in order to start writing to next line_bufers
		din                 : in std_logic_vector(vector_length - 1 downto 0);
		dout                : out std_logic_vector(vector_length - 1 downto 0)
	);
end entity line_buffer;

architecture rtl of line_buffer is

	signal s_rd_en : std_logic;

begin

	full <= s_rd_en;

	-- this process is neccessary to delay next write signal for upcoming line_buffer
	process (clk) is
	begin

		if rising_edge(clk) then
			if reset = '1' then
				full_read_and_write <= '0';
			elsif en = '1' then
				full_read_and_write <= full and wr_en;
			end if;
		end if;

	end process;

	FIFO_INST : entity work.bram_fifo
		generic map (
			vector_length => vector_length,
			depth         => depth
		)
		port map (
			clk   => clk,
			reset => reset,
			wr_en => wr_en and en,
			rd_en => s_rd_en and en,
			full  => s_rd_en,
			empty => open,
			din   => din,
			dout  => dout
		);

end architecture rtl;
