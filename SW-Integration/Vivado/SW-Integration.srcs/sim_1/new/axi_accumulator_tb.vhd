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
use ieee.std_logic_unsigned.all;

entity axi_accumulator_tb is
end;

architecture bench of axi_accumulator_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal clk : std_logic := '0';
  signal reset : std_logic;
  signal s_axis_tdata : std_logic_vector(7 downto 0) := (others => '0');
  signal s_axis_tkeep : std_logic_vector(0 downto 0);
  signal s_axis_tlast : std_logic;
  signal s_axis_tready : std_logic;
  signal s_axis_tvalid : std_logic;
  signal m_axis_tdata : std_logic_vector(7 downto 0);
  signal m_axis_tkeep : std_logic_vector(0 downto 0);
  signal m_axis_tlast : std_logic;
  signal m_axis_tready : std_logic;
  signal m_axis_tvalid : std_logic;
begin

  axi_accumulator_inst : entity work.axi_accumulator
  port map (
    clk => clk,
    reset => reset,
    s_axis_tdata => s_axis_tdata,
    s_axis_tkeep => s_axis_tkeep,
    s_axis_tlast => s_axis_tlast,
    s_axis_tready => s_axis_tready,
    s_axis_tvalid => s_axis_tvalid,
    m_axis_tdata => m_axis_tdata,
    m_axis_tkeep => m_axis_tkeep,
    m_axis_tlast => m_axis_tlast,
    m_axis_tready => m_axis_tready,
    m_axis_tvalid => m_axis_tvalid
  );
    clk <= not clk after clk_period/2;
    reset <= '1' after 0 ns, '0' after 10 ns;

    s_axis_tkeep <= "1";
    s_axis_tlast <= '0' after 0 ns, '1' after 55 ns, '0' after 60 ns;
    s_axis_tvalid <= '0' after 0 ns, '1'  after 30 ns, '0' after 60 ns;
    m_axis_tready <= '1';


	process is
    begin
  
      wait for 10 ns;
      s_axis_tdata <= std_logic_vector(unsigned(s_axis_tdata) + 1);
  
    end process;

end;