module cali_top(
input sys_clk,
input EN_cali,
(* dont_touch = "true" *)input rst,//连接按键，需要确定是否由低电平触发
input EN_trans
//output [53:0]adout_test
    );

wire FIN;
reg [16:0] addr_cali;//校准rom地址
reg [13:0] addr_test,addr_test_read;//测试rom地址
wire [17:0] Din_cali,Din_test;
wire P_trig,N_trig,clk,clk_2u;

reg [53:0] adin;
wire [53:0] aout;
wire [51:0] weight_cali[17:0];//校准的18位权重，用16位整数+18*2位小数表示（*2是因为乘法造成为拓展）
integer i;
reg [14:0]CNT;
reg EN_cali_inner;
reg EN_start;
reg rom_start;
reg EN_read;
reg [14:0]CNT_read;
wire key_cali,key_test;
reg change_cali,change_test;
reg [19:0]adout;//输出的纯二进制数字码

always @(posedge clk_2u)begin
if (change_cali)
rom_start<=1;
end


always @(negedge clk_2u)begin
if (rom_start)
EN_start<=1;
end



//assign adout_test=aout;

CLK CLK
(
.clk_in1(sys_clk),
.clk(clk),
.clk_2u(clk_2u),
.P_trig(P_trig),
.N_trig(N_trig)
);//产生片内时钟与控制信号

Din_cali Din_dither
(
.addra(addr_cali),
.clka(clk),
.douta(Din_cali),
.ena(rom_start)//coe导入用于校准的数字码
);

Din_afterCali Din_afterCali
(
.addra(addr_test),
.clka(clk),
.douta(Din_test)//coe导入用于测试校准效果的数字码
);


(* dont_touch = "true" *)LMS_cali LMS
(.CLK(clk),.CLK_2u(clk_2u),.P_trig(P_trig),.N_trig(N_trig),.EN(EN_start),.rst(rst), .Din(Din_cali),
.weight_0(weight_cali[0]),.weight_1(weight_cali[1]),.weight_2(weight_cali[2]),
.weight_3(weight_cali[3]),.weight_4(weight_cali[4]),.weight_5(weight_cali[5]),.weight_6(weight_cali[6]),
.weight_7(weight_cali[7]),.weight_8(weight_cali[8]),.weight_9(weight_cali[9]),.weight_10(weight_cali[10]),
.weight_11(weight_cali[11]),.weight_12(weight_cali[12]),.weight_13(weight_cali[13]),.weight_14(weight_cali[14]),
.weight_15(weight_cali[15]),.weight_16(weight_cali[16]),.weight_17(weight_cali[17]),.FIN(FIN));//完成校准后，FIN==1
//例化LMS模块

always @(posedge clk or negedge rst)begin 
if (!rst) begin
addr_cali<=0;
addr_test<=0;
addr_test_read<=0;
adin<=0;
CNT<=0;
EN_start<=0;
EN_read<=0;
CNT_read<=0;
change_cali<=0;
change_test<=0;
rom_start<=0;
end

else begin 
if(rom_start&&(!FIN)) begin
addr_cali<=addr_cali+1;
  end
  
 if (FIN&&change_test&&(CNT<1026)) begin//使用完成校准的weight_cali对数字码进行重新编码
   addr_test<=addr_test+1;
    adin <= 
        (Din_test[0]  ? weight_cali[0]  : 0) +
        (Din_test[1]  ? weight_cali[1]  : 0) +
        (Din_test[2]  ? weight_cali[2]  : 0) +
        (Din_test[3]  ? weight_cali[3]  : 0) +
        (Din_test[4]  ? weight_cali[4]  : 0) +
        (Din_test[5]  ? weight_cali[5]  : 0) +
        (Din_test[6]  ? weight_cali[6]  : 0) +
        (Din_test[7]  ? weight_cali[7]  : 0) +
        (Din_test[8]  ? weight_cali[8]  : 0) +
        (Din_test[9]  ? weight_cali[9]  : 0) +
        (Din_test[10] ? weight_cali[10] : 0) +
        (Din_test[11] ? weight_cali[11] : 0) +
        (Din_test[12] ? weight_cali[12] : 0) +
        (Din_test[13] ? weight_cali[13] : 0) +
        (Din_test[14] ? weight_cali[14] : 0) +
        (Din_test[15] ? weight_cali[15] : 0) +
        (Din_test[16] ? weight_cali[16] : 0) +
        (Din_test[17] ? weight_cali[17] : 0);
   CNT<=CNT+1;
   adout<=adin[50:33];//对输出进行截取，得到20位纯二进制输出，以最低为权重位0.5，则包含3位小数位，
 end
end
end


key_filter EN_cali_key (//例化按键消抖模块
        .clk       (clk),
        .rst_n     (rst),
        .key_in    (EN_cali),
        .key_flag  (key_cali),
        .key_state ( )
    );
key_filter EN_test_key (
        .clk       (clk),
        .rst_n     (rst),
        .key_in    (EN_trans),
        .key_flag  (key_test),
        .key_state ( )
    );
    always @(posedge key_cali) begin
     change_cali <= ~change_cali; // 切换连接状态
     end
    always @(posedge key_test) begin
     change_test <= ~change_test; // 切换连接状态
     end


(* dont_touch = "true" *)ila_0 ila (
	.clk(clk), 
	.probe0(change_cali), 
	.probe1(change_test), 
	.probe2(addr_test),
	.probe3(Din_test),
	.probe4(adout)
	
);

endmodule