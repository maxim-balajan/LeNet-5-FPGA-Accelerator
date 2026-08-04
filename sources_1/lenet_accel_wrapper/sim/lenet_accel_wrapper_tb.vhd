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
USE ieee.std_logic_unsigned.ALL;
USE work.libmemory.ALL;

ENTITY lenet_accel_wrapper_tb IS
END ENTITY lenet_accel_wrapper_tb;

ARCHITECTURE bench OF lenet_accel_wrapper_tb IS

	TYPE t_image IS ARRAY(0 TO 32 * 32 - 1) OF STD_LOGIC_VECTOR(8 - 1 DOWNTO 0);

	FUNCTION f_unpack_image (
		packed : STD_LOGIC_VECTOR
	) RETURN t_image IS

		VARIABLE v : t_image;

	BEGIN

		FOR i IN v'RANGE LOOP

			v(i) := packed((i + 1) * (8) - 1 DOWNTO i * (8));

		END LOOP;

		RETURN v;

	END FUNCTION f_unpack_image;

	-- Clock period
	CONSTANT clk_period : TIME := 5 ns;
	-- Generics
	-- Ports
	SIGNAL clk           : STD_LOGIC                    := '0';
	SIGNAL rst           : STD_LOGIC;
	SIGNAL s_axis_tdata  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_axis_tkeep  : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL s_axis_tlast  : STD_LOGIC;
	SIGNAL s_axis_tready : STD_LOGIC;
	SIGNAL s_axis_tvalid : STD_LOGIC;
	SIGNAL m_axis_tdata  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL m_axis_tkeep  : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL m_axis_tlast  : STD_LOGIC;
	SIGNAL m_axis_tready : STD_LOGIC;
	SIGNAL m_axis_tvalid : STD_LOGIC;

	CONSTANT input_path_2 : STRING := "../data/input_2.data";

	CONSTANT s_input_stream_2 : t_image := f_unpack_image(init_from_file(input_path_2, 8, 32 * 32));
	CONSTANT input_path_7     : STRING  := "../data/input_7.data";
	CONSTANT s_input_stream_7 : t_image := f_unpack_image(init_from_file(input_path_7, 8, 32 * 32));
	SIGNAL   s_read_pointer   : INTEGER RANGE 0 TO (32 * 32);

	SIGNAL s_actual_input_stream : t_image;
	SIGNAL s_invalid_delay       : INTEGER RANGE 0 TO 3;
	SIGNAL s_iteration           : INTEGER := 0;

	SIGNAL s_sim_done : STD_LOGIC := '0';

BEGIN

	s_actual_input_stream <= s_input_stream_2 WHEN s_iteration = 0 ELSE s_input_stream_7;

	STREAM_PROC : PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				s_axis_tdata    <= (OTHERS => '0');
				s_axis_tvalid   <= '0';
				s_invalid_delay <= 0;
				s_read_pointer  <= 0;
			ELSE
				IF s_read_pointer < (32 * 32) THEN
					IF s_invalid_delay = 0 THEN
						s_axis_tdata   <= s_actual_input_stream(s_read_pointer);
						s_read_pointer <= s_read_pointer + 1;
						s_axis_tvalid  <= '1';
					ELSE
						s_axis_tvalid <= '0';
					END IF;

				-- if s_invalid_delay /= 3 then
				--   s_invalid_delay <= s_invalid_delay + 1;
				-- else
				--   s_invalid_delay <= 0;
				-- end if;
				ELSE
					s_axis_tdata  <= (OTHERS => '0');
					s_axis_tvalid <= '0';

					IF m_axis_tvalid = '1' AND s_iteration = 1 THEN
						s_read_pointer <= 0;
					END IF;
				END IF;
			END IF;
		END IF;

	END PROCESS STREAM_PROC;

	lenet_accel_wrapper_inst : ENTITY work.lenet_accel_wrapper
		PORT MAP (
			clk           => clk,
			rst           => rst,
			s_axis_tdata  => s_axis_tdata,
			s_axis_tkeep  => s_axis_tkeep,
			s_axis_tlast  => s_axis_tlast,
			s_axis_tready => s_axis_tready,
			s_axis_tvalid => s_axis_tvalid,
			m_axis_tdata  => m_axis_tdata,
			m_axis_tkeep  => m_axis_tkeep,
			m_axis_tlast  => m_axis_tlast,
			m_axis_tready => m_axis_tready,
			m_axis_tvalid => m_axis_tvalid
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

	rst <= '1' AFTER 0 ns, '0' AFTER 10 ns;

	s_axis_tkeep  <= "1";
	s_axis_tlast  <= '0' AFTER 0 ns, '1' AFTER 55 ns, '0' AFTER 200 ns;
	m_axis_tready <= '1';

	CHECK_COMP_COMPLETE : PROCESS (m_axis_tvalid) IS
	BEGIN

		IF rising_edge(m_axis_tvalid) THEN
			s_iteration <= s_iteration + 1;
		END IF;

	END PROCESS CHECK_COMP_COMPLETE;

	TB : PROCESS IS
	BEGIN

		WAIT FOR 20000 * clk_period;
		s_sim_done <= '1';
		WAIT;

	END PROCESS TB;

END ARCHITECTURE bench;
