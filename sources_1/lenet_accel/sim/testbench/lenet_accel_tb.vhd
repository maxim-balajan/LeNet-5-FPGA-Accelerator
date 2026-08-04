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
USE osvvm.RandomPkg;

ENTITY lenet_accel_tb IS
	GENERIC (
		runner_cfg : STRING      := runner_cfg_default;
		stop_level : LOG_LEVEL_T := error;
		-- TB
		G_RND_SEED  : STRING               := "xxx";
		G_LOG_LEVEL : INTEGER RANGE 0 TO 2 := 1;
		--! images that are classified; the runner fills in absolute paths
		G_IMAGE_PATH_A  : STRING  := "../data/input_2.data";
		G_IMAGE_LABEL_A : NATURAL := 2;
		G_IMAGE_PATH_B  : STRING  := "../data/input_7.data";
		G_IMAGE_LABEL_B : NATURAL := 7;
		-- DUT
		G_BIT_WIDTH             : NATURAL              := 8;
		G_ACCUMULATOR_BIT_WIDTH : NATURAL              := 24;
		G_INPUT_WIDTH           : NATURAL              := 32;
		G_INPUT_HEIGHT          : NATURAL              := 32;
		G_KERNEL_SIZE           : NATURAL              := 5;
		G_POOLING_SIZE          : INTEGER RANGE 2 TO 2 := 2;
		G_ENABLE_CLIP_ADDER     : INTEGER RANGE 0 TO 1 := 1;
		G_SCALE_FILE_PATH       : STRING               := "../data/scale_values.data";
		G_CONV_WEIGHT_PREFIX_0  : STRING               := "../data/output/conv_1_weights_ch";
		G_CONV_WEIGHT_PREFIX_1  : STRING               := "../data/output/conv_2_weights_ch";
		G_DENSE_WEIGHT_PREFIX   : STRING               := "../data/output/dense_weights_row"
	);
END ENTITY lenet_accel_tb;

ARCHITECTURE bench OF lenet_accel_tb IS

	PACKAGE PKG_TB IS NEW tb_lib.lenet_accel_tb_pkg
		GENERIC MAP (
			G_BIT_WIDTH    => G_BIT_WIDTH,
			G_INPUT_WIDTH  => G_INPUT_WIDTH,
			G_INPUT_HEIGHT => G_INPUT_HEIGHT,
			G_LABEL_AMOUNT => 10
		);

	PACKAGE PKG_TC IS NEW tb_lib.lenet_accel_tc_pkg
		GENERIC MAP (
			G_IMAGE_PATH_A  => G_IMAGE_PATH_A,
			G_IMAGE_LABEL_A => G_IMAGE_LABEL_A,
			G_IMAGE_PATH_B  => G_IMAGE_PATH_B,
			G_IMAGE_LABEL_B => G_IMAGE_LABEL_B,
			--
			PKG_TB => PKG_TB
		);

	-- Clock period
	SIGNAL clk    : STD_LOGIC := '0';
	SIGNAL s_tb_i : PKG_TB.T_TB_I;
	SIGNAL s_tb_o : PKG_TB.T_TB_O;

BEGIN

	lenet_accel_inst : ENTITY tb_lib.lenet_accel
		GENERIC MAP (
			G_BIT_WIDTH             => G_BIT_WIDTH,
			G_ACCUMULATOR_BIT_WIDTH => G_ACCUMULATOR_BIT_WIDTH,
			G_INPUT_WIDTH           => G_INPUT_WIDTH,
			G_INPUT_HEIGHT          => G_INPUT_HEIGHT,
			G_KERNEL_SIZE           => G_KERNEL_SIZE,
			G_POOLING_SIZE          => G_POOLING_SIZE,
			G_ENABLE_CLIP_ADDER     => G_ENABLE_CLIP_ADDER,
			G_SCALE_FILE_PATH       => G_SCALE_FILE_PATH,
			G_CONV_WEIGHT_PREFIX_0  => G_CONV_WEIGHT_PREFIX_0,
			G_CONV_WEIGHT_PREFIX_1  => G_CONV_WEIGHT_PREFIX_1,
			G_DENSE_WEIGHT_PREFIX   => G_DENSE_WEIGHT_PREFIX
		)
		PORT MAP (
			clk             => s_tb_i.clk,
			rst             => s_tb_o.rst,
			i_pixel_stream  => s_tb_o.i_pixel_stream,
			i_valid_pixel   => s_tb_o.i_valid_pixel,
			o_image_label   => s_tb_i.o_image_label,
			o_comp_complete => s_tb_i.o_comp_complete
		);

	main : PROCESS IS
	BEGIN

		test_runner_setup(runner, runner_cfg);
		set_stop_level(stop_level);

		-- User information
		info("Testbench directory..: " & tb_path(runner_cfg));
		info("Output    directory..: " & output_path(runner_cfg));
		info("Active test case.....: " & enabled_test_cases(runner_cfg));

		PKG_TB.sv_rnd.initseed(G_RND_SEED);

		WAIT FOR 0 ns;

		WHILE test_suite LOOP

			IF run("TC_0000") THEN
				PKG_TC.TC_0000(s_tb_o, s_tb_i);
			ELSE
				REPORT "main: invalid test case assigned: " & enabled_test_cases(runner_cfg)
					SEVERITY failure;
			END IF;

		END LOOP;

		test_runner_cleanup(runner);

	END PROCESS main;

	-------------------------------------------
	-- misc.
	-------------------------------------------

	clk <= NOT clk AFTER PKG_TB.C_CLK_PERIOD / 2;

	b_misc : BLOCK IS
	BEGIN

		p_multiple_times : PROCESS (clk) IS
		BEGIN

			s_tb_i.clk <= clk;

		END PROCESS p_multiple_times;

		p_one_time : PROCESS IS
		BEGIN

			s_tb_i.G_LOG_LEVEL <= G_LOG_LEVEL;

			WAIT;

		END PROCESS p_one_time;

	END BLOCK b_misc;

END ARCHITECTURE bench;
