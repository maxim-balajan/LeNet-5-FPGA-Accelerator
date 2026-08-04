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

LIBRARY tb_lib;

LIBRARY vunit_lib;
	CONTEXT vunit_lib.vunit_context;

LIBRARY osvvm;
	CONTEXT osvvm.OsvvmContext;
USE osvvm.RandomPkg;

ENTITY comparator_tree_tb IS
	GENERIC (
		runner_cfg : STRING      := runner_cfg_default;
		stop_level : LOG_LEVEL_T := error;
		-- TB
		G_RND_SEED  : STRING               := "xxx";
		G_LOG_LEVEL : INTEGER RANGE 0 TO 2 := 1;
		-- DUT
		G_BIT_WIDTH           : NATURAL  := 8;
		G_INIT_PIPELINE_STEPS : POSITIVE := 2;
		G_INPUT_AMOUNT        : NATURAL  := 25;
		G_CONTROL_AMOUNT      : NATURAL  := 1
	);
END ENTITY comparator_tree_tb;

ARCHITECTURE bench OF comparator_tree_tb IS

	PACKAGE PKG_TB IS NEW tb_lib.comparator_tree_tb_pkg
		GENERIC MAP (
			G_BIT_WIDTH      => G_BIT_WIDTH,
			G_INPUT_AMOUNT   => G_INPUT_AMOUNT,
			G_CONTROL_AMOUNT => G_CONTROL_AMOUNT
		);

	PACKAGE PKG_TC IS NEW tb_lib.comparator_tree_tc_pkg
		GENERIC MAP (
			G_BIT_WIDTH      => G_BIT_WIDTH,
			G_INPUT_AMOUNT   => G_INPUT_AMOUNT,
			G_CONTROL_AMOUNT => G_CONTROL_AMOUNT,
			--
			PKG_TB => PKG_TB
		);

	-- Clock period
	SIGNAL clk    : STD_LOGIC := '0';
	SIGNAL s_tb_i : PKG_TB.T_TB_I;
	SIGNAL s_tb_o : PKG_TB.T_TB_O;

	SIGNAL s_rnd_vec0    : STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_actual_vec0 : STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);

BEGIN

	comparator_unit_inst : ENTITY work.comparator_tree_unit
		GENERIC MAP (
			G_BIT_WIDTH           => G_BIT_WIDTH,
			G_INIT_PIPELINE_STEPS => G_INIT_PIPELINE_STEPS,
			G_INPUT_AMOUNT        => G_INPUT_AMOUNT,
			G_CONTROL_AMOUNT      => G_CONTROL_AMOUNT
		)
		PORT MAP (
			clk               => s_tb_i.clk,
			rst               => s_tb_o.rst,
			i_en              => s_tb_o.i_en,
			i_vec0            => s_actual_vec0,
			i_control_signals => s_tb_o.i_control_signals,
			o_vec             => s_tb_i.o_vec,
			o_control_signals => s_tb_i.o_control_signals
		);

	s_actual_vec0 <= s_tb_o.i_vec0 WHEN s_tb_o.i_use_vec0 ELSE s_rnd_vec0;

	RND_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF s_tb_o.rst = '1' THEN
				s_rnd_vec0 <= (OTHERS => '0');
			ELSIF s_tb_o.i_en = '1' THEN
				s_rnd_vec0 <= PKG_TB.f_get_random_inputs(G_BIT_WIDTH, G_INPUT_AMOUNT);
			END IF;
		END IF;

	END PROCESS RND_PROC;

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
			ELSIF run("TC_0010") THEN
				PKG_TC.TC_0010(s_tb_o, s_tb_i);
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

	clk <= not clk AFTER PKG_TB.C_CLK_PERIOD / 2;

	b_misc : BLOCK IS
	BEGIN

		p_multiple_times : PROCESS (clk, s_rnd_vec0) IS
		BEGIN

			s_tb_i.clk        <= clk;
			s_tb_i.i_rnd_vec0 <= s_rnd_vec0;

		END PROCESS p_multiple_times;

		p_one_time : PROCESS IS
		BEGIN

			s_tb_i.G_LOG_LEVEL <= G_LOG_LEVEL;

			WAIT;

		END PROCESS p_one_time;

	END BLOCK b_misc;

END ARCHITECTURE bench;
