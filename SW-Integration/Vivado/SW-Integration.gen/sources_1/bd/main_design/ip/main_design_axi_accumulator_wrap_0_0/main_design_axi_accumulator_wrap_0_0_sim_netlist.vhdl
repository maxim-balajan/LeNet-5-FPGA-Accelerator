-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1.2 (lin64) Build 5164865 Thu Sep  5 14:36:28 MDT 2024
-- Date        : Tue Feb 11 20:50:30 2025
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
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tready : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    clk : in STD_LOGIC;
    reset : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of main_design_axi_accumulator_wrap_0_0_axi_accumulator : entity is "axi_accumulator";
end main_design_axi_accumulator_wrap_0_0_axi_accumulator;

architecture STRUCTURE of main_design_axi_accumulator_wrap_0_0_axi_accumulator is
  signal \m_axis_tdata[7]_i_1_n_0\ : STD_LOGIC;
  signal \m_axis_tkeep[0]_i_1_n_0\ : STD_LOGIC;
  signal m_axis_tlast_i_1_n_0 : STD_LOGIC;
  signal \^m_axis_tlast_reg_0\ : STD_LOGIC;
  signal p_1_in : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s_accumulator : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \s_accumulator0__0_carry_i_10_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_11_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_12_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_13_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_14_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_15_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_1_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_2_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_3_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_4_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_5_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_6_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_7_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_8_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_i_9_n_0\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_1\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_10\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_11\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_12\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_13\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_14\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_15\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_2\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_3\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_4\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_5\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_6\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_7\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_8\ : STD_LOGIC;
  signal \s_accumulator0__0_carry_n_9\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_10_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_11_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_12_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_13_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_14_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_16_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_17_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_1_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_2_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_3_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_4_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_5_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_6_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_7_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_8_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_i_9_n_0\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_n_1\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_n_2\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_n_3\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_n_4\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_n_5\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_n_6\ : STD_LOGIC;
  signal \s_accumulator0__22_carry_n_7\ : STD_LOGIC;
  signal \s_accumulator[7]_i_1_n_0\ : STD_LOGIC;
  signal s_calculating_i_1_n_0 : STD_LOGIC;
  signal \^s_calculating_reg_0\ : STD_LOGIC;
  signal tmp : STD_LOGIC_VECTOR ( 7 downto 6 );
  signal \NLW_s_accumulator0__0_carry_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 to 7 );
  signal \NLW_s_accumulator0__22_carry_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 to 7 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of m_axis_tlast_i_1 : label is "soft_lutpair0";
  attribute ADDER_THRESHOLD : integer;
  attribute ADDER_THRESHOLD of \s_accumulator0__0_carry\ : label is 35;
  attribute HLUTNM : string;
  attribute HLUTNM of \s_accumulator0__0_carry_i_14\ : label is "lutpair0";
  attribute HLUTNM of \s_accumulator0__0_carry_i_6\ : label is "lutpair0";
  attribute ADDER_THRESHOLD of \s_accumulator0__22_carry\ : label is 35;
  attribute HLUTNM of \s_accumulator0__22_carry_i_14\ : label is "lutpair1";
  attribute SOFT_HLUTNM of \s_accumulator0__22_carry_i_15\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \s_accumulator0__22_carry_i_16\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \s_accumulator0__22_carry_i_17\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \s_accumulator0__22_carry_i_18\ : label is "soft_lutpair2";
  attribute HLUTNM of \s_accumulator0__22_carry_i_6\ : label is "lutpair1";
  attribute SOFT_HLUTNM of s_calculating_i_1 : label is "soft_lutpair0";
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
      D => s_accumulator(0),
      Q => m_axis_tdata(0),
      R => reset
    );
\m_axis_tdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator(1),
      Q => m_axis_tdata(1),
      R => reset
    );
\m_axis_tdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator(2),
      Q => m_axis_tdata(2),
      R => reset
    );
\m_axis_tdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator(3),
      Q => m_axis_tdata(3),
      R => reset
    );
\m_axis_tdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator(4),
      Q => m_axis_tdata(4),
      R => reset
    );
\m_axis_tdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator(5),
      Q => m_axis_tdata(5),
      R => reset
    );
\m_axis_tdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator(6),
      Q => m_axis_tdata(6),
      R => reset
    );
\m_axis_tdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => \m_axis_tdata[7]_i_1_n_0\,
      D => s_accumulator(7),
      Q => m_axis_tdata(7),
      R => reset
    );
\m_axis_tkeep[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => reset,
      O => \m_axis_tkeep[0]_i_1_n_0\
    );
\m_axis_tkeep_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \m_axis_tkeep[0]_i_1_n_0\,
      Q => m_axis_tkeep(0),
      R => '0'
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
\s_accumulator0__0_carry\: unisim.vcomponents.CARRY8
     port map (
      CI => '0',
      CI_TOP => '0',
      CO(7) => \NLW_s_accumulator0__0_carry_CO_UNCONNECTED\(7),
      CO(6) => \s_accumulator0__0_carry_n_1\,
      CO(5) => \s_accumulator0__0_carry_n_2\,
      CO(4) => \s_accumulator0__0_carry_n_3\,
      CO(3) => \s_accumulator0__0_carry_n_4\,
      CO(2) => \s_accumulator0__0_carry_n_5\,
      CO(1) => \s_accumulator0__0_carry_n_6\,
      CO(0) => \s_accumulator0__0_carry_n_7\,
      DI(7) => '0',
      DI(6) => \s_accumulator0__0_carry_i_1_n_0\,
      DI(5) => \s_accumulator0__0_carry_i_2_n_0\,
      DI(4) => \s_accumulator0__0_carry_i_3_n_0\,
      DI(3) => \s_accumulator0__0_carry_i_4_n_0\,
      DI(2) => \s_accumulator0__0_carry_i_5_n_0\,
      DI(1) => \s_accumulator0__0_carry_i_6_n_0\,
      DI(0) => '0',
      O(7) => \s_accumulator0__0_carry_n_8\,
      O(6) => \s_accumulator0__0_carry_n_9\,
      O(5) => \s_accumulator0__0_carry_n_10\,
      O(4) => \s_accumulator0__0_carry_n_11\,
      O(3) => \s_accumulator0__0_carry_n_12\,
      O(2) => \s_accumulator0__0_carry_n_13\,
      O(1) => \s_accumulator0__0_carry_n_14\,
      O(0) => \s_accumulator0__0_carry_n_15\,
      S(7) => \s_accumulator0__0_carry_i_7_n_0\,
      S(6) => \s_accumulator0__0_carry_i_8_n_0\,
      S(5) => \s_accumulator0__0_carry_i_9_n_0\,
      S(4) => \s_accumulator0__0_carry_i_10_n_0\,
      S(3) => \s_accumulator0__0_carry_i_11_n_0\,
      S(2) => \s_accumulator0__0_carry_i_12_n_0\,
      S(1) => \s_accumulator0__0_carry_i_13_n_0\,
      S(0) => \s_accumulator0__0_carry_i_14_n_0\
    );
\s_accumulator0__0_carry_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F8888000"
    )
        port map (
      I0 => s_axis_tdata(21),
      I1 => s_axis_tkeep(2),
      I2 => s_axis_tdata(29),
      I3 => s_axis_tkeep(3),
      I4 => s_accumulator(5),
      O => \s_accumulator0__0_carry_i_1_n_0\
    );
\s_accumulator0__0_carry_i_10\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A959595956A6A6A"
    )
        port map (
      I0 => \s_accumulator0__0_carry_i_3_n_0\,
      I1 => s_axis_tdata(28),
      I2 => s_axis_tkeep(3),
      I3 => s_axis_tdata(20),
      I4 => s_axis_tkeep(2),
      I5 => s_accumulator(4),
      O => \s_accumulator0__0_carry_i_10_n_0\
    );
\s_accumulator0__0_carry_i_11\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A959595956A6A6A"
    )
        port map (
      I0 => \s_accumulator0__0_carry_i_4_n_0\,
      I1 => s_axis_tdata(27),
      I2 => s_axis_tkeep(3),
      I3 => s_axis_tdata(19),
      I4 => s_axis_tkeep(2),
      I5 => s_accumulator(3),
      O => \s_accumulator0__0_carry_i_11_n_0\
    );
\s_accumulator0__0_carry_i_12\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A959595956A6A6A"
    )
        port map (
      I0 => \s_accumulator0__0_carry_i_5_n_0\,
      I1 => s_axis_tdata(26),
      I2 => s_axis_tkeep(3),
      I3 => s_axis_tdata(18),
      I4 => s_axis_tkeep(2),
      I5 => s_accumulator(2),
      O => \s_accumulator0__0_carry_i_12_n_0\
    );
\s_accumulator0__0_carry_i_13\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A959595956A6A6A"
    )
        port map (
      I0 => \s_accumulator0__0_carry_i_6_n_0\,
      I1 => s_axis_tdata(25),
      I2 => s_axis_tkeep(3),
      I3 => s_axis_tdata(17),
      I4 => s_axis_tkeep(2),
      I5 => s_accumulator(1),
      O => \s_accumulator0__0_carry_i_13_n_0\
    );
\s_accumulator0__0_carry_i_14\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"87777888"
    )
        port map (
      I0 => s_axis_tdata(16),
      I1 => s_axis_tkeep(2),
      I2 => s_axis_tdata(24),
      I3 => s_axis_tkeep(3),
      I4 => s_accumulator(0),
      O => \s_accumulator0__0_carry_i_14_n_0\
    );
\s_accumulator0__0_carry_i_15\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"956A6A6A"
    )
        port map (
      I0 => s_accumulator(7),
      I1 => s_axis_tkeep(2),
      I2 => s_axis_tdata(23),
      I3 => s_axis_tkeep(3),
      I4 => s_axis_tdata(31),
      O => \s_accumulator0__0_carry_i_15_n_0\
    );
\s_accumulator0__0_carry_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F8888000"
    )
        port map (
      I0 => s_axis_tdata(20),
      I1 => s_axis_tkeep(2),
      I2 => s_axis_tdata(28),
      I3 => s_axis_tkeep(3),
      I4 => s_accumulator(4),
      O => \s_accumulator0__0_carry_i_2_n_0\
    );
\s_accumulator0__0_carry_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F8888000"
    )
        port map (
      I0 => s_axis_tdata(19),
      I1 => s_axis_tkeep(2),
      I2 => s_axis_tdata(27),
      I3 => s_axis_tkeep(3),
      I4 => s_accumulator(3),
      O => \s_accumulator0__0_carry_i_3_n_0\
    );
\s_accumulator0__0_carry_i_4\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F8888000"
    )
        port map (
      I0 => s_axis_tdata(18),
      I1 => s_axis_tkeep(2),
      I2 => s_axis_tdata(26),
      I3 => s_axis_tkeep(3),
      I4 => s_accumulator(2),
      O => \s_accumulator0__0_carry_i_4_n_0\
    );
\s_accumulator0__0_carry_i_5\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F8888000"
    )
        port map (
      I0 => s_axis_tdata(17),
      I1 => s_axis_tkeep(2),
      I2 => s_axis_tdata(25),
      I3 => s_axis_tkeep(3),
      I4 => s_accumulator(1),
      O => \s_accumulator0__0_carry_i_5_n_0\
    );
\s_accumulator0__0_carry_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F8888000"
    )
        port map (
      I0 => s_axis_tdata(16),
      I1 => s_axis_tkeep(2),
      I2 => s_axis_tdata(24),
      I3 => s_axis_tkeep(3),
      I4 => s_accumulator(0),
      O => \s_accumulator0__0_carry_i_6_n_0\
    );
\s_accumulator0__0_carry_i_7\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"157F7F7FEA808080"
    )
        port map (
      I0 => s_accumulator(6),
      I1 => s_axis_tkeep(3),
      I2 => s_axis_tdata(30),
      I3 => s_axis_tkeep(2),
      I4 => s_axis_tdata(22),
      I5 => \s_accumulator0__0_carry_i_15_n_0\,
      O => \s_accumulator0__0_carry_i_7_n_0\
    );
\s_accumulator0__0_carry_i_8\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A959595956A6A6A"
    )
        port map (
      I0 => \s_accumulator0__0_carry_i_1_n_0\,
      I1 => s_axis_tdata(30),
      I2 => s_axis_tkeep(3),
      I3 => s_axis_tdata(22),
      I4 => s_axis_tkeep(2),
      I5 => s_accumulator(6),
      O => \s_accumulator0__0_carry_i_8_n_0\
    );
\s_accumulator0__0_carry_i_9\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A959595956A6A6A"
    )
        port map (
      I0 => \s_accumulator0__0_carry_i_2_n_0\,
      I1 => s_axis_tdata(29),
      I2 => s_axis_tkeep(3),
      I3 => s_axis_tdata(21),
      I4 => s_axis_tkeep(2),
      I5 => s_accumulator(5),
      O => \s_accumulator0__0_carry_i_9_n_0\
    );
\s_accumulator0__22_carry\: unisim.vcomponents.CARRY8
     port map (
      CI => '0',
      CI_TOP => '0',
      CO(7) => \NLW_s_accumulator0__22_carry_CO_UNCONNECTED\(7),
      CO(6) => \s_accumulator0__22_carry_n_1\,
      CO(5) => \s_accumulator0__22_carry_n_2\,
      CO(4) => \s_accumulator0__22_carry_n_3\,
      CO(3) => \s_accumulator0__22_carry_n_4\,
      CO(2) => \s_accumulator0__22_carry_n_5\,
      CO(1) => \s_accumulator0__22_carry_n_6\,
      CO(0) => \s_accumulator0__22_carry_n_7\,
      DI(7) => '0',
      DI(6) => \s_accumulator0__22_carry_i_1_n_0\,
      DI(5) => \s_accumulator0__22_carry_i_2_n_0\,
      DI(4) => \s_accumulator0__22_carry_i_3_n_0\,
      DI(3) => \s_accumulator0__22_carry_i_4_n_0\,
      DI(2) => \s_accumulator0__22_carry_i_5_n_0\,
      DI(1) => \s_accumulator0__22_carry_i_6_n_0\,
      DI(0) => '0',
      O(7 downto 0) => p_1_in(7 downto 0),
      S(7) => \s_accumulator0__22_carry_i_7_n_0\,
      S(6) => \s_accumulator0__22_carry_i_8_n_0\,
      S(5) => \s_accumulator0__22_carry_i_9_n_0\,
      S(4) => \s_accumulator0__22_carry_i_10_n_0\,
      S(3) => \s_accumulator0__22_carry_i_11_n_0\,
      S(2) => \s_accumulator0__22_carry_i_12_n_0\,
      S(1) => \s_accumulator0__22_carry_i_13_n_0\,
      S(0) => \s_accumulator0__22_carry_i_14_n_0\
    );
\s_accumulator0__22_carry_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EA808080"
    )
        port map (
      I0 => \s_accumulator0__0_carry_n_10\,
      I1 => s_axis_tdata(13),
      I2 => s_axis_tkeep(1),
      I3 => s_axis_tdata(5),
      I4 => s_axis_tkeep(0),
      O => \s_accumulator0__22_carry_i_1_n_0\
    );
\s_accumulator0__22_carry_i_10\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A95956A956A956A"
    )
        port map (
      I0 => \s_accumulator0__22_carry_i_3_n_0\,
      I1 => s_axis_tdata(12),
      I2 => s_axis_tkeep(1),
      I3 => \s_accumulator0__0_carry_n_11\,
      I4 => s_axis_tkeep(0),
      I5 => s_axis_tdata(4),
      O => \s_accumulator0__22_carry_i_10_n_0\
    );
\s_accumulator0__22_carry_i_11\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A95956A956A956A"
    )
        port map (
      I0 => \s_accumulator0__22_carry_i_4_n_0\,
      I1 => s_axis_tdata(11),
      I2 => s_axis_tkeep(1),
      I3 => \s_accumulator0__0_carry_n_12\,
      I4 => s_axis_tkeep(0),
      I5 => s_axis_tdata(3),
      O => \s_accumulator0__22_carry_i_11_n_0\
    );
\s_accumulator0__22_carry_i_12\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A95956A956A956A"
    )
        port map (
      I0 => \s_accumulator0__22_carry_i_5_n_0\,
      I1 => s_axis_tdata(10),
      I2 => s_axis_tkeep(1),
      I3 => \s_accumulator0__0_carry_n_13\,
      I4 => s_axis_tkeep(0),
      I5 => s_axis_tdata(2),
      O => \s_accumulator0__22_carry_i_12_n_0\
    );
\s_accumulator0__22_carry_i_13\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A95956A956A956A"
    )
        port map (
      I0 => \s_accumulator0__22_carry_i_6_n_0\,
      I1 => s_axis_tdata(9),
      I2 => s_axis_tkeep(1),
      I3 => \s_accumulator0__0_carry_n_14\,
      I4 => s_axis_tkeep(0),
      I5 => s_axis_tdata(1),
      O => \s_accumulator0__22_carry_i_13_n_0\
    );
\s_accumulator0__22_carry_i_14\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"956A6A6A"
    )
        port map (
      I0 => \s_accumulator0__0_carry_n_15\,
      I1 => s_axis_tdata(8),
      I2 => s_axis_tkeep(1),
      I3 => s_axis_tdata(0),
      I4 => s_axis_tkeep(0),
      O => \s_accumulator0__22_carry_i_14_n_0\
    );
\s_accumulator0__22_carry_i_15\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axis_tkeep(0),
      I1 => s_axis_tdata(6),
      O => tmp(6)
    );
\s_accumulator0__22_carry_i_16\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axis_tkeep(1),
      I1 => s_axis_tdata(14),
      O => \s_accumulator0__22_carry_i_16_n_0\
    );
\s_accumulator0__22_carry_i_17\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axis_tkeep(1),
      I1 => s_axis_tdata(15),
      O => \s_accumulator0__22_carry_i_17_n_0\
    );
\s_accumulator0__22_carry_i_18\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axis_tkeep(0),
      I1 => s_axis_tdata(7),
      O => tmp(7)
    );
\s_accumulator0__22_carry_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EA808080"
    )
        port map (
      I0 => \s_accumulator0__0_carry_n_11\,
      I1 => s_axis_tdata(12),
      I2 => s_axis_tkeep(1),
      I3 => s_axis_tdata(4),
      I4 => s_axis_tkeep(0),
      O => \s_accumulator0__22_carry_i_2_n_0\
    );
\s_accumulator0__22_carry_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EA808080"
    )
        port map (
      I0 => \s_accumulator0__0_carry_n_12\,
      I1 => s_axis_tdata(11),
      I2 => s_axis_tkeep(1),
      I3 => s_axis_tdata(3),
      I4 => s_axis_tkeep(0),
      O => \s_accumulator0__22_carry_i_3_n_0\
    );
\s_accumulator0__22_carry_i_4\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EA808080"
    )
        port map (
      I0 => \s_accumulator0__0_carry_n_13\,
      I1 => s_axis_tdata(10),
      I2 => s_axis_tkeep(1),
      I3 => s_axis_tdata(2),
      I4 => s_axis_tkeep(0),
      O => \s_accumulator0__22_carry_i_4_n_0\
    );
\s_accumulator0__22_carry_i_5\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EA808080"
    )
        port map (
      I0 => \s_accumulator0__0_carry_n_14\,
      I1 => s_axis_tdata(9),
      I2 => s_axis_tkeep(1),
      I3 => s_axis_tdata(1),
      I4 => s_axis_tkeep(0),
      O => \s_accumulator0__22_carry_i_5_n_0\
    );
\s_accumulator0__22_carry_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EA808080"
    )
        port map (
      I0 => \s_accumulator0__0_carry_n_15\,
      I1 => s_axis_tdata(8),
      I2 => s_axis_tkeep(1),
      I3 => s_axis_tdata(0),
      I4 => s_axis_tkeep(0),
      O => \s_accumulator0__22_carry_i_6_n_0\
    );
\s_accumulator0__22_carry_i_7\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"17E8E817E81717E8"
    )
        port map (
      I0 => tmp(6),
      I1 => \s_accumulator0__22_carry_i_16_n_0\,
      I2 => \s_accumulator0__0_carry_n_9\,
      I3 => \s_accumulator0__22_carry_i_17_n_0\,
      I4 => \s_accumulator0__0_carry_n_8\,
      I5 => tmp(7),
      O => \s_accumulator0__22_carry_i_7_n_0\
    );
\s_accumulator0__22_carry_i_8\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A95956A956A956A"
    )
        port map (
      I0 => \s_accumulator0__22_carry_i_1_n_0\,
      I1 => s_axis_tdata(14),
      I2 => s_axis_tkeep(1),
      I3 => \s_accumulator0__0_carry_n_9\,
      I4 => s_axis_tkeep(0),
      I5 => s_axis_tdata(6),
      O => \s_accumulator0__22_carry_i_8_n_0\
    );
\s_accumulator0__22_carry_i_9\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6A95956A956A956A"
    )
        port map (
      I0 => \s_accumulator0__22_carry_i_2_n_0\,
      I1 => s_axis_tdata(13),
      I2 => s_axis_tkeep(1),
      I3 => \s_accumulator0__0_carry_n_10\,
      I4 => s_axis_tkeep(0),
      I5 => s_axis_tdata(5),
      O => \s_accumulator0__22_carry_i_9_n_0\
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
      O => \s_accumulator[7]_i_1_n_0\
    );
\s_accumulator_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_axis_tvalid,
      D => p_1_in(0),
      Q => s_accumulator(0),
      R => \s_accumulator[7]_i_1_n_0\
    );
\s_accumulator_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_axis_tvalid,
      D => p_1_in(1),
      Q => s_accumulator(1),
      R => \s_accumulator[7]_i_1_n_0\
    );
\s_accumulator_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_axis_tvalid,
      D => p_1_in(2),
      Q => s_accumulator(2),
      R => \s_accumulator[7]_i_1_n_0\
    );
\s_accumulator_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_axis_tvalid,
      D => p_1_in(3),
      Q => s_accumulator(3),
      R => \s_accumulator[7]_i_1_n_0\
    );
\s_accumulator_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_axis_tvalid,
      D => p_1_in(4),
      Q => s_accumulator(4),
      R => \s_accumulator[7]_i_1_n_0\
    );
\s_accumulator_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_axis_tvalid,
      D => p_1_in(5),
      Q => s_accumulator(5),
      R => \s_accumulator[7]_i_1_n_0\
    );
\s_accumulator_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_axis_tvalid,
      D => p_1_in(6),
      Q => s_accumulator(6),
      R => \s_accumulator[7]_i_1_n_0\
    );
\s_accumulator_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => s_axis_tvalid,
      D => p_1_in(7),
      Q => s_accumulator(7),
      R => \s_accumulator[7]_i_1_n_0\
    );
s_calculating_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00F2"
    )
        port map (
      I0 => \^s_calculating_reg_0\,
      I1 => \^m_axis_tlast_reg_0\,
      I2 => s_axis_tvalid,
      I3 => reset,
      O => s_calculating_i_1_n_0
    );
s_calculating_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => s_calculating_i_1_n_0,
      Q => \^s_calculating_reg_0\,
      R => '0'
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
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tready : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    clk : in STD_LOGIC;
    reset : in STD_LOGIC
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
      m_axis_tkeep(0) => m_axis_tkeep(0),
      m_axis_tlast_reg_0 => m_axis_tlast_reg,
      m_axis_tready => m_axis_tready,
      reset => reset,
      s_axis_tdata(31 downto 0) => s_axis_tdata(31 downto 0),
      s_axis_tkeep(3 downto 0) => s_axis_tkeep(3 downto 0),
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
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
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
  signal \<const0>\ : STD_LOGIC;
  signal \^m_axis_tdata\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \^m_axis_tkeep\ : STD_LOGIC_VECTOR ( 0 to 0 );
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
  attribute x_interface_parameter of m_axis_tdata : signal is "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN main_design_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute x_interface_info of m_axis_tkeep : signal is "xilinx.com:interface:axis:1.0 m_axis TKEEP";
  attribute x_interface_info of s_axis_tdata : signal is "xilinx.com:interface:axis:1.0 s_axis TDATA";
  attribute x_interface_parameter of s_axis_tdata : signal is "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN main_design_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute x_interface_info of s_axis_tkeep : signal is "xilinx.com:interface:axis:1.0 s_axis TKEEP";
begin
  m_axis_tdata(31) <= \<const0>\;
  m_axis_tdata(30) <= \<const0>\;
  m_axis_tdata(29) <= \<const0>\;
  m_axis_tdata(28) <= \<const0>\;
  m_axis_tdata(27) <= \<const0>\;
  m_axis_tdata(26) <= \<const0>\;
  m_axis_tdata(25) <= \<const0>\;
  m_axis_tdata(24) <= \<const0>\;
  m_axis_tdata(23) <= \<const0>\;
  m_axis_tdata(22) <= \<const0>\;
  m_axis_tdata(21) <= \<const0>\;
  m_axis_tdata(20) <= \<const0>\;
  m_axis_tdata(19) <= \<const0>\;
  m_axis_tdata(18) <= \<const0>\;
  m_axis_tdata(17) <= \<const0>\;
  m_axis_tdata(16) <= \<const0>\;
  m_axis_tdata(15) <= \<const0>\;
  m_axis_tdata(14) <= \<const0>\;
  m_axis_tdata(13) <= \<const0>\;
  m_axis_tdata(12) <= \<const0>\;
  m_axis_tdata(11) <= \<const0>\;
  m_axis_tdata(10) <= \<const0>\;
  m_axis_tdata(9) <= \<const0>\;
  m_axis_tdata(8) <= \<const0>\;
  m_axis_tdata(7 downto 0) <= \^m_axis_tdata\(7 downto 0);
  m_axis_tkeep(3) <= \<const0>\;
  m_axis_tkeep(2) <= \<const0>\;
  m_axis_tkeep(1) <= \<const0>\;
  m_axis_tkeep(0) <= \^m_axis_tkeep\(0);
  m_axis_tlast <= \^m_axis_tlast\;
  m_axis_tvalid <= \^m_axis_tlast\;
  s_axis_tready <= \^m_axis_tkeep\(0);
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
U0: entity work.main_design_axi_accumulator_wrap_0_0_axi_accumulator_wrapper
     port map (
      clk => clk,
      m_axis_tdata(7 downto 0) => \^m_axis_tdata\(7 downto 0),
      m_axis_tkeep(0) => \^m_axis_tkeep\(0),
      m_axis_tlast_reg => \^m_axis_tlast\,
      m_axis_tready => m_axis_tready,
      reset => reset,
      s_axis_tdata(31 downto 0) => s_axis_tdata(31 downto 0),
      s_axis_tkeep(3 downto 0) => s_axis_tkeep(3 downto 0),
      s_axis_tvalid => s_axis_tvalid,
      s_calculating_reg => calculating
    );
end STRUCTURE;
