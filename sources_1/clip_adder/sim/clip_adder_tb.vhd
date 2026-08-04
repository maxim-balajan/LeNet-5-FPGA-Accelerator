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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY clip_adder_tb IS
END ENTITY clip_adder_tb;

ARCHITECTURE bench OF clip_adder_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 5 ns;
	-- Generics
	CONSTANT vector_length : NATURAL := 8;
	-- Ports
	SIGNAL din0 : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL din1 : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL dout : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	clip_adder_inst : ENTITY work.clip_adder
		GENERIC MAP (
			G_BIT_WIDTH => vector_length
		)
		PORT MAP (
			i_din0 => din0,
			i_din1 => din1,
			o_dout => dout
		);

	din0 <= x"05" AFTER 0 ns, x"7F" AFTER clk_period, x"80" AFTER 2 * clk_period, x"FF"  AFTER 3 * clk_period;
	din1 <= x"20" AFTER 0 ns, x"05" AFTER clk_period, x"FC" AFTER 2 * clk_period, x"7F" AFTER 3 * clk_period;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 4 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
