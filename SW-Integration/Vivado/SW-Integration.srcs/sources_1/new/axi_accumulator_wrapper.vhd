
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity axi_accumulator_wrapper is
    port(
		clk   : in std_logic;
		reset : in std_logic;

		s_axis_tdata  : in std_logic_vector(7 downto 0);
		s_axis_tkeep  : in std_logic_vector(0 downto 0);
		s_axis_tlast  : in std_logic;
		s_axis_tready : out std_logic;
		s_axis_tvalid : in std_logic;

		m_axis_tdata  : out std_logic_vector(7 downto 0);
		m_axis_tkeep  : out std_logic_vector(0 downto 0);
		m_axis_tlast  : out std_logic;
		m_axis_tready : in std_logic;
		m_axis_tvalid : out std_logic;
		calculating: out std_logic
    );
end;

architecture bench of axi_accumulator_wrapper is
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
    m_axis_tvalid => m_axis_tvalid,
    calculating => calculating
  );
end;