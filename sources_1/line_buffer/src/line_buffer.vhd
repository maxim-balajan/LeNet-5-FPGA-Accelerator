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
USE ieee.math_real.ALL;

ENTITY line_buffer IS
	GENERIC (
		G_BIT_WIDTH : NATURAL := 8;
		G_DEPTH     : NATURAL := 32
	);
	PORT (
		clk                   : IN STD_LOGIC;
		rst                   : IN STD_LOGIC;
		i_en                  : IN STD_LOGIC;
		i_wr_en               : IN STD_LOGIC;
		o_full                : OUT STD_LOGIC; -- this signal can be omitted but is here for legacy purposes
		o_full_read_and_write : OUT STD_LOGIC; -- this signal is necessary in order to start writing to next line_bufers
		i_din                 : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_dout                : OUT STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0)
	);
END ENTITY line_buffer;

ARCHITECTURE rtl OF line_buffer IS

	SIGNAL s_rd_en : STD_LOGIC;
	SIGNAL s_wr_en : STD_LOGIC;

	SIGNAL s_full_line  : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL s_empty_line : STD_LOGIC_VECTOR(0 DOWNTO 0);

BEGIN

	-- the buffer may only advance while the slider is actually clocking a pixel through,
	-- otherwise it drains during the gaps between two valid pixels
	s_rd_en <= s_full_line(0) AND i_en;
	o_full  <= s_full_line(0);

	-- this process is neccessary to delay next write signal for upcoming line_buffer
	FULL_DELAY_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				o_full_read_and_write <= '0';
			ELSIF i_en = '1' THEN
				o_full_read_and_write <= s_full_line(0) AND i_wr_en;
			END IF;
		END IF;

	END PROCESS FULL_DELAY_PROC;

	s_wr_en <= i_wr_en AND i_en;

	FIFO_INST : ENTITY work.bram_fifo
		GENERIC MAP (
			G_BIT_WIDTH       => G_BIT_WIDTH,
			G_MAX_DEPTH       => G_DEPTH,
			G_FULL_CL_AMOUNT  => 1,
			G_EMPTY_CL_AMOUNT => 1
		)
		PORT MAP (
			clk => clk,
			rst => rst,
			--
			i_set_full => '0',
			i_depth    => open,
			--
			i_din   => i_din,
			i_wr_en => s_wr_en,
			i_rd_en => s_rd_en,
			--
			o_dout               => o_dout,
			o_full_control_line  => s_full_line,
			o_empty_control_line => s_empty_line
		);

END ARCHITECTURE rtl;
