`timescale 1ns / 1ps

module LMS_tb();


parameter SYS_CLK_PERIOD = 20;  // 系统时钟周期 50MHz (20ns)
reg          sys_clk;     // 系统时钟
reg          EN_cali;     // 校准使能
reg          rst;         // 低电平复位
reg          EN_trans;    // 传输使能
wire [53:0]  adout_test;  // 测试输出



cali_top uut (
    .sys_clk    (sys_clk),
    .EN_cali    (EN_cali),
    .rst        (rst),
    .EN_trans   (EN_trans)
);
wire [51:0] weight_cali[17:0]=uut.weight_cali[17:0];
wire         FIN       = uut.FIN;        // 校准完成标志
  always begin
        sys_clk = 1 ; #1 ;
        sys_clk = 0 ; #1 ;
    end // 时钟生成
  initial begin
        #1000
        // 初始化信号
        rst = 1;
        EN_trans = 1;
        EN_cali=1;

        #10 rst = 0;   // 激活复位
        #20 rst = 1;   // 解除复位
        // 启动校准
//       #5 rom_start=1;
        #10 EN_trans = 0;
        EN_cali=0;
        #10 EN_trans = 1;
        EN_cali=1;
        
        
end

always @(*) begin
if (FIN==1)  begin
$display("Weight_0: %f", weight_cali[0] / (2**36.0));  // 显示小数形式
$display("Weight_1: %f", weight_cali[1] / (2**36.0));
$display("Weight_2: %f", weight_cali[2] / (2**36.0));
$display("Weight_3: %f", weight_cali[3] / (2**36.0));
$display("Weight_4: %f", weight_cali[4]/ (2**36.0));
$display("Weight_5: %f", weight_cali[5] /(2**36.0));
$display("Weight_6: %f", weight_cali[6] / (2**36.0));
$display("Weight_7: %f", weight_cali[7] / (2**36.0));
$display("Weight_8: %f", weight_cali[8] / (2**36.0));
$display("Weight_9: %f", weight_cali[9] / (2**36.0));
$display("Weight_10: %f", weight_cali[10] /(2**36.0));
$display("Weight_11: %f", weight_cali[11] / (2**36.0));
$display("Weight_12: %f", weight_cali[12] / (2**36.0));
$display("Weight_13: %f", weight_cali[13] / (2**36.0));
$display("Weight_14: %f", weight_cali[14]/ (2**36.0));
$display("Weight_15: %f", weight_cali[15] / (2**36.0));
$display("Weight_16: %f", weight_cali[16] / (2**36.0));
$display("Weight_17: %f", weight_cali[17] / (2**36.0)); 
#50;
//        $finish;
        end
end

endmodule

