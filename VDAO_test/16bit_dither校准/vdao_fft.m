% filename = 'E:/2024_adc/dither/FFT_1.csv';
% % 检查文件是否存在
% if ~isfile(filename)
%     error('File not found: %s', filename);
% end
% % 读取 J 列的 2~16385 行数据
% dataRange = 'F2:F1025';
% % 使用 readmatrix 读取数据
%data = readmatrix(filename, 'Range', dataRange);
d_len=80;
for i=1:d_len/2
    dout1(i,:)=data(2*(i-1)+1,:);
    dout2(i,:)=data(2*i,:);
end
M = 11; Wda = [496 256 128 64 32 16 16 8 4 2 1];   %高段位电容
L = 6; WLda=[16 16 8 4 2 1];   %低段位电容
Wdit=64; %dither插入电容的权重
WM_dummy = 1;   % 高位dummy
WL_dummy = 15;   % 低位dummy
W_Cc = 2;       % 桥接对应权重   


u=zeros(1,18);

%uk = 5e-6;%校准因子
uk =2^(-17);%校准因子

u = weight*uk;
%u(15:18)=u(15:18)*8;
%u(10:14)=u(10:14)*4;
%u(5:9)=u(5:9)*2;%构成收敛系数矩阵
ud=u(7);

L_real= log2((WL_dummy+sum(WLda) + W_Cc)/W_Cc);
Wda_real = Wda.*2^L_real;%高段因为低端的dummy加入，真实权重发生改变
Wdit_real=Wdit*2^L_real;
Wall(1:M+L+1) = [Wda_real WLda,1/2]; %所有位真实权重
weight =Wall(1:M+L+1);
weight_cal=weight;
delta_d_cal(1) = Wdit_real;
for i=1:d_len/2
    data_dig1(i,1) = dout1(i,:) * weight_cal(i,:)';
    data_dig2(i,1) = dout2(i,:) * weight_cal(i,:)';
    fu(i,1) = data_dig2(i,1) - data_dig1(i,1);
    err(i,1) = data_dig2(i,1) - data_dig1(i,1) - delta_d_cal(i);
for j=1:18
    weight_cal(i+1,j) = weight_cal(i,j) - u(j) * err(i) *2* (dout2(i,j) - dout1(i,j));
end
  %weight_cal(i+1,18) = weight_cal(i,18);
    delta_d_cal(i+1) = delta_d_cal(i) + ud * err(i);
end





