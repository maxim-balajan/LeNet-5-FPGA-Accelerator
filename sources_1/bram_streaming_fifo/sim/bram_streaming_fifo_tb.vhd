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

ENTITY bram_streaming_fifo_tb IS
END ENTITY bram_streaming_fifo_tb;

ARCHITECTURE bench OF bram_streaming_fifo_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT vector_length : NATURAL := 8;
	CONSTANT depth         : NATURAL := 5;
	-- Ports
	SIGNAL clk         : STD_LOGIC                                    := '0';
	SIGNAL rst         : STD_LOGIC;
	SIGNAL wr_en       : STD_LOGIC;
	SIGNAL rd_en       : STD_LOGIC;
	SIGNAL full        : STD_LOGIC;
	SIGNAL empty       : STD_LOGIC;
	SIGNAL wrap_around : STD_LOGIC;
	SIGNAL waiting     : STD_LOGIC;
	SIGNAL dout_valid  : STD_LOGIC;
	SIGNAL din         : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL dout        : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);

	SIGNAL s_sim_done : STD_LOGIC := '0';

	SIGNAL read_rst : STD_LOGIC := '0';

BEGIN

	bram_streaming_fifo_inst : ENTITY work.bram_streaming_fifo
		GENERIC MAP (
			G_BIT_WIDTH => vector_length,
			G_DEPTH     => depth
		)
		PORT MAP (
			clk          => clk,
			rst          => rst,
			i_read_reset => read_rst,
			i_wr_en      => wr_en,
			i_rd_en      => rd_en,
			o_full       => full,
			o_empty      => empty,
			o_dout_valid => dout_valid,
			i_din        => din,
			o_dout       => dout
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

	rst <= '1' AFTER 0 ns, '0' AFTER 10 ns,
	-- second part
	       '1' AFTER 140 ns, '0' AFTER 150 ns,
	-- third part
	       '1' AFTER 250 ns, '0' AFTER 260 ns;
	wr_en <= '0' AFTER 0 ns, '1' AFTER 10 ns, '0' AFTER 60 ns,
	-- second part
	         '1' AFTER 140 ns, '0' AFTER 200 ns,
	-- third part
	         '1' AFTER 290 ns, '0' AFTER 330 ns, '1' AFTER 390 ns, '0' AFTER 430 ns;
	rd_en <= '0' AFTER 0 ns, '1' AFTER 10 ns, '0' AFTER 80 ns, '1' AFTER 90 ns,
	-- second part
	         '0' AFTER 140 ns, '1' AFTER 170 ns,
	-- third part
	         '1' AFTER 260 ns, '0' AFTER 280 ns, '1' AFTER 350 ns, '0' AFTER 400 ns;

	STIM_PROC : PROCESS IS
	BEGIN

		WAIT FOR 10 ns;
		din <= std_logic_vector(unsigned(din) + 1);

	END PROCESS STIM_PROC;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 450 ns;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
