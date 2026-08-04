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

LIBRARY vunit_lib;
	CONTEXT vunit_lib.vunit_context;

LIBRARY osvvm;
	CONTEXT osvvm.OsvvmContext;
USE osvvm.RandomPkg.ALL;

PACKAGE adder_tree_tb_pkg IS

	GENERIC (
		G_BIT_WIDTH           : natural              := 8;
		G_OUT_BIT_WIDTH       : integer              := 8;
		G_INPUT_AMOUNT        : natural              := 25;
		G_CONTROL_AMOUNT      : natural              := 1;
		G_ENABLE_MUL_LINE     : integer RANGE 0 TO 1 := 1
	);

	----------------------------------------------------------------------
	-- TYPEs
	----------------------------------------------------------------------

	----------------------------------------------------------------------
	-- CONSTANTs
	----------------------------------------------------------------------
	CONSTANT C_CLK_PERIOD : TIME := 10 ns;

	----------------------------------------------------------------------
	-- RECORDs
	----------------------------------------------------------------------
	-- TB output record

	TYPE t_tb_o IS RECORD
		rst : std_logic;
		-- Control Logic
		i_en : std_logic;
		--
		i_use_vec : boolean;
		i_vec0    : std_logic_vector(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
		i_vec1    : std_logic_vector(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
		--
		i_control_signals : std_logic_vector(G_CONTROL_AMOUNT - 1 DOWNTO 0);
	END RECORD t_tb_o;

	-- TB input record

	TYPE t_tb_i IS RECORD
		-- generics
		G_LOG_LEVEL : integer RANGE 0 TO 2;
		-- clock
		clk : std_logic;
		--
		o_vec             : std_logic_vector(G_OUT_BIT_WIDTH - 1 DOWNTO 0);
		o_control_signals : std_logic_vector(G_CONTROL_AMOUNT - 1 DOWNTO 0);
		-- Helper signals
		i_rnd_vec0 : std_logic_vector(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
		i_rnd_vec1 : std_logic_vector(G_INPUT_AMOUNT * G_BIT_WIDTH - 1 DOWNTO 0);
	END RECORD t_tb_i;

	----------------------------------------------------------------------
	-- FUNCTIONs
	----------------------------------------------------------------------

	IMPURE FUNCTION f_get_result (
		CONSTANT bit_width : integer;
		CONSTANT input_amount : integer;
		CONSTANT vector0 : std_logic_vector;
		CONSTANT vector1 : std_logic_vector
	) RETURN integer;

	IMPURE FUNCTION f_get_counter_inputs (
		CONSTANT bit_width : integer;
		CONSTANT input_amount : integer
	) RETURN std_logic_vector;

	IMPURE FUNCTION f_get_random_inputs (
		CONSTANT bit_width : integer;
		CONSTANT input_amount : integer
	) RETURN std_logic_vector;
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

	----------------------------------------------------------------------
	-- SHARED VARIABLES (cannot be in generic packages -> local copy!)
	----------------------------------------------------------------------
	SHARED VARIABLE sv_rnd : RandomPType;

END PACKAGE adder_tree_tb_pkg;

PACKAGE BODY adder_tree_tb_pkg IS

	----------------------------------------------------------------------
	-- FUNCTIONs
	----------------------------------------------------------------------

	IMPURE FUNCTION f_get_result (
		CONSTANT bit_width : integer;
		CONSTANT input_amount : integer;
		CONSTANT vector0 : std_logic_vector;
		CONSTANT vector1 : std_logic_vector
	) RETURN integer IS

		VARIABLE v_result : INTEGER := 0;

	BEGIN

		FOR i IN 0 TO input_amount - 1 LOOP

			IF G_ENABLE_MUL_LINE = 1 THEN
				v_result := v_result + to_integer(signed(vector0((i + 1) * bit_width - 1 DOWNTO i * bit_width)) * signed(vector1((i + 1) * bit_width - 1 DOWNTO i * bit_width)));
			ELSE
				v_result := v_result + to_integer(signed(vector0((i + 1) * bit_width - 1 DOWNTO i * bit_width)));
			END IF;

		END LOOP;

		RETURN v_result;

	END FUNCTION f_get_result;

	IMPURE FUNCTION f_get_counter_inputs (
		CONSTANT bit_width : integer;
		CONSTANT input_amount : integer
	) RETURN std_logic_vector IS

		VARIABLE v_output_vector : STD_LOGIC_VECTOR(input_amount * bit_width - 1 DOWNTO 0);

	BEGIN

		FOR i IN 0 TO input_amount - 1 LOOP

			v_output_vector((i + 1) * bit_width - 1 downto i * bit_width) := std_logic_vector(to_unsigned(i, bit_width));

		END LOOP;

		RETURN v_output_vector;

	END FUNCTION f_get_counter_inputs;

	IMPURE FUNCTION f_get_random_inputs (
		CONSTANT bit_width : integer;
		CONSTANT input_amount : integer
	) RETURN std_logic_vector IS

		VARIABLE v_output_vector : STD_LOGIC_VECTOR(input_amount * bit_width - 1 DOWNTO 0);

	BEGIN

		FOR i IN 0 TO input_amount - 1 LOOP

			v_output_vector((i + 1) * bit_width - 1 downto i * bit_width) := sv_rnd.RandSlv(Size => bit_width);

		END LOOP;

		RETURN v_output_vector;

	END FUNCTION f_get_random_inputs;

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

		tb_o.i_en              <= '0';
		tb_o.i_use_vec         <= TRUE;
		tb_o.i_vec0            <= (OTHERS => '0');
		tb_o.i_vec1            <= (OTHERS => '0');
		tb_o.i_control_signals <= (OTHERS => '0');

		IF do_dut_init THEN
			-- wait until rising_edge(tb_i.clk);
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

END PACKAGE BODY adder_tree_tb_pkg;
