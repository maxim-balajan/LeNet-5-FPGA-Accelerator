// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1.2 (lin64) Build 5164865 Thu Sep  5 14:36:28 MDT 2024
// Date        : Tue Feb 11 20:50:30 2025
// Host        : hpenvy running 64-bit unknown
// Command     : write_verilog -force -mode funcsim
//               /home/markus/Documents/RADL/SW-Integration/Vivado/SW-Integration.gen/sources_1/bd/main_design/ip/main_design_axi_accumulator_wrap_0_0/main_design_axi_accumulator_wrap_0_0_sim_netlist.v
// Design      : main_design_axi_accumulator_wrap_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu3eg-sbva484-1-i
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "main_design_axi_accumulator_wrap_0_0,axi_accumulator_wrapper,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* ip_definition_source = "module_ref" *) 
(* x_core_info = "axi_accumulator_wrapper,Vivado 2024.1.2" *) 
(* NotValidForBitStream *)
module main_design_axi_accumulator_wrap_0_0
   (clk,
    reset,
    s_axis_tdata,
    s_axis_tkeep,
    s_axis_tlast,
    s_axis_tready,
    s_axis_tvalid,
    m_axis_tdata,
    m_axis_tkeep,
    m_axis_tlast,
    m_axis_tready,
    m_axis_tvalid,
    calculating);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF m_axis:s_axis, ASSOCIATED_RESET reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN main_design_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input clk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 reset RST" *) (* x_interface_parameter = "XIL_INTERFACENAME reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input reset;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TDATA" *) (* x_interface_parameter = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN main_design_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TKEEP" *) input [3:0]s_axis_tkeep;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TLAST" *) input s_axis_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TREADY" *) output s_axis_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TVALID" *) input s_axis_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TDATA" *) (* x_interface_parameter = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN main_design_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [31:0]m_axis_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TKEEP" *) output [3:0]m_axis_tkeep;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TLAST" *) output m_axis_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TREADY" *) input m_axis_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TVALID" *) output m_axis_tvalid;
  output calculating;

  wire \<const0> ;
  wire calculating;
  wire clk;
  wire [7:0]\^m_axis_tdata ;
  wire [0:0]\^m_axis_tkeep ;
  wire m_axis_tlast;
  wire m_axis_tready;
  wire reset;
  wire [31:0]s_axis_tdata;
  wire [3:0]s_axis_tkeep;
  wire s_axis_tvalid;

  assign m_axis_tdata[31] = \<const0> ;
  assign m_axis_tdata[30] = \<const0> ;
  assign m_axis_tdata[29] = \<const0> ;
  assign m_axis_tdata[28] = \<const0> ;
  assign m_axis_tdata[27] = \<const0> ;
  assign m_axis_tdata[26] = \<const0> ;
  assign m_axis_tdata[25] = \<const0> ;
  assign m_axis_tdata[24] = \<const0> ;
  assign m_axis_tdata[23] = \<const0> ;
  assign m_axis_tdata[22] = \<const0> ;
  assign m_axis_tdata[21] = \<const0> ;
  assign m_axis_tdata[20] = \<const0> ;
  assign m_axis_tdata[19] = \<const0> ;
  assign m_axis_tdata[18] = \<const0> ;
  assign m_axis_tdata[17] = \<const0> ;
  assign m_axis_tdata[16] = \<const0> ;
  assign m_axis_tdata[15] = \<const0> ;
  assign m_axis_tdata[14] = \<const0> ;
  assign m_axis_tdata[13] = \<const0> ;
  assign m_axis_tdata[12] = \<const0> ;
  assign m_axis_tdata[11] = \<const0> ;
  assign m_axis_tdata[10] = \<const0> ;
  assign m_axis_tdata[9] = \<const0> ;
  assign m_axis_tdata[8] = \<const0> ;
  assign m_axis_tdata[7:0] = \^m_axis_tdata [7:0];
  assign m_axis_tkeep[3] = \<const0> ;
  assign m_axis_tkeep[2] = \<const0> ;
  assign m_axis_tkeep[1] = \<const0> ;
  assign m_axis_tkeep[0] = \^m_axis_tkeep [0];
  assign m_axis_tvalid = m_axis_tlast;
  assign s_axis_tready = \^m_axis_tkeep [0];
  GND GND
       (.G(\<const0> ));
  main_design_axi_accumulator_wrap_0_0_axi_accumulator_wrapper U0
       (.clk(clk),
        .m_axis_tdata(\^m_axis_tdata ),
        .m_axis_tkeep(\^m_axis_tkeep ),
        .m_axis_tlast_reg(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .reset(reset),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tvalid(s_axis_tvalid),
        .s_calculating_reg(calculating));
endmodule

(* ORIG_REF_NAME = "axi_accumulator" *) 
module main_design_axi_accumulator_wrap_0_0_axi_accumulator
   (m_axis_tlast_reg_0,
    s_calculating_reg_0,
    m_axis_tkeep,
    m_axis_tdata,
    m_axis_tready,
    s_axis_tvalid,
    s_axis_tkeep,
    s_axis_tdata,
    clk,
    reset);
  output m_axis_tlast_reg_0;
  output s_calculating_reg_0;
  output [0:0]m_axis_tkeep;
  output [7:0]m_axis_tdata;
  input m_axis_tready;
  input s_axis_tvalid;
  input [3:0]s_axis_tkeep;
  input [31:0]s_axis_tdata;
  input clk;
  input reset;

  wire clk;
  wire [7:0]m_axis_tdata;
  wire \m_axis_tdata[7]_i_1_n_0 ;
  wire [0:0]m_axis_tkeep;
  wire \m_axis_tkeep[0]_i_1_n_0 ;
  wire m_axis_tlast_i_1_n_0;
  wire m_axis_tlast_reg_0;
  wire m_axis_tready;
  wire [7:0]p_1_in;
  wire reset;
  wire [7:0]s_accumulator;
  wire s_accumulator0__0_carry_i_10_n_0;
  wire s_accumulator0__0_carry_i_11_n_0;
  wire s_accumulator0__0_carry_i_12_n_0;
  wire s_accumulator0__0_carry_i_13_n_0;
  wire s_accumulator0__0_carry_i_14_n_0;
  wire s_accumulator0__0_carry_i_15_n_0;
  wire s_accumulator0__0_carry_i_1_n_0;
  wire s_accumulator0__0_carry_i_2_n_0;
  wire s_accumulator0__0_carry_i_3_n_0;
  wire s_accumulator0__0_carry_i_4_n_0;
  wire s_accumulator0__0_carry_i_5_n_0;
  wire s_accumulator0__0_carry_i_6_n_0;
  wire s_accumulator0__0_carry_i_7_n_0;
  wire s_accumulator0__0_carry_i_8_n_0;
  wire s_accumulator0__0_carry_i_9_n_0;
  wire s_accumulator0__0_carry_n_1;
  wire s_accumulator0__0_carry_n_10;
  wire s_accumulator0__0_carry_n_11;
  wire s_accumulator0__0_carry_n_12;
  wire s_accumulator0__0_carry_n_13;
  wire s_accumulator0__0_carry_n_14;
  wire s_accumulator0__0_carry_n_15;
  wire s_accumulator0__0_carry_n_2;
  wire s_accumulator0__0_carry_n_3;
  wire s_accumulator0__0_carry_n_4;
  wire s_accumulator0__0_carry_n_5;
  wire s_accumulator0__0_carry_n_6;
  wire s_accumulator0__0_carry_n_7;
  wire s_accumulator0__0_carry_n_8;
  wire s_accumulator0__0_carry_n_9;
  wire s_accumulator0__22_carry_i_10_n_0;
  wire s_accumulator0__22_carry_i_11_n_0;
  wire s_accumulator0__22_carry_i_12_n_0;
  wire s_accumulator0__22_carry_i_13_n_0;
  wire s_accumulator0__22_carry_i_14_n_0;
  wire s_accumulator0__22_carry_i_16_n_0;
  wire s_accumulator0__22_carry_i_17_n_0;
  wire s_accumulator0__22_carry_i_1_n_0;
  wire s_accumulator0__22_carry_i_2_n_0;
  wire s_accumulator0__22_carry_i_3_n_0;
  wire s_accumulator0__22_carry_i_4_n_0;
  wire s_accumulator0__22_carry_i_5_n_0;
  wire s_accumulator0__22_carry_i_6_n_0;
  wire s_accumulator0__22_carry_i_7_n_0;
  wire s_accumulator0__22_carry_i_8_n_0;
  wire s_accumulator0__22_carry_i_9_n_0;
  wire s_accumulator0__22_carry_n_1;
  wire s_accumulator0__22_carry_n_2;
  wire s_accumulator0__22_carry_n_3;
  wire s_accumulator0__22_carry_n_4;
  wire s_accumulator0__22_carry_n_5;
  wire s_accumulator0__22_carry_n_6;
  wire s_accumulator0__22_carry_n_7;
  wire \s_accumulator[7]_i_1_n_0 ;
  wire [31:0]s_axis_tdata;
  wire [3:0]s_axis_tkeep;
  wire s_axis_tvalid;
  wire s_calculating_i_1_n_0;
  wire s_calculating_reg_0;
  wire [7:6]tmp;
  wire [7:7]NLW_s_accumulator0__0_carry_CO_UNCONNECTED;
  wire [7:7]NLW_s_accumulator0__22_carry_CO_UNCONNECTED;

  LUT4 #(
    .INIT(16'h0020)) 
    \m_axis_tdata[7]_i_1 
       (.I0(m_axis_tready),
        .I1(m_axis_tlast_reg_0),
        .I2(s_calculating_reg_0),
        .I3(s_axis_tvalid),
        .O(\m_axis_tdata[7]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[0] 
       (.C(clk),
        .CE(\m_axis_tdata[7]_i_1_n_0 ),
        .D(s_accumulator[0]),
        .Q(m_axis_tdata[0]),
        .R(reset));
  FDRE \m_axis_tdata_reg[1] 
       (.C(clk),
        .CE(\m_axis_tdata[7]_i_1_n_0 ),
        .D(s_accumulator[1]),
        .Q(m_axis_tdata[1]),
        .R(reset));
  FDRE \m_axis_tdata_reg[2] 
       (.C(clk),
        .CE(\m_axis_tdata[7]_i_1_n_0 ),
        .D(s_accumulator[2]),
        .Q(m_axis_tdata[2]),
        .R(reset));
  FDRE \m_axis_tdata_reg[3] 
       (.C(clk),
        .CE(\m_axis_tdata[7]_i_1_n_0 ),
        .D(s_accumulator[3]),
        .Q(m_axis_tdata[3]),
        .R(reset));
  FDRE \m_axis_tdata_reg[4] 
       (.C(clk),
        .CE(\m_axis_tdata[7]_i_1_n_0 ),
        .D(s_accumulator[4]),
        .Q(m_axis_tdata[4]),
        .R(reset));
  FDRE \m_axis_tdata_reg[5] 
       (.C(clk),
        .CE(\m_axis_tdata[7]_i_1_n_0 ),
        .D(s_accumulator[5]),
        .Q(m_axis_tdata[5]),
        .R(reset));
  FDRE \m_axis_tdata_reg[6] 
       (.C(clk),
        .CE(\m_axis_tdata[7]_i_1_n_0 ),
        .D(s_accumulator[6]),
        .Q(m_axis_tdata[6]),
        .R(reset));
  FDRE \m_axis_tdata_reg[7] 
       (.C(clk),
        .CE(\m_axis_tdata[7]_i_1_n_0 ),
        .D(s_accumulator[7]),
        .Q(m_axis_tdata[7]),
        .R(reset));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tkeep[0]_i_1 
       (.I0(reset),
        .O(\m_axis_tkeep[0]_i_1_n_0 ));
  FDRE \m_axis_tkeep_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\m_axis_tkeep[0]_i_1_n_0 ),
        .Q(m_axis_tkeep),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h0000CC2C)) 
    m_axis_tlast_i_1
       (.I0(m_axis_tready),
        .I1(m_axis_tlast_reg_0),
        .I2(s_calculating_reg_0),
        .I3(s_axis_tvalid),
        .I4(reset),
        .O(m_axis_tlast_i_1_n_0));
  FDRE m_axis_tlast_reg
       (.C(clk),
        .CE(1'b1),
        .D(m_axis_tlast_i_1_n_0),
        .Q(m_axis_tlast_reg_0),
        .R(1'b0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY8 s_accumulator0__0_carry
       (.CI(1'b0),
        .CI_TOP(1'b0),
        .CO({NLW_s_accumulator0__0_carry_CO_UNCONNECTED[7],s_accumulator0__0_carry_n_1,s_accumulator0__0_carry_n_2,s_accumulator0__0_carry_n_3,s_accumulator0__0_carry_n_4,s_accumulator0__0_carry_n_5,s_accumulator0__0_carry_n_6,s_accumulator0__0_carry_n_7}),
        .DI({1'b0,s_accumulator0__0_carry_i_1_n_0,s_accumulator0__0_carry_i_2_n_0,s_accumulator0__0_carry_i_3_n_0,s_accumulator0__0_carry_i_4_n_0,s_accumulator0__0_carry_i_5_n_0,s_accumulator0__0_carry_i_6_n_0,1'b0}),
        .O({s_accumulator0__0_carry_n_8,s_accumulator0__0_carry_n_9,s_accumulator0__0_carry_n_10,s_accumulator0__0_carry_n_11,s_accumulator0__0_carry_n_12,s_accumulator0__0_carry_n_13,s_accumulator0__0_carry_n_14,s_accumulator0__0_carry_n_15}),
        .S({s_accumulator0__0_carry_i_7_n_0,s_accumulator0__0_carry_i_8_n_0,s_accumulator0__0_carry_i_9_n_0,s_accumulator0__0_carry_i_10_n_0,s_accumulator0__0_carry_i_11_n_0,s_accumulator0__0_carry_i_12_n_0,s_accumulator0__0_carry_i_13_n_0,s_accumulator0__0_carry_i_14_n_0}));
  LUT5 #(
    .INIT(32'hF8888000)) 
    s_accumulator0__0_carry_i_1
       (.I0(s_axis_tdata[21]),
        .I1(s_axis_tkeep[2]),
        .I2(s_axis_tdata[29]),
        .I3(s_axis_tkeep[3]),
        .I4(s_accumulator[5]),
        .O(s_accumulator0__0_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    s_accumulator0__0_carry_i_10
       (.I0(s_accumulator0__0_carry_i_3_n_0),
        .I1(s_axis_tdata[28]),
        .I2(s_axis_tkeep[3]),
        .I3(s_axis_tdata[20]),
        .I4(s_axis_tkeep[2]),
        .I5(s_accumulator[4]),
        .O(s_accumulator0__0_carry_i_10_n_0));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    s_accumulator0__0_carry_i_11
       (.I0(s_accumulator0__0_carry_i_4_n_0),
        .I1(s_axis_tdata[27]),
        .I2(s_axis_tkeep[3]),
        .I3(s_axis_tdata[19]),
        .I4(s_axis_tkeep[2]),
        .I5(s_accumulator[3]),
        .O(s_accumulator0__0_carry_i_11_n_0));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    s_accumulator0__0_carry_i_12
       (.I0(s_accumulator0__0_carry_i_5_n_0),
        .I1(s_axis_tdata[26]),
        .I2(s_axis_tkeep[3]),
        .I3(s_axis_tdata[18]),
        .I4(s_axis_tkeep[2]),
        .I5(s_accumulator[2]),
        .O(s_accumulator0__0_carry_i_12_n_0));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    s_accumulator0__0_carry_i_13
       (.I0(s_accumulator0__0_carry_i_6_n_0),
        .I1(s_axis_tdata[25]),
        .I2(s_axis_tkeep[3]),
        .I3(s_axis_tdata[17]),
        .I4(s_axis_tkeep[2]),
        .I5(s_accumulator[1]),
        .O(s_accumulator0__0_carry_i_13_n_0));
  (* HLUTNM = "lutpair0" *) 
  LUT5 #(
    .INIT(32'h87777888)) 
    s_accumulator0__0_carry_i_14
       (.I0(s_axis_tdata[16]),
        .I1(s_axis_tkeep[2]),
        .I2(s_axis_tdata[24]),
        .I3(s_axis_tkeep[3]),
        .I4(s_accumulator[0]),
        .O(s_accumulator0__0_carry_i_14_n_0));
  LUT5 #(
    .INIT(32'h956A6A6A)) 
    s_accumulator0__0_carry_i_15
       (.I0(s_accumulator[7]),
        .I1(s_axis_tkeep[2]),
        .I2(s_axis_tdata[23]),
        .I3(s_axis_tkeep[3]),
        .I4(s_axis_tdata[31]),
        .O(s_accumulator0__0_carry_i_15_n_0));
  LUT5 #(
    .INIT(32'hF8888000)) 
    s_accumulator0__0_carry_i_2
       (.I0(s_axis_tdata[20]),
        .I1(s_axis_tkeep[2]),
        .I2(s_axis_tdata[28]),
        .I3(s_axis_tkeep[3]),
        .I4(s_accumulator[4]),
        .O(s_accumulator0__0_carry_i_2_n_0));
  LUT5 #(
    .INIT(32'hF8888000)) 
    s_accumulator0__0_carry_i_3
       (.I0(s_axis_tdata[19]),
        .I1(s_axis_tkeep[2]),
        .I2(s_axis_tdata[27]),
        .I3(s_axis_tkeep[3]),
        .I4(s_accumulator[3]),
        .O(s_accumulator0__0_carry_i_3_n_0));
  LUT5 #(
    .INIT(32'hF8888000)) 
    s_accumulator0__0_carry_i_4
       (.I0(s_axis_tdata[18]),
        .I1(s_axis_tkeep[2]),
        .I2(s_axis_tdata[26]),
        .I3(s_axis_tkeep[3]),
        .I4(s_accumulator[2]),
        .O(s_accumulator0__0_carry_i_4_n_0));
  LUT5 #(
    .INIT(32'hF8888000)) 
    s_accumulator0__0_carry_i_5
       (.I0(s_axis_tdata[17]),
        .I1(s_axis_tkeep[2]),
        .I2(s_axis_tdata[25]),
        .I3(s_axis_tkeep[3]),
        .I4(s_accumulator[1]),
        .O(s_accumulator0__0_carry_i_5_n_0));
  (* HLUTNM = "lutpair0" *) 
  LUT5 #(
    .INIT(32'hF8888000)) 
    s_accumulator0__0_carry_i_6
       (.I0(s_axis_tdata[16]),
        .I1(s_axis_tkeep[2]),
        .I2(s_axis_tdata[24]),
        .I3(s_axis_tkeep[3]),
        .I4(s_accumulator[0]),
        .O(s_accumulator0__0_carry_i_6_n_0));
  LUT6 #(
    .INIT(64'h157F7F7FEA808080)) 
    s_accumulator0__0_carry_i_7
       (.I0(s_accumulator[6]),
        .I1(s_axis_tkeep[3]),
        .I2(s_axis_tdata[30]),
        .I3(s_axis_tkeep[2]),
        .I4(s_axis_tdata[22]),
        .I5(s_accumulator0__0_carry_i_15_n_0),
        .O(s_accumulator0__0_carry_i_7_n_0));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    s_accumulator0__0_carry_i_8
       (.I0(s_accumulator0__0_carry_i_1_n_0),
        .I1(s_axis_tdata[30]),
        .I2(s_axis_tkeep[3]),
        .I3(s_axis_tdata[22]),
        .I4(s_axis_tkeep[2]),
        .I5(s_accumulator[6]),
        .O(s_accumulator0__0_carry_i_8_n_0));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    s_accumulator0__0_carry_i_9
       (.I0(s_accumulator0__0_carry_i_2_n_0),
        .I1(s_axis_tdata[29]),
        .I2(s_axis_tkeep[3]),
        .I3(s_axis_tdata[21]),
        .I4(s_axis_tkeep[2]),
        .I5(s_accumulator[5]),
        .O(s_accumulator0__0_carry_i_9_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY8 s_accumulator0__22_carry
       (.CI(1'b0),
        .CI_TOP(1'b0),
        .CO({NLW_s_accumulator0__22_carry_CO_UNCONNECTED[7],s_accumulator0__22_carry_n_1,s_accumulator0__22_carry_n_2,s_accumulator0__22_carry_n_3,s_accumulator0__22_carry_n_4,s_accumulator0__22_carry_n_5,s_accumulator0__22_carry_n_6,s_accumulator0__22_carry_n_7}),
        .DI({1'b0,s_accumulator0__22_carry_i_1_n_0,s_accumulator0__22_carry_i_2_n_0,s_accumulator0__22_carry_i_3_n_0,s_accumulator0__22_carry_i_4_n_0,s_accumulator0__22_carry_i_5_n_0,s_accumulator0__22_carry_i_6_n_0,1'b0}),
        .O(p_1_in),
        .S({s_accumulator0__22_carry_i_7_n_0,s_accumulator0__22_carry_i_8_n_0,s_accumulator0__22_carry_i_9_n_0,s_accumulator0__22_carry_i_10_n_0,s_accumulator0__22_carry_i_11_n_0,s_accumulator0__22_carry_i_12_n_0,s_accumulator0__22_carry_i_13_n_0,s_accumulator0__22_carry_i_14_n_0}));
  LUT5 #(
    .INIT(32'hEA808080)) 
    s_accumulator0__22_carry_i_1
       (.I0(s_accumulator0__0_carry_n_10),
        .I1(s_axis_tdata[13]),
        .I2(s_axis_tkeep[1]),
        .I3(s_axis_tdata[5]),
        .I4(s_axis_tkeep[0]),
        .O(s_accumulator0__22_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'h6A95956A956A956A)) 
    s_accumulator0__22_carry_i_10
       (.I0(s_accumulator0__22_carry_i_3_n_0),
        .I1(s_axis_tdata[12]),
        .I2(s_axis_tkeep[1]),
        .I3(s_accumulator0__0_carry_n_11),
        .I4(s_axis_tkeep[0]),
        .I5(s_axis_tdata[4]),
        .O(s_accumulator0__22_carry_i_10_n_0));
  LUT6 #(
    .INIT(64'h6A95956A956A956A)) 
    s_accumulator0__22_carry_i_11
       (.I0(s_accumulator0__22_carry_i_4_n_0),
        .I1(s_axis_tdata[11]),
        .I2(s_axis_tkeep[1]),
        .I3(s_accumulator0__0_carry_n_12),
        .I4(s_axis_tkeep[0]),
        .I5(s_axis_tdata[3]),
        .O(s_accumulator0__22_carry_i_11_n_0));
  LUT6 #(
    .INIT(64'h6A95956A956A956A)) 
    s_accumulator0__22_carry_i_12
       (.I0(s_accumulator0__22_carry_i_5_n_0),
        .I1(s_axis_tdata[10]),
        .I2(s_axis_tkeep[1]),
        .I3(s_accumulator0__0_carry_n_13),
        .I4(s_axis_tkeep[0]),
        .I5(s_axis_tdata[2]),
        .O(s_accumulator0__22_carry_i_12_n_0));
  LUT6 #(
    .INIT(64'h6A95956A956A956A)) 
    s_accumulator0__22_carry_i_13
       (.I0(s_accumulator0__22_carry_i_6_n_0),
        .I1(s_axis_tdata[9]),
        .I2(s_axis_tkeep[1]),
        .I3(s_accumulator0__0_carry_n_14),
        .I4(s_axis_tkeep[0]),
        .I5(s_axis_tdata[1]),
        .O(s_accumulator0__22_carry_i_13_n_0));
  (* HLUTNM = "lutpair1" *) 
  LUT5 #(
    .INIT(32'h956A6A6A)) 
    s_accumulator0__22_carry_i_14
       (.I0(s_accumulator0__0_carry_n_15),
        .I1(s_axis_tdata[8]),
        .I2(s_axis_tkeep[1]),
        .I3(s_axis_tdata[0]),
        .I4(s_axis_tkeep[0]),
        .O(s_accumulator0__22_carry_i_14_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    s_accumulator0__22_carry_i_15
       (.I0(s_axis_tkeep[0]),
        .I1(s_axis_tdata[6]),
        .O(tmp[6]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h8)) 
    s_accumulator0__22_carry_i_16
       (.I0(s_axis_tkeep[1]),
        .I1(s_axis_tdata[14]),
        .O(s_accumulator0__22_carry_i_16_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h8)) 
    s_accumulator0__22_carry_i_17
       (.I0(s_axis_tkeep[1]),
        .I1(s_axis_tdata[15]),
        .O(s_accumulator0__22_carry_i_17_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    s_accumulator0__22_carry_i_18
       (.I0(s_axis_tkeep[0]),
        .I1(s_axis_tdata[7]),
        .O(tmp[7]));
  LUT5 #(
    .INIT(32'hEA808080)) 
    s_accumulator0__22_carry_i_2
       (.I0(s_accumulator0__0_carry_n_11),
        .I1(s_axis_tdata[12]),
        .I2(s_axis_tkeep[1]),
        .I3(s_axis_tdata[4]),
        .I4(s_axis_tkeep[0]),
        .O(s_accumulator0__22_carry_i_2_n_0));
  LUT5 #(
    .INIT(32'hEA808080)) 
    s_accumulator0__22_carry_i_3
       (.I0(s_accumulator0__0_carry_n_12),
        .I1(s_axis_tdata[11]),
        .I2(s_axis_tkeep[1]),
        .I3(s_axis_tdata[3]),
        .I4(s_axis_tkeep[0]),
        .O(s_accumulator0__22_carry_i_3_n_0));
  LUT5 #(
    .INIT(32'hEA808080)) 
    s_accumulator0__22_carry_i_4
       (.I0(s_accumulator0__0_carry_n_13),
        .I1(s_axis_tdata[10]),
        .I2(s_axis_tkeep[1]),
        .I3(s_axis_tdata[2]),
        .I4(s_axis_tkeep[0]),
        .O(s_accumulator0__22_carry_i_4_n_0));
  LUT5 #(
    .INIT(32'hEA808080)) 
    s_accumulator0__22_carry_i_5
       (.I0(s_accumulator0__0_carry_n_14),
        .I1(s_axis_tdata[9]),
        .I2(s_axis_tkeep[1]),
        .I3(s_axis_tdata[1]),
        .I4(s_axis_tkeep[0]),
        .O(s_accumulator0__22_carry_i_5_n_0));
  (* HLUTNM = "lutpair1" *) 
  LUT5 #(
    .INIT(32'hEA808080)) 
    s_accumulator0__22_carry_i_6
       (.I0(s_accumulator0__0_carry_n_15),
        .I1(s_axis_tdata[8]),
        .I2(s_axis_tkeep[1]),
        .I3(s_axis_tdata[0]),
        .I4(s_axis_tkeep[0]),
        .O(s_accumulator0__22_carry_i_6_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    s_accumulator0__22_carry_i_7
       (.I0(tmp[6]),
        .I1(s_accumulator0__22_carry_i_16_n_0),
        .I2(s_accumulator0__0_carry_n_9),
        .I3(s_accumulator0__22_carry_i_17_n_0),
        .I4(s_accumulator0__0_carry_n_8),
        .I5(tmp[7]),
        .O(s_accumulator0__22_carry_i_7_n_0));
  LUT6 #(
    .INIT(64'h6A95956A956A956A)) 
    s_accumulator0__22_carry_i_8
       (.I0(s_accumulator0__22_carry_i_1_n_0),
        .I1(s_axis_tdata[14]),
        .I2(s_axis_tkeep[1]),
        .I3(s_accumulator0__0_carry_n_9),
        .I4(s_axis_tkeep[0]),
        .I5(s_axis_tdata[6]),
        .O(s_accumulator0__22_carry_i_8_n_0));
  LUT6 #(
    .INIT(64'h6A95956A956A956A)) 
    s_accumulator0__22_carry_i_9
       (.I0(s_accumulator0__22_carry_i_2_n_0),
        .I1(s_axis_tdata[13]),
        .I2(s_axis_tkeep[1]),
        .I3(s_accumulator0__0_carry_n_10),
        .I4(s_axis_tkeep[0]),
        .I5(s_axis_tdata[5]),
        .O(s_accumulator0__22_carry_i_9_n_0));
  LUT4 #(
    .INIT(16'hBAAA)) 
    \s_accumulator[7]_i_1 
       (.I0(reset),
        .I1(s_axis_tvalid),
        .I2(s_calculating_reg_0),
        .I3(m_axis_tlast_reg_0),
        .O(\s_accumulator[7]_i_1_n_0 ));
  FDRE \s_accumulator_reg[0] 
       (.C(clk),
        .CE(s_axis_tvalid),
        .D(p_1_in[0]),
        .Q(s_accumulator[0]),
        .R(\s_accumulator[7]_i_1_n_0 ));
  FDRE \s_accumulator_reg[1] 
       (.C(clk),
        .CE(s_axis_tvalid),
        .D(p_1_in[1]),
        .Q(s_accumulator[1]),
        .R(\s_accumulator[7]_i_1_n_0 ));
  FDRE \s_accumulator_reg[2] 
       (.C(clk),
        .CE(s_axis_tvalid),
        .D(p_1_in[2]),
        .Q(s_accumulator[2]),
        .R(\s_accumulator[7]_i_1_n_0 ));
  FDRE \s_accumulator_reg[3] 
       (.C(clk),
        .CE(s_axis_tvalid),
        .D(p_1_in[3]),
        .Q(s_accumulator[3]),
        .R(\s_accumulator[7]_i_1_n_0 ));
  FDRE \s_accumulator_reg[4] 
       (.C(clk),
        .CE(s_axis_tvalid),
        .D(p_1_in[4]),
        .Q(s_accumulator[4]),
        .R(\s_accumulator[7]_i_1_n_0 ));
  FDRE \s_accumulator_reg[5] 
       (.C(clk),
        .CE(s_axis_tvalid),
        .D(p_1_in[5]),
        .Q(s_accumulator[5]),
        .R(\s_accumulator[7]_i_1_n_0 ));
  FDRE \s_accumulator_reg[6] 
       (.C(clk),
        .CE(s_axis_tvalid),
        .D(p_1_in[6]),
        .Q(s_accumulator[6]),
        .R(\s_accumulator[7]_i_1_n_0 ));
  FDRE \s_accumulator_reg[7] 
       (.C(clk),
        .CE(s_axis_tvalid),
        .D(p_1_in[7]),
        .Q(s_accumulator[7]),
        .R(\s_accumulator[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h00F2)) 
    s_calculating_i_1
       (.I0(s_calculating_reg_0),
        .I1(m_axis_tlast_reg_0),
        .I2(s_axis_tvalid),
        .I3(reset),
        .O(s_calculating_i_1_n_0));
  FDRE s_calculating_reg
       (.C(clk),
        .CE(1'b1),
        .D(s_calculating_i_1_n_0),
        .Q(s_calculating_reg_0),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "axi_accumulator_wrapper" *) 
module main_design_axi_accumulator_wrap_0_0_axi_accumulator_wrapper
   (m_axis_tlast_reg,
    s_calculating_reg,
    m_axis_tkeep,
    m_axis_tdata,
    m_axis_tready,
    s_axis_tvalid,
    s_axis_tkeep,
    s_axis_tdata,
    clk,
    reset);
  output m_axis_tlast_reg;
  output s_calculating_reg;
  output [0:0]m_axis_tkeep;
  output [7:0]m_axis_tdata;
  input m_axis_tready;
  input s_axis_tvalid;
  input [3:0]s_axis_tkeep;
  input [31:0]s_axis_tdata;
  input clk;
  input reset;

  wire clk;
  wire [7:0]m_axis_tdata;
  wire [0:0]m_axis_tkeep;
  wire m_axis_tlast_reg;
  wire m_axis_tready;
  wire reset;
  wire [31:0]s_axis_tdata;
  wire [3:0]s_axis_tkeep;
  wire s_axis_tvalid;
  wire s_calculating_reg;

  main_design_axi_accumulator_wrap_0_0_axi_accumulator axi_accumulator_inst
       (.clk(clk),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tkeep(m_axis_tkeep),
        .m_axis_tlast_reg_0(m_axis_tlast_reg),
        .m_axis_tready(m_axis_tready),
        .reset(reset),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tvalid(s_axis_tvalid),
        .s_calculating_reg_0(s_calculating_reg));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
