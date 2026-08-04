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

ENTITY line_buffer_tb IS
END ENTITY line_buffer_tb;

ARCHITECTURE bench OF line_buffer_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT vector_length : INTEGER := 8;
	CONSTANT depth         : INTEGER := 5;
	-- Ports
	SIGNAL clk   : STD_LOGIC := '0';
	SIGNAL rst   : STD_LOGIC;
	SIGNAL wr_en : STD_LOGIC;
	SIGNAL full  : STD_LOGIC;
	SIGNAL din   : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL dout  : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	line_buffer_inst : ENTITY work.line_buffer
		GENERIC MAP (
			G_BIT_WIDTH => vector_length,
			G_DEPTH     => depth
		)
		PORT MAP (
			clk     => clk,
			rst     => rst,
			i_en    => '1',
			i_wr_en => wr_en,
			o_full  => full,
			i_din   => din,
			o_dout  => dout
		);

	CLK_PROC : PROCESS IS
	BEGIN

		WHILE s_sim_done = '0' LOOP

			clk <= '0';
			WAIT FOR clk_period / 2;
			clk <= '1';
			WAIT FOR clk_period / 2;

		END LOOP;

		WAIT;

	END PROCESS CLK_PROC;

	rst   <= '1' AFTER 0 ns, '0' AFTER 10 ns;
	wr_en <= '1' AFTER 0 ns;

	din <= x"00" AFTER 0 ns, x"01" AFTER 10 ns, x"02" AFTER 20 ns, x"03" AFTER 30 ns, x"04" AFTER 40 ns, x"05" AFTER 50 ns,
	       x"06" AFTER 60 ns, x"07" AFTER 70 ns;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 90 ns;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
