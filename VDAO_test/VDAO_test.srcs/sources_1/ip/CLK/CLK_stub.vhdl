-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Wed Mar  5 16:44:33 2025
-- Host        : DESKTOP-O0VQFCR running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               E:/2024_adc/DITHER/dither_FPGA/with_ila/with_ila.srcs/sources_1/ip/CLK/CLK_stub.vhdl
-- Design      : CLK
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLK is
  Port ( 
    clk : out STD_LOGIC;
    clk_2u : out STD_LOGIC;
    P_trig : out STD_LOGIC;
    N_trig : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end CLK;

architecture stub of CLK is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,clk_2u,P_trig,N_trig,clk_in1";
begin
end;
