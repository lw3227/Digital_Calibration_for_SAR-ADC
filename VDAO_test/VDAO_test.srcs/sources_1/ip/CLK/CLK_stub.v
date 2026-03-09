// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Mar  5 16:44:33 2025
// Host        : DESKTOP-O0VQFCR running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/2024_adc/DITHER/dither_FPGA/with_ila/with_ila.srcs/sources_1/ip/CLK/CLK_stub.v
// Design      : CLK
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module CLK(clk, clk_2u, P_trig, N_trig, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk,clk_2u,P_trig,N_trig,clk_in1" */;
  output clk;
  output clk_2u;
  output P_trig;
  output N_trig;
  input clk_in1;
endmodule
