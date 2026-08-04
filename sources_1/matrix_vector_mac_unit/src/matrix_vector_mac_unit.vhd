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

ENTITY matrix_vector_mac_unit IS
	GENERIC (
		G_BIT_WIDTH         : NATURAL              := 8;
		G_ENABLE_CLIP_ADDER : INTEGER RANGE 0 TO 1 := 1
	);
	PORT (
		clk            : IN STD_LOGIC;
		rst            : IN STD_LOGIC;
		i_en           : IN STD_LOGIC;
		i_vector       : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		i_weight       : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		i_partial_sum  : IN STD_LOGIC_VECTOR(3 * G_BIT_WIDTH - 1 DOWNTO 0);
		o_en_delay     : OUT STD_LOGIC;
		o_vector_delay : OUT STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_partial_sum  : OUT STD_LOGIC_VECTOR(3 * G_BIT_WIDTH - 1 DOWNTO 0)
	);
END ENTITY matrix_vector_mac_unit;

ARCHITECTURE rtl OF matrix_vector_mac_unit IS

	SIGNAL s_en          : STD_LOGIC;
	SIGNAL s_vector      : SIGNED(G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_weight      : SIGNED(G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_partial_sum : SIGNED(3 * G_BIT_WIDTH - 1 DOWNTO 0);

	SIGNAL s_mul_result : SIGNED(3 * G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_add_result : SIGNED(3 * G_BIT_WIDTH - 1 DOWNTO 0);
	-- These signals are for the clip adder
	SIGNAL s_tmp_add_result  : STD_LOGIC_VECTOR(3 * G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_mul_result_slv  : STD_LOGIC_VECTOR(3 * G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_partial_sum_slv : STD_LOGIC_VECTOR(3 * G_BIT_WIDTH - 1 DOWNTO 0);

BEGIN

	DELAY_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_en          <= '0';
				s_vector      <= (OTHERS => '0');
				s_weight      <= (OTHERS => '0');
				s_partial_sum <= (OTHERS => '0');
			ELSE
				s_en          <= i_en;
				s_vector      <= signed(i_vector);
				s_weight      <= signed(i_weight);
				s_partial_sum <= signed(i_partial_sum);
			END IF;
		END IF;

	END PROCESS DELAY_PROC;

	-- Calculations of inputs; delayed by one cycle through DELAY_PROC
	-- weight_vector also delayed => BRAM needs enable signals one cycle earlier
	s_mul_result <= resize(signed(s_vector) * signed(s_weight), s_mul_result'LENGTH);

	s_mul_result_slv  <= std_logic_vector(s_mul_result);
	s_partial_sum_slv <= std_logic_vector(s_partial_sum);

	CLIP_GEN : IF G_ENABLE_CLIP_ADDER = 1 GENERATE

		CLIP_ADDER_INST : ENTITY work.clip_adder
			GENERIC MAP (
				G_BIT_WIDTH => 3 * G_BIT_WIDTH
			)
			PORT MAP (
				i_din0 => s_mul_result_slv,
				i_din1 => s_partial_sum_slv,
				o_dout => s_tmp_add_result
			);

	END GENERATE CLIP_GEN;

	NO_CLIP_GEN : IF G_ENABLE_CLIP_ADDER = 0 GENERATE
		s_tmp_add_result <= std_logic_vector(s_mul_result + s_partial_sum);
	END GENERATE NO_CLIP_GEN;

	-- result is only taken iff. s_mac_en = '1'
	s_add_result <= signed(s_tmp_add_result) WHEN s_en = '1' ELSE s_partial_sum;

	-- Setting of output signals
	o_en_delay     <= s_en;
	o_partial_sum  <= std_logic_vector(s_add_result);
	o_vector_delay <= std_logic_vector(s_vector);

END ARCHITECTURE rtl;
