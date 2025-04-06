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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package libmatrix is

	--! shape: x,"Vector Length"

	type matrix_1d is array (natural range <>) of std_logic_vector;

	--! shape: y,x,"Vector Length"

	type matrix_2d is array (natural range <>) of matrix_1d;

	--! shape: channel,y,x,"Vector Length"

	type matrix_3d is array (natural range <>) of matrix_2d;

	--! Function for transposing a 2D Matrix m_{ij} to m_{ji}

	function transpose_matrix2d (
		input : matrix_2d
	) return matrix_2d;

	--! Function for concatenating two matrix_1d

	function concat_matrix1d (
		l : matrix_1d;
		r : matrix_1d
	) return matrix_1d;

end package libmatrix;

package body libmatrix is

	function concat_matrix1d (
		l : matrix_1d;
		r : matrix_1d
	) return matrix_1d is

		variable tmp : matrix_1d(0 to l'length + r'length - 1)(l(l'low)'range);

	begin

		-- Add elements of l
		for i in l'range loop

			tmp(i) := l(i);

		end loop;

		-- Add elements of r

		for i in r'range loop

			tmp(l'length + i) := r(i);

		end loop;

		return tmp;

	end function concat_matrix1d;

	function transpose_matrix2d (
		input : matrix_2d
	) return matrix_2d is

		variable tmp : matrix_2d(input(input'low)'range)(input'range)(input(input'low)(input'low)'range);

	begin

		for i in input'range loop

			for j in input(input'low)'range loop

				tmp(j)(i) := input(i)(j);

			end loop;

		end loop;

		return tmp;

	end function transpose_matrix2d;

end package body libmatrix;
