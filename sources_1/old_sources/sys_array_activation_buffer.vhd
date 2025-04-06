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

entity sys_array_activation_buffer is
	generic (
		input_width   : integer := 1;
		vector_length : integer := 8
	);
	port (
		clk               : in std_logic;
		reset             : in std_logic;
		en                : in std_logic;
		din               : in matrix_1d(0 to input_width - 1)(vector_length - 1 downto 0);
		result_activation : out std_logic_vector(vector_length - 1 downto 0)
	);
end entity sys_array_activation_buffer;

architecture rtl of sys_array_activation_buffer is

	-- notice the buffer has space for input_width + 1 elements
	-- this is to ensure a "0" element at the last index
	signal s_buffer            : matrix_1d(0 to input_width)(vector_length - 1 downto 0);
	signal s_read_id           : unsigned(integer(ceil(log2(real(input_width)))) downto 0);
	signal s_result_activation : std_logic_vector(result_activation'range);

begin

	READ_PROC : process (clk) is
	begin

		if rising_edge(clk) then
			if reset = '1' then
				s_buffer                       <= (others => (others => '0'));
				s_buffer(0 to input_width - 1) <= din;
				s_read_id                      <= (others => '0');
				s_result_activation            <= (others => '0');
			else
				if en = '1' then
					s_result_activation <= s_buffer(to_integer(s_read_id));
					-- if last element of s_buffer is reached the buffer is empty
					-- and should always return the "0" element
					if s_read_id /= input_width then
						s_read_id <= s_read_id + 1;
					end if;
				else
					-- if reading is not allowed return "0" as activation input
					s_result_activation <= (others => '0');
				end if;
			end if;
		end if;

	end process READ_PROC;

	result_activation <= s_result_activation;

end architecture rtl;
