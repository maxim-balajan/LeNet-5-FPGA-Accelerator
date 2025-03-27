-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1.2 (lin64) Build 5164865 Thu Sep  5 14:36:28 MDT 2024
-- Date        : Fri Feb 28 21:54:58 2025
-- Host        : hpenvy running 64-bit unknown
-- Command     : write_vhdl -force -mode funcsim
--               /home/markus/Documents/RADL/SW-Integration/Vivado/SW-Integration.gen/sources_1/bd/main_design/ip/main_design_axi_accumulator_wrap_0_0/main_design_axi_accumulator_wrap_0_0_sim_netlist.vhdl
-- Design      : main_design_axi_accumulator_wrap_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu3eg-sbva484-1-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity main_design_axi_accumulator_wrap_0_0_axi_accumulator is
  port (
    m_axis_tlast_reg_0 : out STD_LOGIC;
    s_calculating_reg_0 : out STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tready : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    reset : in STD_LOGIC;
    clk : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of main_design_axi_accumulator_wrap_0_0_axi_accumulator : entity is "axi_accumulator";
end main_design_axi_accumulator_wrap_0_0_axi_accumulator;

architecture STRUCTURE of main_design_axi_accumulator_wrap_0_0_axi_accumulator is
  signal \m_axis_tdata[7]_i_1_n_0\ : STD_LOGIC;
  signal m_axis_tlast_i_1_n_0 : STD_LOGIC;
  signal \^m_axis_tlast_reg_0\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s_accumulator : STD_LOGIC;
  signal s_accumulator0_carry_i_1_n_0 : STD_LOGIC;
  signal s_accumulator0_carry_i_2_n_0 : STD_LOGIC;
  signal s_accumulator0_carry_i_3_n_0 : STD_LOGIC;
  signal s_accumulator0_carry_i_4_n_0 : STD_LOGIC;
  signal s_accumulator0_carry_i_5_n_0 : STD_LOGIC;
  signal s_accumulator0_carry_i_6_n_0 : STD_LOGIC;
  signal s_accumulator0_carry_i_7_n_0 : STD_LOGIC;
  signal s_accumulator0_carry_i_8_n_0 : STD_LOGIC;
  signal s_accumulator0_carry_n_1 : STD_LOGIC;
  signal s_accumulator0_carry_n_2 : STD_LOGIC;
  signal s_accumulator0_carry_n_3 : STD_LOGIC;
  signal s_accumulator0_carry_n_4 : STD_LOGIC;
  signal s_accumulator0_carry_n_5 : STD_LOGIC;
  signal s_accumulator0_carry_n_6 : STD_LOGIC;
  signal s_accumulator0_carry_n_7 : STD_LOGIC;
  signal s_accumulator_reg : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s_calculating_i_1_n_0 : STD_LOGIC;
  signal \^s_calculating_reg_0\ : STD_LOGIC;
  signal s_m_axis_tvalid : STD_LOGIC;
  signal NLW_s_accumulator0_carry_CO_UNCONNECTED : STD_LOGIC_VECTOR ( 7 to 7 );
  attribute ADDER_THRESHOLD : integer;
  attribute ADDER_THRESHOLD of s_accumulator0_carry : label is 35;
begin
  m_axis_tlast_reg_0 <= \^m_axis_tlast_reg_0\;
  s_calculating_reg_0 <= \^s_calculating_reg_0\;
\m_axis_tdata[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0020"
    )
        port map (
      I0 => m_axis_tready,
      I1 => \^m_axis_tlast_reg_0\,
      I2 => \^s_calculating_reg_0\,
      I3 => s_axis_tvalid,
      O => \m_axis_tdata[7]_i_1_n_0\
    );
\m_axis_tdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator_reg(0),
      Q => m_axis_tdata(0),
      R => reset
    );
\m_axis_tdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator_reg(1),
      Q => m_axis_tdata(1),
      R => reset
    );
\m_axis_tdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator_reg(2),
      Q => m_axis_tdata(2),
      R => reset
    );
\m_axis_tdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator_reg(3),
      Q => m_axis_tdata(3),
      R => reset
    );
\m_axis_tdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator_reg(4),
      Q => m_axis_tdata(4),
      R => reset
    );
\m_axis_tdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator_reg(5),
      Q => m_axis_tdata(5),
      R => reset
    );
\m_axis_tdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator_reg(6),
      Q => m_axis_tdata(6),
      R => reset
    );
\m_axis_tdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator_reg(7),
      Q => m_axis_tdata(7),
      R => reset
    );
m_axis_tlast_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000CC2C"
    )
        port map (
      I0 => m_axis_tready,
      I1 => \^m_axis_tlast_reg_0\,
      I2 => \^s_calculating_reg_0\,
      I3 => s_axis_tvalid,
      I4 => reset,
      O => m_axis_tlast_i_1_n_0
    );
m_axis_tlast_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => m_axis_tlast_i_1_n_0,
      Q => \^m_axis_tlast_reg_0\,
      R => '0'
    );
s_accumulator0_carry: unisim.vcomponents.CARRY8
     port map (
      CI => '0',
      CI_TOP => '0',
      CO(7) => NLW_s_accumulator0_carry_CO_UNCONNECTED(7),
      CO(6) => s_accumulator0_carry_n_1,
      CO(5) => s_accumulator0_carry_n_2,
      CO(4) => s_accumulator0_carry_n_3,
      CO(3) => s_accumulator0_carry_n_4,
      CO(2) => s_accumulator0_carry_n_5,
      CO(1) => s_accumulator0_carry_n_6,
      CO(0) => s_accumulator0_carry_n_7,
      DI(7) => '0',
      DI(6 downto 0) => s_accumulator_reg(6 downto 0),
      O(7 downto 0) => p_0_in(7 downto 0),
      S(7) => s_accumulator0_carry_i_1_n_0,
      S(6) => s_accumulator0_carry_i_2_n_0,
      S(5) => s_accumulator0_carry_i_3_n_0,
      S(4) => s_accumulator0_carry_i_4_n_0,
      S(3) => s_accumulator0_carry_i_5_n_0,
      S(2) => s_accumulator0_carry_i_6_n_0,
      S(1) => s_accumulator0_carry_i_7_n_0,
      S(0) => s_accumulator0_carry_i_8_n_0
    );
s_accumulator0_carry_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => s_accumulator_reg(7),
      I1 => s_axis_tdata(7),
      O => s_accumulator0_carry_i_1_n_0
    );
s_accumulator0_carry_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => s_accumulator_reg(6),
      I1 => s_axis_tdata(6),
      O => s_accumulator0_carry_i_2_n_0
    );
s_accumulator0_carry_i_3: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => s_accumulator_reg(5),
      I1 => s_axis_tdata(5),
      O => s_accumulator0_carry_i_3_n_0
    );
s_accumulator0_carry_i_4: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => s_accumulator_reg(4),
      I1 => s_axis_tdata(4),
      O => s_accumulator0_carry_i_4_n_0
    );
s_accumulator0_carry_i_5: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => s_accumulator_reg(3),
      I1 => s_axis_tdata(3),
      O => s_accumulator0_carry_i_5_n_0
    );
s_accumulator0_carry_i_6: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => s_accumulator_reg(2),
      I1 => s_axis_tdata(2),
      O => s_accumulator0_carry_i_6_n_0
    );
s_accumulator0_carry_i_7: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => s_accumulator_reg(1),
      I1 => s_axis_tdata(1),
      O => s_accumulator0_carry_i_7_n_0
    );
s_accumulator0_carry_i_8: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => s_accumulator_reg(0),
      I1 => s_axis_tdata(0),
      O => s_accumulator0_carry_i_8_n_0
    );
\s_accumulator[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BAAA"
    )
        port map (
      I0 => reset,
      I1 => s_axis_tvalid,
      I2 => \^s_calculating_reg_0\,
      I3 => \^m_axis_tlast_reg_0\,
      O => s_m_axis_tvalid
    );
\s_accumulator[7]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axis_tvalid,
      I1 => s_axis_tkeep(0),
      O => s_accumulator
    );
\s_accumulator_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_accumulator,
      D => p_0_in(0),
      Q => s_accumulator_reg(0),
      R => s_m_axis_tvalid
    );
\s_accumulator_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_accumulator,
      D => p_0_in(1),
      Q => s_accumulator_reg(1),
      R => s_m_axis_tvalid
    );
\s_accumulator_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_accumulator,
      D => p_0_in(2),
      Q => s_accumulator_reg(2),
      R => s_m_axis_tvalid
    );
\s_accumulator_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_accumulator,
      D => p_0_in(3),
      Q => s_accumulator_reg(3),
      R => s_m_axis_tvalid
    );
\s_accumulator_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_accumulator,
      D => p_0_in(4),
      Q => s_accumulator_reg(4),
      R => s_m_axis_tvalid
    );
\s_accumulator_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_accumulator,
      D => p_0_in(5),
      Q => s_accumulator_reg(5),
      R => s_m_axis_tvalid
    );
\s_accumulator_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_accumulator,
      D => p_0_in(6),
      Q => s_accumulator_reg(6),
      R => s_m_axis_tvalid
    );
\s_accumulator_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_accumulator,
      D => p_0_in(7),
      Q => s_accumulator_reg(7),
      R => s_m_axis_tvalid
    );
s_axis_tready_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => '1',
      Q => s_axis_tready,
      R => reset
    );
s_calculating_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"BA"
    )
        port map (
      I0 => s_axis_tvalid,
      I1 => \^m_axis_tlast_reg_0\,
      I2 => \^s_calculating_reg_0\,
      O => s_calculating_i_1_n_0
    );
s_calculating_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => s_calculating_i_1_n_0,
      Q => \^s_calculating_reg_0\,
      R => reset
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity main_design_axi_accumulator_wrap_0_0_axi_accumulator_wrapper is
  port (
    m_axis_tlast_reg : out STD_LOGIC;
    s_calculating_reg : out STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tready : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    reset : in STD_LOGIC;
    clk : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of main_design_axi_accumulator_wrap_0_0_axi_accumulator_wrapper : entity is "axi_accumulator_wrapper";
end main_design_axi_accumulator_wrap_0_0_axi_accumulator_wrapper;

architecture STRUCTURE of main_design_axi_accumulator_wrap_0_0_axi_accumulator_wrapper is
begin
axi_accumulator_inst: entity work.main_design_axi_accumulator_wrap_0_0_axi_accumulator
     port map (
      clk => clk,
      m_axis_tdata(7 downto 0) => m_axis_tdata(7 downto 0),
      m_axis_tlast_reg_0 => m_axis_tlast_reg,
      m_axis_tready => m_axis_tready,
      reset => reset,
      s_axis_tdata(7 downto 0) => s_axis_tdata(7 downto 0),
      s_axis_tkeep(0) => s_axis_tkeep(0),
      s_axis_tready => s_axis_tready,
      s_axis_tvalid => s_axis_tvalid,
      s_calculating_reg_0 => s_calculating_reg
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity main_design_axi_accumulator_wrap_0_0 is
  port (
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tlast : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tlast : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    calculating : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of main_design_axi_accumulator_wrap_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of main_design_axi_accumulator_wrap_0_0 : entity is "main_design_axi_accumulator_wrap_0_0,axi_accumulator_wrapper,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of main_design_axi_accumulator_wrap_0_0 : entity is "yes";
  attribute ip_definition_source : string;
  attribute ip_definition_source of main_design_axi_accumulator_wrap_0_0 : entity is "module_ref";
  attribute x_core_info : string;
  attribute x_core_info of main_design_axi_accumulator_wrap_0_0 : entity is "axi_accumulator_wrapper,Vivado 2024.1.2";
end main_design_axi_accumulator_wrap_0_0;

architecture STRUCTURE of main_design_axi_accumulator_wrap_0_0 is
  signal \<const1>\ : STD_LOGIC;
  signal \^m_axis_tlast\ : STD_LOGIC;
  attribute x_interface_info : string;
  attribute x_interface_info of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of clk : signal is "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF m_axis:s_axis, ASSOCIATED_RESET reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN main_design_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute x_interface_info of m_axis_tlast : signal is "xilinx.com:interface:axis:1.0 m_axis TLAST";
  attribute x_interface_info of m_axis_tready : signal is "xilinx.com:interface:axis:1.0 m_axis TREADY";
  attribute x_interface_info of m_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 m_axis TVALID";
  attribute x_interface_info of reset : signal is "xilinx.com:signal:reset:1.0 reset RST";
  attribute x_interface_parameter of reset : signal is "XIL_INTERFACENAME reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0";
  attribute x_interface_info of s_axis_tlast : signal is "xilinx.com:interface:axis:1.0 s_axis TLAST";
  attribute x_interface_info of s_axis_tready : signal is "xilinx.com:interface:axis:1.0 s_axis TREADY";
  attribute x_interface_info of s_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 s_axis TVALID";
  attribute x_interface_info of m_axis_tdata : signal is "xilinx.com:interface:axis:1.0 m_axis TDATA";
  attribute x_interface_parameter of m_axis_tdata : signal is "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN main_design_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute x_interface_info of m_axis_tkeep : signal is "xilinx.com:interface:axis:1.0 m_axis TKEEP";
  attribute x_interface_info of s_axis_tdata : signal is "xilinx.com:interface:axis:1.0 s_axis TDATA";
  attribute x_interface_parameter of s_axis_tdata : signal is "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN main_design_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute x_interface_info of s_axis_tkeep : signal is "xilinx.com:interface:axis:1.0 s_axis TKEEP";
begin
  m_axis_tkeep(0) <= \<const1>\;
  m_axis_tlast <= \^m_axis_tlast\;
  m_axis_tvalid <= \^m_axis_tlast\;
U0: entity work.main_design_axi_accumulator_wrap_0_0_axi_accumulator_wrapper
     port map (
      clk => clk,
      m_axis_tdata(7 downto 0) => m_axis_tdata(7 downto 0),
      m_axis_tlast_reg => \^m_axis_tlast\,
      m_axis_tready => m_axis_tready,
      reset => reset,
      s_axis_tdata(7 downto 0) => s_axis_tdata(7 downto 0),
      s_axis_tkeep(0) => s_axis_tkeep(0),
      s_axis_tready => s_axis_tready,
      s_axis_tvalid => s_axis_tvalid,
      s_calculating_reg => calculating
    );
VCC: unisim.vcomponents.VCC
     port map (
      P => \<const1>\
    );
end STRUCTURE;
