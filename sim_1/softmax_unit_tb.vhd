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
use std.env.finish;

entity softmax_unit_tb is
end entity softmax_unit_tb;

architecture bench of softmax_unit_tb is

	-- Clock period
	constant clk_period : time := 5 ns;
	-- Generics
	constant input_length : natural := 8;
	constant input_amount : natural := 10;
	-- Ports
	signal clk           : std_logic := '0';
	signal reset         : std_logic;
	signal en            : std_logic;
	signal input         : matrix_1d(0 to input_amount - 1)(input_length - 1 downto 0);
	signal max_index     : std_logic_vector(integer(ceil(log2(real(input_amount)))) - 1 downto 0);
	signal comp_complete : std_logic;

begin

	softmax_unit_inst : entity work.softmax_unit
		generic map (
			input_length => input_length,
			input_amount => input_amount
		)
		port map (
			clk           => clk,
			reset         => reset,
			en            => en,
			input         => input,
			max_index     => max_index,
			comp_complete => comp_complete
		);

	clk   <= not clk after clk_period / 2;
	reset <= '1' after 0 ns, '0' after 2 * clk_period;
	input <= ("10101101", "10101010", "11101010", "10000000", "11011010", "10001010", "10010000", "10101010", "11000000", "10110101");
	en    <= '1';

	TB : process is
	begin

		wait for 10 * clk_period;
		finish;

	end process TB;

end architecture bench;
