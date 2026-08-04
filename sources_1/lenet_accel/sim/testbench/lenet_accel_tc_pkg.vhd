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

LIBRARY tb_lib;

LIBRARY vunit_lib;
	CONTEXT vunit_lib.vunit_context;

LIBRARY osvvm;
	CONTEXT osvvm.OsvvmContext;
USE osvvm.RandomPkg.ALL;

PACKAGE lenet_accel_tc_pkg IS

	GENERIC (
		--! image files that are classified, together with the digit they show
		G_IMAGE_PATH_A  : string;
		G_IMAGE_LABEL_A : natural;
		G_IMAGE_PATH_B  : string;
		G_IMAGE_LABEL_B : natural;
		--
		PACKAGE PKG_TB IS NEW tb_lib.lenet_accel_tb_pkg GENERIC MAP (<>)
	);
	----------------
	-- TEST CASES --
	----------------

	PROCEDURE TC_0000 (
		SIGNAL tb_o : OUT PKG_TB.t_tb_o;
		SIGNAL tb_i : IN PKG_TB.t_tb_i
	);

END PACKAGE lenet_accel_tc_pkg;

PACKAGE BODY lenet_accel_tc_pkg IS

	------------------------------------------------------------------
	-- test-case
	------------------------------------------------------------------

	PROCEDURE TC_0000 (
		SIGNAL tb_o : OUT PKG_TB.t_tb_o;
		SIGNAL tb_i : IN PKG_TB.t_tb_i
	) IS

		CONSTANT C_IMAGE_A : PKG_TB.T_IMAGE := PKG_TB.f_get_image(G_IMAGE_PATH_A);
		CONSTANT C_IMAGE_B : PKG_TB.T_IMAGE := PKG_TB.f_get_image(G_IMAGE_PATH_B);

		VARIABLE v_label : INTEGER;

	BEGIN

		info("################################################################");
		info("## BASIC TC_0000                                               #");
		info("################################################################");
		info("## Streams two handwritten digits through the whole            #");
		info("## accelerator and checks that both are classified correctly.  #");
		info("## The accelerator is rst in between, exactly like the AXI    #");
		info("## wrapper does it after every inference.                      #");
		info("################################################################");

		-- first image
		PKG_TB.tc_init(tb_o, tb_i);

		info("### Streaming " & G_IMAGE_PATH_A & " ...");
		PKG_TB.stream_image(tb_o, tb_i, C_IMAGE_A, v_label);

		info("### Inferred label: " & INTEGER'IMAGE(v_label));
		check_equal(v_label, G_IMAGE_LABEL_A,
	            "Check if the first image is classified as " & INTEGER'IMAGE(G_IMAGE_LABEL_A) & "...");

		-- second image, the accelerator has to be rst before it can take a new image
		PKG_TB.tc_init(tb_o, tb_i);

		info("### Streaming " & G_IMAGE_PATH_B & " ...");
		PKG_TB.stream_image(tb_o, tb_i, C_IMAGE_B, v_label);

		info("### Inferred label: " & INTEGER'IMAGE(v_label));
		check_equal(v_label, G_IMAGE_LABEL_B,
	            "Check if the second image is classified as " & INTEGER'IMAGE(G_IMAGE_LABEL_B) & "...");

		WAIT FOR 2 * PKG_TB.C_CLK_PERIOD;

		info("### Finished TC_0000!");

	END PROCEDURE TC_0000;

END PACKAGE BODY lenet_accel_tc_pkg;
