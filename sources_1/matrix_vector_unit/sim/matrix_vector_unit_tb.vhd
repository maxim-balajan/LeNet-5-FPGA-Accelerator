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

ENTITY matrix_vector_unit_tb IS
END ENTITY matrix_vector_unit_tb;

ARCHITECTURE bench OF matrix_vector_unit_tb IS

	-- Clock period
	CONSTANT clk_period : TIME := 10 ns;
	-- Generics
	CONSTANT weight_width  : INTEGER := 400;
	CONSTANT weight_height : INTEGER := 120;
	CONSTANT vector_length : INTEGER := 8;
	-- Ports
	SIGNAL clk              : STD_LOGIC := '1';
	SIGNAL rst              : STD_LOGIC;
	SIGNAL en               : STD_LOGIC;
	SIGNAL weights          : STD_LOGIC_VECTOR(weight_height * vector_length - 1 DOWNTO 0);
	SIGNAL input            : STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
	SIGNAL bram_enable_line : STD_LOGIC_VECTOR(0 TO weight_height - 1);
	SIGNAL results          : STD_LOGIC_VECTOR(weight_height * vector_length - 1 DOWNTO 0);
	SIGNAL comp_complete    : STD_LOGIC;

	CONSTANT c_actual_weight_width  : STD_LOGIC_VECTOR(integer(ceil(log2(real(weight_width)))) DOWNTO 0)  := std_logic_vector(to_unsigned(5, integer(ceil(log2(real(weight_width)))) + 1));
	CONSTANT c_actual_weight_height : STD_LOGIC_VECTOR(integer(ceil(log2(real(weight_height)))) DOWNTO 0) := std_logic_vector(to_unsigned(4, integer(ceil(log2(real(weight_height)))) + 1));

	CONSTANT c_input_delay_amount : INTEGER := 3;
	SIGNAL   s_invalid_delay      : INTEGER;

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	matrix_vector_unit_inst : ENTITY work.matrix_vector_unit
		GENERIC MAP (
			G_MAX_WEIGHT_WIDTH  => weight_width,
			G_MAX_WEIGHT_HEIGHT => weight_height,
			G_BIT_WIDTH         => vector_length,
			G_OUT_BIT_WIDTH     => 3 * vector_length
		)
		PORT MAP (
			clk                    => clk,
			rst                    => rst,
			i_en                   => en,
			i_weights              => weights,
			i_actual_weight_width  => c_actual_weight_width,
			i_actual_weight_height => c_actual_weight_height,
			i_vector               => input,
			o_bram_enable_line     => bram_enable_line,
			o_results              => results,
			o_comp_complete        => comp_complete
		);

	CLK_PROC : PROCESS IS
	BEGIN

		WHILE s_sim_done = '0' LOOP

			clk <= '0';
			WAIT FOR clk_period / 2;
			clk <= '1';
			WAIT FOR clk_period / 2;

		END LOOP;

		WAIT;

	END PROCESS CLK_PROC;

	rst <= '1' AFTER 0 ns, '0' AFTER 2 * clk_period;

	INPUT_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				input           <= (OTHERS => '0');
				en              <= '0';
				s_invalid_delay <= 0;
			ELSE
				IF s_invalid_delay = 0 THEN
					IF signed(input) >= signed(c_actual_weight_width) THEN
						en <= '0';
					ELSE
						input <= std_logic_vector(signed(input) + 1);
						en    <= '1';
					END IF;
				ELSE
					en <= '0';
				END IF;

				IF s_invalid_delay /= c_input_delay_amount THEN
					s_invalid_delay <= s_invalid_delay + 1;
				ELSE
					s_invalid_delay <= 0;
				END IF;
			END IF;
		END IF;

	END PROCESS INPUT_PROC;

	WEIGHT_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN

				FOR i IN 0 TO to_integer(unsigned(c_actual_weight_height)) - 1 LOOP

					weights((i + 1) * vector_length - 1 downto i * vector_length) <= std_logic_vector(to_signed(i + 2, vector_length));

				END LOOP;

				FOR i IN to_integer(unsigned(c_actual_weight_height)) TO weight_height - 1 LOOP

					weights((i + 1) * vector_length - 1 downto i * vector_length) <= (OTHERS => '0');

				END LOOP;

			ELSE

				FOR i IN 0 TO to_integer(unsigned(c_actual_weight_height)) - 1 LOOP

					IF bram_enable_line(i) = '1' THEN
						weights((i + 1) * vector_length - 1 downto i * vector_length) <= std_logic_vector(signed(weights((i + 1) * vector_length - 1 DOWNTO i * vector_length)) + 1);
					END IF;

				END LOOP;

			END IF;
		END IF;

	END PROCESS WEIGHT_PROC;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 30 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
