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

----------------------------------------------------------------------------------
-- FIFO that buffers one complete input channel and can replay it.
-- offers the read_reset behaviour that conv_seq needs to stream a stored channel
-- again for every output channel.
----------------------------------------------------------------------------------

ENTITY bram_streaming_fifo IS
	GENERIC (
		G_BIT_WIDTH : NATURAL := 8;
		G_DEPTH     : NATURAL := 28
	);
	PORT (
		clk          : IN STD_LOGIC;
		rst          : IN STD_LOGIC;
		i_read_reset : IN STD_LOGIC;
		i_wr_en      : IN STD_LOGIC;
		i_rd_en      : IN STD_LOGIC;
		o_full       : OUT STD_LOGIC;
		o_empty      : OUT STD_LOGIC;
		i_din        : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_dout       : OUT STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_dout_valid : OUT STD_LOGIC
	);
END ENTITY bram_streaming_fifo;

ARCHITECTURE rtl OF bram_streaming_fifo IS

	TYPE t_ram IS ARRAY(0 TO G_DEPTH - 1) OF STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

	SIGNAL s_ram : t_ram;
	ATTRIBUTE ram_style : STRING;
	ATTRIBUTE ram_style OF s_ram : signal IS "block";

	-- Read and write pointers to the memory
	SIGNAL s_read_pointer  : UNSIGNED(integer(ceil(log2(real(G_DEPTH)))) DOWNTO 0);
	SIGNAL s_write_pointer : UNSIGNED(integer(ceil(log2(real(G_DEPTH)))) DOWNTO 0);

	SIGNAL s_empty : STD_LOGIC;
	SIGNAL s_full  : STD_LOGIC;

	SIGNAL s_pointer_equal : STD_LOGIC;

	SIGNAL s_last_write : STD_LOGIC;
	SIGNAL s_dout       : STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_dout_valid : STD_LOGIC;

BEGIN

	s_pointer_equal <= '1' WHEN s_read_pointer = s_write_pointer ELSE '0';

	s_empty <= s_pointer_equal AND not s_last_write;
	s_full  <= s_pointer_equal AND s_last_write;

	o_empty <= s_empty;
	o_full  <= s_full;

	o_dout       <= s_dout;
	o_dout_valid <= s_dout_valid;

	FIFO_PROC : PROCESS (clk, rst) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_read_pointer  <= (OTHERS => '0');
				s_write_pointer <= (OTHERS => '0');
				s_last_write    <= '0';
				s_dout          <= (OTHERS => '0');
				s_dout_valid    <= '0';
			ELSE
				-- only accept read_resets if the fifo is already filled
				-- this resets the read pointer but does not affect the write pointer
				IF i_read_reset = '1' AND s_write_pointer = G_DEPTH THEN
					s_read_pointer <= (OTHERS => '0');
					s_last_write   <= '1';
					s_dout         <= (OTHERS => '0');
					s_dout_valid   <= '0';
				ELSE
					-- Reset of last write value and dout_valid and put on them 0 for now
					s_last_write <= '0';
					s_dout_valid <= '0';
					IF i_rd_en = '1' AND s_empty = '0' THEN
						-- Read from memory
						s_dout       <= s_ram(to_integer(s_read_pointer));
						s_dout_valid <= '1';

						-- If last value has been read, don't increment pointer so that in coming cycles read is blocked via empty signal
						IF s_read_pointer /= G_DEPTH THEN
							s_read_pointer <= s_read_pointer + 1;
						END IF;
					END IF;
					-- Only accept writes if there is still place inside the fifo
					IF s_write_pointer /= G_DEPTH THEN
						IF i_wr_en = '1' AND (s_full = '0' OR i_rd_en = '1') THEN
							s_last_write <= '1';
							-- Write to memory
							s_ram(to_integer(s_write_pointer)) <= i_din;

							s_write_pointer <= s_write_pointer + 1;
						END IF;
					END IF;
					-- If neither read nor wright was performed, hold old state and overwrite initial rst statement
					IF not (i_rd_en = '1' AND s_empty = '0') AND not (s_write_pointer /= G_DEPTH AND i_wr_en = '1' AND (s_full = '0' OR i_rd_en = '1')) THEN
						s_last_write <= s_last_write;
					END IF;
				END IF;
			END IF;
		END IF;

	END PROCESS FIFO_PROC;

END ARCHITECTURE rtl;
