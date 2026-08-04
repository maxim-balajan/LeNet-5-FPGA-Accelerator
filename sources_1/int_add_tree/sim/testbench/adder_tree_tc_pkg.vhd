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

LIBRARY tb_lib;

LIBRARY vunit_lib;
	CONTEXT vunit_lib.vunit_context;

LIBRARY osvvm;
	CONTEXT osvvm.OsvvmContext;
USE osvvm.RandomPkg.ALL;

PACKAGE adder_tree_tc_pkg IS

	GENERIC (
		G_BIT_WIDTH           : natural;
		G_OUT_BIT_WIDTH       : integer;
		G_INPUT_AMOUNT        : natural;
		G_ENABLE_MUL_LINE     : integer RANGE 0 TO 1;
		--
		package PKG_TB is new tb_lib.adder_tree_tb_pkg generic map (<>)
	);
	----------------
	-- TEST CASES --
	----------------

	PROCEDURE TC_0000 (
		SIGNAL tb_o : OUT PKG_TB.t_tb_o;
		SIGNAL tb_i : IN PKG_TB.t_tb_i
	);

	PROCEDURE TC_0010 (
		SIGNAL tb_o : OUT PKG_TB.t_tb_o;
		SIGNAL tb_i : IN PKG_TB.t_tb_i
	);

END PACKAGE adder_tree_tc_pkg;

PACKAGE BODY adder_tree_tc_pkg IS

	------------------------------------------------------------------
	-- test-case
	------------------------------------------------------------------

	PROCEDURE TC_0000 (
		SIGNAL tb_o : OUT PKG_TB.t_tb_o;
		SIGNAL tb_i : IN PKG_TB.t_tb_i
	) IS

		CONSTANT C_COUNTER_VEC        : STD_LOGIC_VECTOR(tb_o.i_vec0'RANGE) := PKG_TB.f_get_counter_inputs(G_BIT_WIDTH, G_INPUT_AMOUNT);
		CONSTANT C_N                  : INTEGER                             := G_INPUT_AMOUNT - 1;
		CONSTANT C_EXPECTED_FAULHABER : INTEGER                             := (C_N * (C_N + 1) * (2 * C_N + 1)) / 6;
		CONSTANT C_EXPECTED_GAUSS     : INTEGER                             := (C_N * (C_N + 1)) / 2;
		CONSTANT C_EXPECTED_RES       : INTEGER                             := PKG_TB.f_get_result(G_BIT_WIDTH, G_INPUT_AMOUNT, C_COUNTER_VEC, C_COUNTER_VEC);

	BEGIN

		info("################################################################");
		info("## BASIC TC_0000                                               #");
		info("################################################################");
		info("## Testing if sum of a vector that counts up can be            #");
		info("## found with Little Gauss, or with Faulhabers Formula if      #");
		info("## multiplication is used, and also with std solution function #");
		info("################################################################");

		PKG_TB.tc_init(tb_o, tb_i);

		tb_o.i_en                 <= '1';
		tb_o.i_vec0               <= C_COUNTER_VEC;
		tb_o.i_vec1               <= C_COUNTER_VEC;
		tb_o.i_control_signals(0) <= '1';

		WAIT UNTIL rising_edge(tb_i.o_control_signals(0));

		IF G_ENABLE_MUL_LINE = 1 THEN
			check_equal(tb_i.o_vec, std_logic_vector(to_signed(C_EXPECTED_FAULHABER, G_OUT_BIT_WIDTH)), "Check if output vector is result of Faulhabers Formula...");
		ELSIF G_ENABLE_MUL_LINE = 0 THEN
			check_equal(tb_i.o_vec, std_logic_vector(to_signed(C_EXPECTED_GAUSS, G_OUT_BIT_WIDTH)), "Check if output vector is result of Gauss Formula...");
		ELSE
			check_failed("### G_ENABLE_MUL_LINE is " & INTEGER'IMAGE(G_ENABLE_MUL_LINE) & " but can only be in {0, 1}...");
		END IF;

		check_equal(tb_i.o_vec, std_logic_vector(to_signed(C_EXPECTED_RES, G_OUT_BIT_WIDTH)), "Check if output vector is as expected...");

		WAIT FOR 2 * PKG_TB.C_CLK_PERIOD;

		info("### Finished TC_0000!");

	END PROCEDURE TC_0000;

	------------------------------------------------------------------
	-- test-case
	------------------------------------------------------------------

	PROCEDURE TC_0010 (
		SIGNAL tb_o : OUT PKG_TB.t_tb_o;
		SIGNAL tb_i : IN PKG_TB.t_tb_i
	) IS

		VARIABLE v_result : INTEGER                                                     := 0;
		VARIABLE v_input0 : STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
		VARIABLE v_input1 : STD_LOGIC_VECTOR(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

		VARIABLE v_identifier      : UNSIGNED(tb_o.i_control_signals'RANGE) := to_unsigned(1, tb_o.i_control_signals'LENGTH);
		VARIABLE v_next_identifier : UNSIGNED(v_identifier'RANGE)           := to_unsigned(2, tb_o.i_control_signals'LENGTH);

	BEGIN

		info("################################################################");
		info("## ADVANCED TC_0010                                            #");
		info("################################################################");
		info("## Testing for 1000 iterations if sum value of a vector        #");
		info("## that consists of random values can be found correctly...    #");
		info("################################################################");

		PKG_TB.tc_init(tb_o, tb_i);

		tb_o.i_use_vec <= FALSE;
		tb_o.i_en      <= '1';

		FOR i IN 1 TO 1000 LOOP

			v_input0               := tb_i.i_rnd_vec0;
			v_input1               := tb_i.i_rnd_vec1;
			v_result               := PKG_TB.f_get_result(G_BIT_WIDTH, G_INPUT_AMOUNT, v_input0, v_input1);
			tb_o.i_control_signals <= std_logic_vector(v_identifier);

			WAIT UNTIL rising_edge(tb_i.clk) AND v_identifier = unsigned(tb_i.o_control_signals);

			v_identifier      := v_next_identifier;
			v_next_identifier := v_next_identifier + 1;

			check_equal(tb_i.o_vec, std_logic_vector(to_signed(v_result, G_OUT_BIT_WIDTH)), "Check if output vector is as expected...");

			WAIT FOR 0 ns; -- wait delta cycle so that tb_i.i_rnd_vec0 and tb_i.i_rnd_vec1 is updated correctly

		END LOOP;

		WAIT FOR 2 * PKG_TB.C_CLK_PERIOD;

		info("### Finished TC_0010!");

	END PROCEDURE TC_0010;

END PACKAGE BODY adder_tree_tc_pkg;
