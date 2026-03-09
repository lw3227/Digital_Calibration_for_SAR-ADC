// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Mar  4 17:20:58 2025
// Host        : DESKTOP-O0VQFCR running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/2024_adc/DITHER/dither_FPGA/with_clk/with_clk.srcs/sources_1/ip/adout/adout_stub.v
// Design      : adout
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module adout(clka, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[13:0],dina[53:0],clkb,enb,addrb[13:0],doutb[53:0]" */;
  input clka;
  input [0:0]wea;
  input [13:0]addra;
  input [53:0]dina;
  input clkb;
  input enb;
  input [13:0]addrb;
  output [53:0]doutb;
endmodule
