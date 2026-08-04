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

-- This unit is purely combinatorial!!! It is not pipelined because, although it would be easy to implement
-- it for the convolutions, it would be hard to implement this into the MACs of the MV-Unit.
-- Also two multiplexers (in series) shouldn't increase the critical path by too much compared to a single adder

ENTITY clip_adder IS
	GENERIC (
		G_BIT_WIDTH : NATURAL := 8
	);
	PORT (
		i_din0 : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		i_din1 : IN STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
		o_dout : OUT STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0)
	);
END ENTITY clip_adder;

ARCHITECTURE rtl OF clip_adder IS

	SIGNAL s_tmp_result : STD_LOGIC_VECTOR(G_BIT_WIDTH - 1 DOWNTO 0);
	SIGNAL s_result     : SIGNED(G_BIT_WIDTH - 1 DOWNTO 0);

	SIGNAL s_overflow  : STD_LOGIC;
	SIGNAL s_underflow : STD_LOGIC;

BEGIN

	-- Do addition
	s_tmp_result <= std_logic_vector(signed(i_din0) + signed(i_din1));
	-- Set control signals
	s_overflow  <= '1' WHEN i_din0(i_din0'HIGH) = '0' AND i_din1(i_din1'HIGH) = '0' AND s_tmp_result(s_tmp_result'HIGH) = '1' ELSE '0';
	s_underflow <= '1' WHEN i_din0(i_din0'HIGH) = '1' AND i_din1(i_din1'HIGH) = '1' AND s_tmp_result(s_tmp_result'HIGH) = '0' ELSE '0';
	-- Output result via two multiplexers
	s_result <= to_signed(2 ** (G_BIT_WIDTH - 1) - 1, s_result'LENGTH) WHEN s_overflow = '1' ELSE
	            to_signed(- 2 ** (G_BIT_WIDTH - 1), s_result'LENGTH) WHEN s_underflow = '1' ELSE
	            signed(s_tmp_result);
	-- Write output to dout port
	o_dout <= std_logic_vector(s_result);

END ARCHITECTURE rtl;
