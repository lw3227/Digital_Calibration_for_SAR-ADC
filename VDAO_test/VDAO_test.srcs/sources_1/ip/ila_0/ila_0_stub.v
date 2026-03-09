// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Apr 15 15:52:15 2025
// Host        : DESKTOP-O0VQFCR running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/2024_adc/DITHER/dither_FPGA/VDAO_test/VDAO_test.srcs/sources_1/ip/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2018.3" *)
module ila_0(clk, probe0, probe1, probe2, probe3, probe4)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[0:0],probe2[13:0],probe3[17:0],probe4[19:0]" */;
  input clk;
  input [0:0]probe0;
  input [0:0]probe1;
  input [13:0]probe2;
  input [17:0]probe3;
  input [19:0]probe4;
endmodule
