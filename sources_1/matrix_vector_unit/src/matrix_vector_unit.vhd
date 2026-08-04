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

ENTITY matrix_vector_unit IS
	GENERIC (
		-- weight_width == input_height
		G_MAX_WEIGHT_WIDTH  : NATURAL              := 400;
		G_MAX_WEIGHT_HEIGHT : NATURAL              := 120;
		G_BIT_WIDTH         : NATURAL              := 8;
		G_OUT_BIT_WIDTH     : NATURAL              := 24;
		G_ENABLE_CLIP_ADDER : INTEGER RANGE 0 TO 1 := 1
	);
	PORT (
		clk                    : IN STD_LOGIC;
		rst                    : IN STD_LOGIC;
		i_en                   : IN STD_LOGIC;
		i_actual_weight_width  : IN STD_LOGIC_VECTOR(integer(ceil(log2(real(G_MAX_WEIGHT_WIDTH)))) DOWNTO 0);
		i_actual_weight_height : IN STD_LOGIC_VECTOR(integer(ceil(log2(real(G_MAX_WEIGHT_HEIGHT)))) DOWNTO 0);
		--! one weight per MAC, MAC i occupies ((i + 1) * G_BIT_WIDTH - 1 downto i * G_BIT_WIDTH)
		i_weights          : IN STD_LOGIC_VECTOR(G_MAX_WEIGHT_HEIGHT * G_BIT_WIDTH - 1 DOWNTO 0);
		i_vector           : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_bram_enable_line : OUT STD_LOGIC_VECTOR(0 TO G_MAX_WEIGHT_HEIGHT - 1);
		--! one result per MAC, MAC i occupies ((i + 1) * G_OUT_BIT_WIDTH - 1 downto i * G_OUT_BIT_WIDTH)
		o_results       : OUT STD_LOGIC_VECTOR(G_MAX_WEIGHT_HEIGHT * G_OUT_BIT_WIDTH - 1 DOWNTO 0);
		o_comp_complete : OUT STD_LOGIC
	);
END ENTITY matrix_vector_unit;

ARCHITECTURE rtl OF matrix_vector_unit IS

	-- The input value travels from MAC to MAC, so one extra element is needed at the end

	TYPE t_input_line IS ARRAY(0 TO G_MAX_WEIGHT_HEIGHT) OF STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);

	TYPE t_partial_results IS ARRAY(0 TO G_MAX_WEIGHT_HEIGHT - 1) OF STD_LOGIC_VECTOR(3 * G_BIT_WIDTH - 1 DOWNTO 0);

	SIGNAL s_input : STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_en    : STD_LOGIC;

	SIGNAL s_inputs_pipelined : UNSIGNED(integer(ceil(log2(real(G_MAX_WEIGHT_WIDTH)))) DOWNTO 0);
	SIGNAL s_inputs_finished  : UNSIGNED(integer(ceil(log2(real(G_MAX_WEIGHT_WIDTH)))) DOWNTO 0);

	SIGNAL s_enable_bits     : STD_LOGIC_VECTOR(0 TO G_MAX_WEIGHT_HEIGHT);
	SIGNAL s_input_line      : t_input_line;
	SIGNAL s_partial_results : t_partial_results;

	SIGNAL s_actual_weight_width  : UNSIGNED(integer(ceil(log2(real(G_MAX_WEIGHT_WIDTH)))) DOWNTO 0);
	SIGNAL s_actual_weight_height : UNSIGNED(integer(ceil(log2(real(G_MAX_WEIGHT_HEIGHT)))) DOWNTO 0);

BEGIN

	-- This process delays the inputs by one cycle
	-- This could also probably be omitted but is here to make sure everything is clocked
	DELAY_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_input <= (OTHERS => '0');
				s_en    <= '0';
			ELSE
				s_input <= i_vector;
				s_en    <= i_en;
			END IF;
		END IF;

	END PROCESS DELAY_PROC;

	-- This process starts the actual pipelining process and also makes sure no illegal values are pipelined
	-- It also keeps track on how many inputs successfully finished computation to later correctly determine
	-- when the computation should end

	PIPELINE_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_inputs_pipelined               <= (OTHERS => '0');
				s_inputs_finished                <= (OTHERS => '0');
				s_enable_bits(s_enable_bits'low) <= '0';
				s_input_line(s_input_line'low)   <= (OTHERS => '0');
				-- when resetting the unit set the actual weight_width and weight_height for further computation
				s_actual_weight_width  <= unsigned(i_actual_weight_width);
				s_actual_weight_height <= unsigned(i_actual_weight_height);
			ELSE
				-- only pipeline values when not all inputs were received
				IF s_inputs_pipelined /= s_actual_weight_width THEN
					s_enable_bits(s_enable_bits'low) <= s_en;
					IF s_en = '1' THEN
						-- Store amount of inputs pipelined and write current input to first MAC
						s_inputs_pipelined             <= s_inputs_pipelined + 1;
						s_input_line(s_input_line'low) <= s_input;
					END IF;
				ELSE
					s_enable_bits(s_enable_bits'low) <= '0';
				END IF;

				-- If enable bit is buffered through all MACs then a input value is finished with it's computation
				IF s_enable_bits(to_integer(s_actual_weight_height)) = '1' THEN
					s_inputs_finished <= s_inputs_finished + 1;
				END IF;
			END IF;
		END IF;

	END PROCESS PIPELINE_PROC;

	MAC_GENERATION : FOR y_id IN 0 TO G_MAX_WEIGHT_HEIGHT - 1 GENERATE

		MACS : ENTITY work.matrix_vector_mac_unit
			GENERIC MAP (
				G_BIT_WIDTH         => G_BIT_WIDTH,
				G_ENABLE_CLIP_ADDER => G_ENABLE_CLIP_ADDER
			)
			PORT MAP (
				clk            => clk,
				rst            => rst,
				i_en           => s_enable_bits(y_id),
				i_vector       => s_input_line(y_id),
				i_weight       => i_weights((y_id + 1) * G_BIT_WIDTH - 1 DOWNTO y_id * G_BIT_WIDTH),
				i_partial_sum  => s_partial_results(y_id),
				o_en_delay     => s_enable_bits(y_id + 1),
				o_vector_delay => s_input_line(y_id + 1),
				o_partial_sum  => s_partial_results(y_id)
			);

	END GENERATE MAC_GENERATION;

	-- This generate is necessary to get G_OUT_BIT_WIDTH-long slices of the partial results

	MAP_GEN : FOR i IN 0 TO G_MAX_WEIGHT_HEIGHT - 1 GENERATE
		o_results((i + 1) * G_OUT_BIT_WIDTH - 1 downto i * G_OUT_BIT_WIDTH) <= s_partial_results(i)(G_OUT_BIT_WIDTH - 1 DOWNTO 0);
	END GENERATE MAP_GEN;

	-- This signal is set one cycle to late, but this is not a problem because no illegal values are ever pipelined
	o_comp_complete <= '1' WHEN s_inputs_finished = s_actual_weight_width ELSE '0';
	-- BRAM enable line always needs enable signals one cycle earlier because BRAM access has a cycle delay
	o_bram_enable_line <= s_en & s_enable_bits(0 TO G_MAX_WEIGHT_HEIGHT - 2);

END ARCHITECTURE rtl;
