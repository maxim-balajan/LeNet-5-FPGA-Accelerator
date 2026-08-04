------------------------------------------------------------------------------
-- SPDX-License-Identifier: GPL-3.0-only
--
-- A hardware accelerated exp2 calculation aimed for FPGAs.
--
-- Copyright (C) 2026 Maxim Balajan (maxim.balajan@fau.de)
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

ENTITY bram_fifo IS
	GENERIC (
		G_BIT_WIDTH       : NATURAL  := 8;
		G_MAX_DEPTH       : NATURAL  := 64;
		G_FULL_CL_AMOUNT  : POSITIVE := 1;
		G_EMPTY_CL_AMOUNT : POSITIVE := 1
	);
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		--
		i_set_full : IN STD_LOGIC                                                         := '0';
		i_depth    : IN STD_LOGIC_VECTOR(integer(ceil(log2(real(G_MAX_DEPTH)))) DOWNTO 0) := std_logic_vector(to_unsigned(G_MAX_DEPTH, 1 + integer(ceil(log2(real(G_MAX_DEPTH))))));
		--
		i_din   : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		i_wr_en : IN STD_LOGIC;
		i_rd_en : IN STD_LOGIC;
		--
		o_dout               : OUT STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_full_control_line  : OUT STD_LOGIC_VECTOR(G_FULL_CL_AMOUNT - 1 DOWNTO 0);
		o_empty_control_line : OUT STD_LOGIC_VECTOR(G_EMPTY_CL_AMOUNT - 1 DOWNTO 0)
	);
END ENTITY bram_fifo;

ARCHITECTURE rtl OF bram_fifo IS

	TYPE t_ram IS ARRAY(0 TO G_MAX_DEPTH - 1) OF STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

	-- Initialize RAM with 0s so that it works if set_full is set to '1' during rst
	SIGNAL RAM : t_ram := (OTHERS => (OTHERS => '0'));
	ATTRIBUTE ram_style : STRING;
	ATTRIBUTE ram_style OF RAM : signal IS "block";

	-- Register for storing the actual depth of FIFO
	SIGNAL s_actual_depth : UNSIGNED(integer(ceil(log2(real(G_MAX_DEPTH)))) DOWNTO 0);
	SIGNAL s_entry_amount : SIGNED(integer(ceil(log2(real(G_MAX_DEPTH)))) + 1 DOWNTO 0);
	-- This signal is used to write 0s for s_actual_depth many cycles if set_full = '1'
	-- This is to accommodate that BRAM can't be rst
	SIGNAL s_is_invalid : STD_LOGIC;

	-- Read and write pointers to the memory
	SIGNAL s_read_pointer  : UNSIGNED(integer(ceil(log2(real(G_MAX_DEPTH)))) DOWNTO 0);
	SIGNAL s_write_pointer : UNSIGNED(integer(ceil(log2(real(G_MAX_DEPTH)))) DOWNTO 0);

	SIGNAL s_empty_line : STD_LOGIC_VECTOR(G_EMPTY_CL_AMOUNT - 1 DOWNTO 0);
	SIGNAL s_full_line  : STD_LOGIC_VECTOR(G_FULL_CL_AMOUNT - 1 DOWNTO 0);

	SIGNAL s_last_write : STD_LOGIC;
	SIGNAL s_dout       : STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

BEGIN

	FULL_LINE_GEN : FOR i IN 0 TO G_FULL_CL_AMOUNT - 1 GENERATE
		s_full_line(i) <= '1' WHEN s_entry_amount >= (signed(resize(s_actual_depth, s_entry_amount'LENGTH)) - i) ELSE '0';
	END GENERATE FULL_LINE_GEN;

	EMPTY_LINE_GEN : FOR i IN 0 TO G_EMPTY_CL_AMOUNT - 1 GENERATE
		s_empty_line(i) <= '1' WHEN s_entry_amount <= i ELSE '0';
	END GENERATE EMPTY_LINE_GEN;

	o_dout               <= s_dout;
	o_full_control_line  <= s_full_line;
	o_empty_control_line <= s_empty_line;

	MEM_PROC : PROCESS (clk, rst) IS

		-- has to have the same width as s_entry_amount, otherwise the copy below fails
		VARIABLE v_entry_amount : SIGNED(integer(ceil(log2(real(G_MAX_DEPTH)))) + 1 DOWNTO 0);

	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_read_pointer  <= (OTHERS => '0');
				s_write_pointer <= (OTHERS => '0');
				-- When last_write is set to one, the fifo is flagged as "full" and only contains zeros
				s_last_write <= i_set_full;
				-- If s_is_invalid is set to '1', the first actual_depth read cycles are performed, but 0s are always returned
				s_is_invalid <= i_set_full;
				IF i_set_full = '1' THEN
					s_entry_amount(s_entry_amount'high)              <= '0';
					s_entry_amount(s_entry_amount'high - 1 downto 0) <= signed(i_depth);
				ELSE
					s_entry_amount <= (OTHERS => '0');
				END IF;
				s_actual_depth <= unsigned(i_depth);
				s_dout         <= (OTHERS => '0');
			ELSE
				-- Store entry amount in variable to subtract/add in one iteration
				v_entry_amount := s_entry_amount;
				-- Reset of last write value and put on it 0 for now
				s_last_write <= '0';
				-- Always write 0 even if no read was performed
				-- s_dout <= (others => '0');
				IF i_rd_en = '1' AND s_empty_line(s_empty_line'LOW) = '0' THEN
					-- Read from memory
					-- Only get the actual memory if reset_cycle has been completed
					IF s_is_invalid = '0' THEN
						s_dout <= RAM(to_integer(s_read_pointer));
					ELSE
						s_dout <= (OTHERS => '0');
					END IF;

					IF s_read_pointer /= s_actual_depth - 1 THEN
						s_read_pointer <= s_read_pointer + 1;
					ELSE
						-- all illegal values that came via set_full = '1' were now safely read
						s_is_invalid   <= '0';
						s_read_pointer <= (OTHERS => '0');
					END IF;
					v_entry_amount := v_entry_amount - 1;
				END IF;
				IF i_wr_en = '1' AND (s_full_line(s_full_line'LOW) = '0' OR i_rd_en = '1') THEN
					s_last_write <= '1';
					-- Write to memory
					RAM(to_integer(s_write_pointer)) <= i_din;

					IF s_write_pointer /= s_actual_depth - 1 THEN
						s_write_pointer <= s_write_pointer + 1;
					ELSE
						s_write_pointer <= (OTHERS => '0');
					END IF;

					v_entry_amount := v_entry_amount + 1;
				END IF;
				-- If neither read nor wright was performed, hold old state and overwrite initial rst statement
				IF not (i_rd_en = '1' AND s_empty_line(s_empty_line'LOW) = '0') AND not (i_wr_en = '1' AND (s_full_line(s_full_line'LOW) = '0' OR i_rd_en = '1')) THEN
					s_last_write <= s_last_write;
				END IF;
				-- Write entry amount variable back to take changes into effect
				s_entry_amount <= v_entry_amount;
			END IF;
		END IF;

	END PROCESS MEM_PROC;

END ARCHITECTURE rtl;

