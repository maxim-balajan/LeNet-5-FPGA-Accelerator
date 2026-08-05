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
USE STD.TEXTIO.ALL;

--! Helper functions for the data files of the accelerator.
--!
--! The weights themselves are no longer sliced here. data/generate_bram_data.py writes
--! one ready to use file per BRAM tile into data/output, and every tile simply reads its
--! own file. This package only keeps what is not a memory: the per-layer scale values,
--! the plain file reader used by the test benches, and the helper that builds the file
--! name of a generated BRAM tile.

PACKAGE libmemory IS

	--! Builds the file name of one generated BRAM tile, for example
	--! bram_path("../data/output/dense_weights_row", 7) is
	--! "../data/output/dense_weights_row007.data".
	--! Has to stay pure so that it can be used inside a generic map.

	FUNCTION bram_path (
		prefix : IN string;
		index  : IN natural
	) RETURN string;

	--! Reads one hex line and returns it as a vector of G_BIT_WIDTH bits.

	FUNCTION hex_line_to_slv (
		file_line     : IN string;
		vector_length : IN natural
	) RETURN std_logic_vector;

	--! Reads depth lines and packs them into one flat vector.
	--! Element i occupies the bits ((i + 1) * G_BIT_WIDTH - 1 downto i * G_BIT_WIDTH).

	IMPURE FUNCTION init_from_file (
		file_name     : IN string;
		vector_length : IN natural;
		depth         : IN natural;
		bit_width	  : IN natural
	) RETURN std_logic_vector;

	--! Reads the scale value stored in line G_SCALE_ID (1 based) and zero extends it.

	IMPURE FUNCTION read_scale_value (
		file_name     : IN string;
		vector_length : IN natural;
		scale_length  : IN natural;
		current_scale : IN natural;
		bit_width	  : IN natural
	) RETURN std_logic_vector;

END PACKAGE libmemory;

PACKAGE BODY libmemory IS

	FUNCTION bram_path (
		prefix : IN string;
		index  : IN natural
	) RETURN string IS

		-- the generator pads the index to three digits
		VARIABLE v_digits : STRING(1 TO 3);
		VARIABLE v_value  : NATURAL := index;

	BEGIN

		FOR i IN 3 DOWNTO 1 LOOP

			v_digits(i) := character'VAL(character'POS('0') + (v_value mod 10));
			v_value     := v_value / 10;

		END LOOP;

		RETURN prefix & v_digits & ".data";

	END FUNCTION bram_path;

	FUNCTION hex_line_to_slv (
		file_line     : IN string;
		vector_length : IN natural
	) RETURN std_logic_vector IS

		VARIABLE v_value  : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0) := (OTHERS => '0');
		VARIABLE v_nibble : STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE v_char   : CHARACTER;
		VARIABLE v_digit  : INTEGER;

	BEGIN

		FOR i IN file_line'RANGE LOOP

			v_char := file_line(i);

			IF v_char >= '0' AND v_char <= '9' THEN
				v_digit := character'POS(v_char) - character'POS('0');
			ELSIF v_char >= 'A' AND v_char <= 'F' THEN
				v_digit := 10 + character'POS(v_char) - character'POS('A');
			ELSIF v_char >= 'a' AND v_char <= 'f' THEN
				v_digit := 10 + character'POS(v_char) - character'POS('a');
			ELSE
				-- end of the hex number, everything that follows is whitespace
				EXIT;
			END IF;

			v_nibble := std_logic_vector(to_unsigned(v_digit, 4));

			IF vector_length > 4 THEN
				v_value := v_value(vector_length - 5 DOWNTO 0) & v_nibble;
			ELSE
				v_value := v_nibble(vector_length - 1 DOWNTO 0);
			END IF;

		END LOOP;

		RETURN v_value;

	END FUNCTION hex_line_to_slv;

	IMPURE FUNCTION init_from_file (
		file_name     : IN string;
		vector_length : IN natural;
		depth         : IN natural;
		bit_width	  : IN natural
	) RETURN std_logic_vector IS

		FILE     mem_file    : TEXT OPEN READ_MODE IS file_name;
		VARIABLE v_file_line : LINE;
		VARIABLE v_str_line  : STRING(1 to bit_width / 4);
		VARIABLE v_tmp_ram   : STD_LOGIC_VECTOR(depth * vector_length - 1 DOWNTO 0) := (OTHERS => '0');

	BEGIN

		FOR i IN 0 TO depth - 1 LOOP

			EXIT WHEN endfile(mem_file);
			readline(mem_file, v_file_line);

			v_str_line := (OTHERS => ' ');
			read(v_file_line, v_str_line(1 to v_file_line'length));
			v_tmp_ram((i + 1) * vector_length - 1 downto i * vector_length) := hex_line_to_slv(v_str_line, vector_length);

		END LOOP;

		RETURN v_tmp_ram;

	END FUNCTION init_from_file;

	IMPURE FUNCTION read_scale_value (
		file_name     : IN string;
		vector_length : IN natural;
		scale_length  : IN natural;
		current_scale : IN natural;
		bit_width	 : IN natural
	) RETURN std_logic_vector IS

		FILE     mem_file    : TEXT OPEN READ_MODE IS file_name;
		VARIABLE v_file_line : LINE;
		VARIABLE v_str_line  : STRING(1 to bit_width / 4);
		VARIABLE v_value     : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0) := (OTHERS => '0');

	BEGIN

		-- Read until the desired line, the last one read is the one of interest
		FOR i IN 0 TO current_scale - 1 LOOP

			EXIT WHEN endfile(mem_file);
			readline(mem_file, v_file_line);

		END LOOP;

		v_str_line := (OTHERS => ' ');
		read(v_file_line, v_str_line(1 to v_file_line'length));

		v_value(scale_length - 1 downto 0) := hex_line_to_slv(v_str_line, scale_length);

		RETURN v_value;

	END FUNCTION read_scale_value;

END PACKAGE BODY libmemory;
