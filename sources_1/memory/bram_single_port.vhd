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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ALL;
USE STD.TEXTIO.ALL;

ENTITY bram_single_port IS
	GENERIC (
		G_BIT_WIDTH      : NATURAL;
		G_DEPTH          : NATURAL;
		G_DATA_FILE_PATH : STRING
	);
	PORT (
		clk     : IN STD_LOGIC;
		i_rd_en : IN STD_LOGIC;
		i_wr_en : IN STD_LOGIC;
		i_addr  : IN STD_LOGIC_VECTOR(integer(ceil(log2(real(G_DEPTH)))) - 1 DOWNTO 0);
		i_din   : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_dout  : OUT STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0)
	);
END ENTITY bram_single_port;

ARCHITECTURE behavioral OF bram_single_port IS

	--------------------------------------------------------
	-- TYPEs
	--------------------------------------------------------

	TYPE t_ram IS ARRAY (0 TO G_DEPTH - 1) OF STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

	--------------------------------------------------------
	-- FUNCTIONs
	--------------------------------------------------------

	IMPURE FUNCTION f_init_from_file (
		file_name     : IN STRING
	) RETURN t_ram IS

		FILE     mem_file    : TEXT OPEN READ_MODE IS file_name;
		VARIABLE v_file_line : LINE;
		VARIABLE v_tmp_ram   : t_ram;
		VARIABLE hex_string  : STRING(1 TO integer(ceil(real(G_BIT_WIDTH) / 4.0)));
		VARIABLE hval        : INTEGER;

	BEGIN

		FOR i IN v_tmp_ram'RANGE LOOP

			readline(mem_file, v_file_line);

			read(v_file_line, hex_string);

			-- convert string hex to integer
			hval := 0;

			FOR j IN hex_string'RANGE LOOP

				hval := hval * 16;

				IF hex_string(j) >= '0' AND hex_string(j) <= '9' THEN
					hval := hval + character'POS(hex_string(j)) - character'POS('0');
				ELSIF hex_string(j) >= 'A' AND hex_string(j) <= 'F' THEN
					hval := hval + 10 + character'POS(hex_string(j)) - character'POS('A');
				ELSIF hex_string(j) >= 'a' AND hex_string(j) <= 'f' THEN
					hval := hval + 10 + character'POS(hex_string(j)) - character'POS('a');
				ELSE
					REPORT "Invalid hex character"
						SEVERITY failure;
				END IF;

			END LOOP;

			-- assign to ram element
			v_tmp_ram(i) := std_logic_vector(to_unsigned(hval, v_tmp_ram(i)'LENGTH));

		END LOOP;

		RETURN v_tmp_ram;

	END FUNCTION f_init_from_file;

	--------------------------------------------------------
	-- SIGNALs
	--------------------------------------------------------

	SHARED VARIABLE sv_RAM : t_ram := f_init_from_file(G_DATA_FILE_PATH);

BEGIN

	-- Definition r port
	PORT_R : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF i_rd_en = '1' THEN
				IF i_wr_en = '1' THEN
					sv_RAM(to_integer(unsigned(i_addr))) := i_din;
				END IF;
				o_dout <= sv_RAM(to_integer(unsigned(i_addr)));
			END IF;
		END IF;

	END PROCESS PORT_R;

END ARCHITECTURE behavioral;
