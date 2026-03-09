`timescale 1ns / 1ps

 module LMS_cali(CLK,CLK_2u, EN, rst, Din, P_trig, N_trig,weight_0,weight_1,weight_2,weight_3,weight_4,
 weight_5,weight_6,weight_7,weight_8,weight_9,weight_10,weight_11,weight_12,weight_13,weight_14,weight_15,
 weight_16,weight_17,FIN);
(* dont_touch = "true" *)input [17:0] Din;
(* dont_touch = "true" *)input CLK,CLK_2u,rst,EN, P_trig, N_trig;
(* dont_touch = "true" *)output [51:0]weight_0;
(* dont_touch = "true" *)output [51:0]weight_1;
(* dont_touch = "true" *)output [51:0]weight_2;
(* dont_touch = "true" *)output [51:0]weight_3;
(* dont_touch = "true" *)output [51:0]weight_4;
(* dont_touch = "true" *)output [51:0]weight_5;
(* dont_touch = "true" *)output [51:0]weight_6;
(* dont_touch = "true" *)output [51:0]weight_7;
(* dont_touch = "true" *)output [51:0]weight_8;
(* dont_touch = "true" *)output [51:0]weight_9;
(* dont_touch = "true" *)output [51:0]weight_10;
(* dont_touch = "true" *)output [51:0]weight_11;
(* dont_touch = "true" *)output [51:0]weight_12;
(* dont_touch = "true" *)output [51:0]weight_13;
(* dont_touch = "true" *)output [51:0]weight_14;
(* dont_touch = "true" *)output [51:0]weight_15;
(* dont_touch = "true" *)output [51:0]weight_16;
(* dont_touch = "true" *)output [51:0]weight_17;
(* dont_touch = "true" *)output FIN;

(* dont_touch = "true" *)reg [33:0] u [17:0];
(* dont_touch = "true" *)reg [33:0] ud;

(* dont_touch = "true" *)reg [51:0] weight_fixp [17:0];
(* dont_touch = "true" *)reg [33:0] VDAO_P;
(* dont_touch = "true" *)reg [33:0] VDAO_N;
(* dont_touch = "true" *)reg[16:0]CNT;
(* dont_touch = "true" *)reg [33:0]weight_dit;
(* dont_touch = "true" *)reg [17:0]Din_P,Din_N;
integer i,j ;
(* dont_touch = "true" *)wire EN_inner;
(* dont_touch = "true" *)wire [33:0]weight_mem[17:0];//使用ila探测信号，防止布线阶段被优化


assign FIN=(CNT==17'd65536)?1'b1:1'd0;
assign EN_inner=EN&&(!FIN);//计数共65536*2个sample

genvar m;
generate
    for (m = 0; m <= 17; m = m + 1) begin : WEIGHT_MEM_ASSIGN
       assign weight_mem[m] = (weight_fixp[m][17] && (!weight_fixp[m][18])) ? 
                     {(weight_fixp[m] >> 19), 1'b1} : weight_fixp[m] >> 18;//四舍五入截断出16位小数
    end

endgenerate

assign weight_0=weight_fixp[0];
assign weight_1=weight_fixp[1];
assign weight_2=weight_fixp[2];
assign weight_3=weight_fixp[3];
assign weight_4=weight_fixp[4];
assign weight_5=weight_fixp[5];
assign weight_6=weight_fixp[6];
assign weight_7=weight_fixp[7];
assign weight_8=weight_fixp[8];
assign weight_9=weight_fixp[9];
assign weight_10=weight_fixp[10];
assign weight_11=weight_fixp[11];
assign weight_12=weight_fixp[12];
assign weight_13=weight_fixp[13];
assign weight_14=weight_fixp[14];
assign weight_15=weight_fixp[15];
assign weight_16=weight_fixp[16];
assign weight_17=weight_fixp[17];


//输出校准后的weight
always @(negedge CLK) begin
if (!rst) begin//同步置位
u[17]<=34'd31744*2;
u[16]<=34'd16384*2;
u[15]<=34'd8192*2;
u[14]<=34'd4096*2;
u[13]<=34'd2048*2;
u[12]<=34'd1024*2;
u[11]<=34'd1024*2;
u[10]<=34'd512*2;
u[9]<=34'd256*2;
u[8]<=34'd128*2;
u[7]<=34'd64*2;
u[6]<=34'd32*2;
u[5]<=34'd32*2;
u[4]<=34'd16*2;
u[3]<=34'd8*2;
u[2]<=34'd4*2;
u[1]<=34'd2*2;
u[0]<=34'd1*2;
ud<=34'd1024*2;//初始化收敛因子

 end

else 
if (EN_inner) begin//开始校准

if(P_trig) begin 
Din_N<=Din;
VDAO_N <= 
 (Din[0]  ? weight_mem[0]  : 0) +
                 (Din[1]  ? weight_mem[1]  : 0) +
                 (Din[2]  ? weight_mem[2]  : 0) +
                 (Din[3]  ? weight_mem[3]  : 0) +
                 (Din[4]  ? weight_mem[4]  : 0) +
                 (Din[5]  ? weight_mem[5]  : 0) +
                 (Din[6]  ? weight_mem[6]  : 0) +
                 (Din[7]  ? weight_mem[7]  : 0) +
                 (Din[8]  ? weight_mem[8]  : 0) +
                 (Din[9]  ? weight_mem[9]  : 0) +
                 (Din[10] ? weight_mem[10] : 0) +
                 (Din[11] ? weight_mem[11] : 0) +
                 (Din[12] ? weight_mem[12] : 0) +
                 (Din[13] ? weight_mem[13] : 0) +
                 (Din[14] ? weight_mem[14] : 0) +
                 (Din[15] ? weight_mem[15] : 0) +
                 (Din[16] ? weight_mem[16] : 0) +
                 (Din[17] ? weight_mem[17] : 0);

 end
if(N_trig) begin 
Din_P<=Din;
VDAO_P <= 

 (Din[0]  ? weight_mem[0]  : 0) +
                 (Din[1]  ? weight_mem[1]  : 0) +
                 (Din[2]  ? weight_mem[2]  : 0) +
                 (Din[3]  ? weight_mem[3]  : 0) +
                 (Din[4]  ? weight_mem[4]  : 0) +
                 (Din[5]  ? weight_mem[5]  : 0) +
                 (Din[6]  ? weight_mem[6]  : 0) +
                 (Din[7]  ? weight_mem[7]  : 0) +
                 (Din[8]  ? weight_mem[8]  : 0) +
                 (Din[9]  ? weight_mem[9]  : 0) +
                 (Din[10] ? weight_mem[10] : 0) +
                 (Din[11] ? weight_mem[11] : 0) +
                 (Din[12] ? weight_mem[12] : 0) +
                 (Din[13] ? weight_mem[13] : 0) +
                 (Din[14] ? weight_mem[14] : 0) +
                 (Din[15] ? weight_mem[15] : 0) +
                 (Din[16] ? weight_mem[16] : 0) +
                 (Din[17] ? weight_mem[17] : 0);

  end
 end
end

always @(negedge CLK_2u ) begin
if(!rst)begin
CNT<=0;
weight_fixp[17]<=52'd15872<<36;//因为权重的定点数格式为q16.36，需要左移36位以表示整数
weight_fixp[16]<=52'd8192<<36;
weight_fixp[15]<=52'd4096<<36;
weight_fixp[14]<=52'd2048<<36;
weight_fixp[13]<=52'd1024<<36;
weight_fixp[12]<=52'd512<<36;
weight_fixp[11]<=52'd512<<36;
weight_fixp[10]<=52'd256<<36;
weight_fixp[9]<=52'd128<<36;
weight_fixp[8]<=52'd64<<36;
weight_fixp[7]<=52'd32<<36;
weight_fixp[6]<=52'd16<<36;
weight_fixp[5]<=52'd16<<36;
weight_fixp[4]<=52'd8<<36;
weight_fixp[3]<=52'd4<<36;
weight_fixp[2]<=52'd2<<36;
weight_fixp[1]<=52'd1<<36;
weight_fixp[0]<=(34'b0000_0000_0000_0000_1000_0000_0000_0000_00)<<18;//初始化权重
weight_dit <= 34'd2048<<18;
end


else if (EN_inner) begin//开始校准
 if((VDAO_P-VDAO_N)>=weight_dit)begin//此处没用有符号数表示，故计算表达式较为繁琐，计算逻辑同行为级模型
    for (j=0; j<=17; j=j+1) begin
    if(Din_P[j]>=Din_N[j]) 
     weight_fixp[j]<=weight_fixp[j]-u[j] * (VDAO_P-VDAO_N-weight_dit);
     else//实际上必有Din_P[j]>=Din_N[j]，故不会进入else语句
     weight_fixp[j]<=weight_fixp[j]+u[j] * (VDAO_P-VDAO_N-weight_dit);
     if(j==17) begin
       CNT<=CNT+1;//每完成一次校准，进行一次计数
      end
     end
     weight_dit<=weight_dit+(ud*(VDAO_P-VDAO_N-weight_dit)>>18);
 end
   if((VDAO_P-VDAO_N)<weight_dit)begin
    for (j=0; j<=17; j=j+1) begin
    if(Din_P[j]>=Din_N[j])
      weight_fixp[j]<=weight_fixp[j]+u[j] * (weight_dit-(VDAO_P-VDAO_N));
    else//实际上必有Din_P[j]>=Din_N[j]，故不会进入else语句
      weight_fixp[j]<=weight_fixp[j]-u[j] * (weight_dit-(VDAO_P-VDAO_N));
     if(j==17) begin
       CNT<=CNT+1;//每完成一次校准，进行一次计数
      end
     end
     weight_dit<=weight_dit-(ud*(weight_dit-(VDAO_P-VDAO_N))>>18);
 end

end
end

endmodule
