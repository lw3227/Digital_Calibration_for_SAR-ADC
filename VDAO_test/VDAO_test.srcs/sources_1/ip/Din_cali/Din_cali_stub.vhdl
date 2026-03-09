-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Fri Jun  6 20:15:45 2025
-- Host        : DESKTOP-O0VQFCR running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               F:/2024_adc/DITHER/dither_FPGA/VDAO_test/VDAO_test.srcs/sources_1/ip/Din_cali/Din_cali_stub.vhdl
-- Design      : Din_cali
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Din_cali is
  Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 16 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 17 downto 0 )
  );

end Din_cali;

architecture stub of Din_cali is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,ena,addra[16:0],douta[17:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_2,Vivado 2018.3";
begin
end;
