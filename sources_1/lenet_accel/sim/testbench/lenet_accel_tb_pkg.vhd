------------------------------------------------------------------------------
-- SPDX-License-Identifier: GPL-3.0-only
--
-- A LeNet-5 inference accelerator aimed for FPGAs.
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

LIBRARY vunit_lib;
	CONTEXT vunit_lib.vunit_context;

LIBRARY osvvm;
	CONTEXT osvvm.OsvvmContext;
USE osvvm.RandomPkg.ALL;

LIBRARY tb_lib;
USE tb_lib.libmemory.ALL;

PACKAGE lenet_accel_tb_pkg IS

	GENERIC (
		G_BIT_WIDTH   : natural := 8;
		G_INPUT_WIDTH : natural := 32;
		G_INPUT_HEIGHT : natural := 32;
		G_LABEL_AMOUNT : natural := 10
	);

	----------------------------------------------------------------------
	-- CONSTANTs
	----------------------------------------------------------------------
	CONSTANT C_CLK_PERIOD : TIME := 10 ns;

	--! Amount of pixels of one image
	CONSTANT C_IMAGE_SIZE : natural := G_INPUT_WIDTH * G_INPUT_HEIGHT;

	--! Width of the inferred label
	CONSTANT C_LABEL_WIDTH : natural := integer(ceil(log2(real(G_LABEL_AMOUNT))));

	--! The accelerator is fed one valid pixel every C_PIXEL_GAP cycles, which is what the
	--! AXI wrapper produces as well. Streaming without gaps is not supported.
	CONSTANT C_PIXEL_GAP : natural := 4;

	----------------------------------------------------------------------
	-- TYPEs
	----------------------------------------------------------------------

	TYPE t_image IS ARRAY (0 TO C_IMAGE_SIZE - 1) OF std_logic_vector(G_BIT_WIDTH - 1 DOWNTO 0);

	----------------------------------------------------------------------
	-- RECORDs
	----------------------------------------------------------------------
	-- TB output record

	TYPE t_tb_o IS RECORD
		rst : std_logic;
		-- Control Logic
		i_valid_pixel  : std_logic;
		i_pixel_stream : std_logic_vector(G_BIT_WIDTH - 1 DOWNTO 0);
	END RECORD t_tb_o;

	-- TB input record

	TYPE t_tb_i IS RECORD
		-- generics
		G_LOG_LEVEL : integer RANGE 0 TO 2;
		-- clock
		clk : std_logic;
		--
		o_image_label   : std_logic_vector(C_LABEL_WIDTH - 1 DOWNTO 0);
		o_comp_complete : std_logic;
	END RECORD t_tb_i;

	----------------------------------------------------------------------
	-- FUNCTIONs
	----------------------------------------------------------------------

	--! Reads one image file and unpacks it so that it can be indexed with a signal

	IMPURE FUNCTION f_get_image (
		CONSTANT file_name : string
	) RETURN t_image;

	----------------------------------------------------------------------
	-- PROCEDUREs
	----------------------------------------------------------------------
	-- TC

	PROCEDURE tc_init (
		SIGNAL tb_o : OUT t_tb_o;
		SIGNAL tb_i : IN t_tb_i;
		do_dut_init : boolean := TRUE
	);

	-- DUT

	PROCEDURE dut_init (
		SIGNAL tb_o : OUT t_tb_o;
		SIGNAL tb_i : IN t_tb_i
	);

	--! Streams a whole image into the accelerator and returns the inferred label

	PROCEDURE stream_image (
		SIGNAL tb_o    : OUT t_tb_o;
		SIGNAL tb_i    : IN t_tb_i;
		CONSTANT image : IN t_image;
		VARIABLE digit : OUT integer
	);

	----------------------------------------------------------------------
	-- SHARED VARIABLES (cannot be in generic packages -> local copy!)
	----------------------------------------------------------------------
	SHARED VARIABLE sv_rnd : RandomPType;

END PACKAGE lenet_accel_tb_pkg;

PACKAGE BODY lenet_accel_tb_pkg IS

	----------------------------------------------------------------------
	-- FUNCTIONs
	----------------------------------------------------------------------

	IMPURE FUNCTION f_get_image (
		CONSTANT file_name : string
	) RETURN t_image IS

		CONSTANT C_PACKED : STD_LOGIC_VECTOR(C_IMAGE_SIZE * G_BIT_WIDTH - 1 DOWNTO 0) :=
	                                                                                 init_from_file(file_name, G_BIT_WIDTH, C_IMAGE_SIZE, G_BIT_WIDTH);

		VARIABLE v_image : T_IMAGE;

	BEGIN

		FOR i IN v_image'RANGE LOOP

			v_image(i) := C_PACKED((i + 1) * G_BIT_WIDTH - 1 DOWNTO i * G_BIT_WIDTH);

		END LOOP;

		RETURN v_image;

	END FUNCTION f_get_image;

	----------------------------------------------------------------------
	-- PROCEDUREs
	----------------------------------------------------------------------
	-- TC

	PROCEDURE tc_init (
		SIGNAL tb_o : OUT t_tb_o;
		SIGNAL tb_i : IN t_tb_i;
		do_dut_init : boolean := TRUE
	) IS
	BEGIN

		tb_o.rst <= '1';
		WAIT FOR 1 ns;

		tb_o.i_valid_pixel  <= '0';
		tb_o.i_pixel_stream <= (OTHERS => '0');

		IF do_dut_init THEN
			-- initialize DUT
			dut_init(tb_o, tb_i);
		END IF;

		WAIT FOR 0 ns;

	END PROCEDURE tc_init;

	-- DUT

	PROCEDURE dut_init (
		SIGNAL tb_o : OUT t_tb_o;
		SIGNAL tb_i : IN t_tb_i
	) IS
	BEGIN

		WAIT UNTIL rising_edge(tb_i.clk);
		tb_o.rst <= '1';
		WAIT UNTIL rising_edge(tb_i.clk);
		tb_o.rst <= '0';
		WAIT FOR 0 ns;

	END PROCEDURE dut_init;

	PROCEDURE stream_image (
		SIGNAL tb_o    : OUT t_tb_o;
		SIGNAL tb_i    : IN t_tb_i;
		CONSTANT image : IN t_image;
		VARIABLE digit : OUT integer
	) IS
	BEGIN

		FOR i IN image'RANGE LOOP

			WAIT UNTIL rising_edge(tb_i.clk);
			tb_o.i_pixel_stream <= image(i);
			tb_o.i_valid_pixel  <= '1';

			-- hold the pixel invalid for the rest of the gap
			FOR j IN 1 TO C_PIXEL_GAP - 1 LOOP

				WAIT UNTIL rising_edge(tb_i.clk);
				tb_o.i_valid_pixel <= '0';

			END LOOP;

		END LOOP;

		WAIT UNTIL rising_edge(tb_i.clk);
		tb_o.i_valid_pixel  <= '0';
		tb_o.i_pixel_stream <= (OTHERS => '0');

		-- the inference keeps running for a while after the last pixel
		WAIT UNTIL rising_edge(tb_i.o_comp_complete);
		digit := to_integer(unsigned(tb_i.o_image_label));

	END PROCEDURE stream_image;

END PACKAGE BODY lenet_accel_tb_pkg;
