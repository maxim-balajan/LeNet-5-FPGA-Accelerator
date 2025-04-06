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

entity sys_array_result_buffer is
	generic (
		input_width   : integer := 1;
		vector_length : integer := 8
	);
	port (
		clk           : in std_logic;
		reset         : in std_logic;
		en            : in std_logic;
		din           : in std_logic_vector(3 * vector_length - 1 downto 0);
		buffer_full   : out std_logic;
		result_buffer : out matrix_1d(0 to input_width - 1)(vector_length - 1 downto 0)
	);
end entity sys_array_result_buffer;

architecture rtl of sys_array_result_buffer is

	signal s_buffer   : matrix_1d(0 to input_width - 1)(vector_length - 1 downto 0);
	signal s_write_id : unsigned(integer(ceil(log2(real(input_width)))) downto 0);

begin

	WRITE_PROC : process (clk) is
	begin

		if rising_edge(clk) then
			if reset = '1' then
				s_buffer   <= (others => (others => '0'));
				s_write_id <= (others => '0');
			else
				if en = '1' then
					-- if buffer is full, do not take new elements into the buffer
					if to_integer(s_write_id) /= input_width then
						s_buffer(to_integer(s_write_id)) <= din(vector_length - 1 downto 0);
						s_write_id                       <= s_write_id + 1;
					end if;
				end if;
			end if;
		end if;

	end process WRITE_PROC;

	result_buffer <= s_buffer;
	-- write index reached oob value, thus buffer full
	buffer_full <= s_write_id ?= input_width;

end architecture rtl;
