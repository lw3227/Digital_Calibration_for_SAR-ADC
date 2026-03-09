clear all;
clc;
times = 16;
ENOB_all = 0;
cali = 0;%1开校准，0关校准
OSR = 1;
d_len = 128*OSR; %用于FFT分析的样本长度
K=1.3806505e-23;
T=300;
fin =489;    %fin/d_len为输入频率，fin与d_len互质
fin =61;   
adout(d_len) = 0; %ad_vres(d_len) = 0;%定义存放转换结果的数组
L_true=0;
% 这一段定义SAR ADC中主要的结构和电路参数；
% 这里考虑的非理想电路因素有：电容失配、比较器失调和噪声、采样噪声、寄生电容效应
Vref =3.3; %定义了参考电压变量
k = 1; %分段式电容结构，M为高位段分辨率，L为低位段分辨率，k=高段单位电容/低段单位电容



M = 11; Wda = [496 256 128 64 32 16 16 8 4 2 1];   %高段位电容
L = 6; WLda=[16 16 8 4 2 1];   %低段位电容
Wdit=64; %dither插入电容的权重
WM_dummy = 1;   % 高位dummy
WL_dummy = 15;   % 低位dummy
W_Cc = 2;       % 桥接对应权重                             


Cu = 30e-15;    %单位电容值
del_Cu = Cu*0.03;% 定义工作电容的设计值和分布的均方根值
alfa =0.02; beta =0.02;  % 定义 alfa底板和beta顶板到地的归一化寄生电容。
% 此值是估值，实际取值应从版图提取。底板寄生相对没那么重要，顶板寄生较重要，大概是0.1。正确科学的方法是从版图提取，但是前期算法层面的行为级验证或者SAR ADC逻辑验证时大概定义个0.2就够了。
del_Compos = 10e-6;       % 定义比较器失调的均方根值。均方根值=标准差 σ
del_Compvn = 47e-6;     % 定义比较器噪声
pkt = 1;                  % 是否加入kT/C噪声

%*****************以下是理想情况****************
 % del_Cu = 0;
 % alfa =0; beta =0;
 % del_Compos = 0;    %定义比较器失调的均方根值
 % del_Compvn = 0;  %定义比较器噪声
 % pkt = 0;         %是否加入kT/C噪声


Vcm=Vref/2;
Cm_p(1:M)=0;
Cm_n(1:M)=0;
Cl_p(1:L)=0;
Cl_n(1:L)=0;

Cdit_p =  Wdit*k*Cu + sqrt( Wdit*k)*del_Cu*randn(1,1);
Cdit_n =  Wdit*k*Cu + sqrt( Wdit*k)*del_Cu*randn(1,1);
for i=1:M
     Cm_p(i) =  Wda(i)*k*Cu + sqrt( Wda(i)*k)*del_Cu*randn(1,1);%randn(1,1)是一个1*1均值为0，方差σ^2 = 1，标准差σ = 1的正态分布矩阵。del_Cu*randn(1,1)是一个均值为0，方差σ^2 = del_Cu^2的正态分布。 
    Cm_n(i) =  Wda(i)*k*Cu + sqrt( Wda(i)*k)*del_Cu*randn(1,1);%单位电容Cu对应的方差是del_Cu^2*randn(1,1)^2，Wda(i)*k*Cu对应的方差是Wda(i)*k*del_Cu^2*randn(1,1)^2，因此标准差是sqrt( Wda(i)*k)*del_Cu*randn(1,1)
end     % 设定高位段中的工作电容的值
Cd1_p = k*WM_dummy*Cu + sqrt(k*WM_dummy)*del_Cu*randn(1,1); %高段dummy
Cd1_n = k*WM_dummy*Cu + sqrt(k*WM_dummy)*del_Cu*randn(1,1);
for i=1:L
    Cl_p(i) = WLda(i)*Cu + sqrt(WLda(i))*del_Cu*randn(1,1);
    Cl_n(i) = WLda(i)*Cu + sqrt(WLda(i))*del_Cu*randn(1,1);
end     % 设定低位段中的工作电容的值
Cd2_p = WL_dummy*Cu + sqrt(WL_dummy)*del_Cu*randn(1,1); %低段dummy
Cd2_n = WL_dummy*Cu + sqrt(WL_dummy)*del_Cu*randn(1,1);

Ca_p = (Cu*W_Cc) + sqrt(W_Cc)*del_Cu*randn(1,1);    % 定义两段间桥接电容的值
Ca_n = (Cu*W_Cc)+ sqrt(W_Cc)*del_Cu*randn(1,1);    % 定义两段间桥接电容的值
%注意：Cd2, Ca的值要在结构设计中确定，具体取值方法请见课件中的“两段结构的线性化设计”部分


%***********************定义各种寄生**************************************%
Cp1_p = alfa*Ca_p + beta*(sum(Cm_p)+Cd1_p);%Cbpb
Cp2_p = beta*(sum(Cl_p)+Cd2_p);  %定义寄生电容  %Cbpt
Cp3_p = 0;  %注意：Cp3为高位段、低位段公共顶板之间的寄生电容，其值要根据具体版图设计来提取

Cp1_n = alfa*Ca_n + beta*(sum(Cm_n)+Cd1_n);
Cp2_n = beta*Ca_n + beta*(sum(Cl_n)+Cd2_n);  %定义寄生电容
Cp3_n = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L_true= log2((Cd2_p+sum(Cl_p) + Ca_p)/Ca_p);
Wda_true =  Cm_p/Cu.*2^L_true;%高段因为低端的dummy加入，真实权重发生改变
Wall(1:M+L+1) = [Wda_true  Cl_p/Cu,1/2]; %所有位真实权重
weight_ture =Wall(1:M+L+1);

w_LP=(Cl_p./WLda)/Cu*30.0244;
w_LN=(Cl_n./WLda)/Cu*30.0244;
w_MP=(Cm_p./Wda)/Cu*30.024;
w_MN=(Cm_n./Wda)/Cu*30.024;
w_ditp=(Cdit_p/Wdit)/Cu*30.024;
w_ditn=(Cdit_n/Wdit)/Cu*30.024;
w_d1p=Cd1_p/Cu*30.024;
w_d1n=Cd1_n/Cu*30.024;
w_d2p=(Cd2_p/WL_dummy)/Cu*30.024;
w_d2n=(Cd2_n/WL_dummy)/Cu*30.024;
w_cap=Ca_p/W_Cc/Cu*30.024;
w_can=Ca_n/W_Cc/Cu*30.024;
w_p1p=Cp1_p/Cu*30.024;
w_p1n=Cp1_n/Cu*30.024;
w_p2p=Cp2_p/Cu*30.024;
w_p2n=Cp2_n/Cu*30.024;%计算失配电容对应的单位电容，以此修改电路上的单位电容大小，从而引入失配
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Comp_os = del_Compos*randn(1,1);    %设定比较器的失调电压
del_ktc_p = pkt*(K*T/(sum(Cm_p)+Cd1_p));    %pkt表示是否计算kt/c噪声
del_ktc_n = pkt*(K*T/(sum(Cm_n)+Cd1_n));

delta_ph = 2*pi*fin/d_len;  % input's delta phase for a Tclk


if cali==1
for Bit=L+1:M+L       %这里表示从低段的最高位开始校准,校准高位电容
        Wda(L+M+1-Bit)= calibration(Bit,Vcm,Vcm,Vref,Vcm,M,L,Cm_p,Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n,Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,Comp_os,del_Compvn,del_ktc_p,del_ktc_n,Wda,WLda,times);    
end
end

%不进行低位校准高位的权重校准

%***************** SAR conversation *****************************
%校准前转换
L_real= log2((WL_dummy+sum(WLda) + W_Cc)/W_Cc);
Wda_real = Wda.*2^L_real;%高段因为低端的dummy加入，真实权重发生改变
Wdit_real=Wdit*2^L_real;
Wall(1:M+L+1) = [Wda_real WLda,1/2]; %所有位真实权重
weight =Wall(1:M+L+1);
dout=zeros(1,18);
for i = 1:d_len
    ctrl=0;
    Vip = 0.49*Vref*sin(i*delta_ph)+Vcm; % defining input signal 输入单频信号，幅度近似满量程，用sar adc对其进行转换，并将转换结果放到数组adout中
    Vin = -0.49*Vref*sin(i*delta_ph)+Vcm;
    dout = adc_sar(Vip,Vin,Vref,Vcm,M,L,Cm_p,Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n,Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,Comp_os,del_Compvn,del_ktc_p,del_ktc_n,Wda,WLda,W_Cc,WM_dummy,WL_dummy,Wdit,Cdit_p,Cdit_n,ctrl); 
    dout=2*dout-1;
    adout(i) = dout * weight';
end 

[pow,SNR,SNDR,ENOB,SFDR,THD,HD] = calculate_dynamic_spec(adout,OSR);
%***************** Plot Output Power spectrum *****************************
figure(1);
base_value=-140;
xz = 0:d_len/2-1;
xz = xz / (d_len/2) *500 * OSR;
stem(xz, 10*log10(pow), 'Marker', 'none','BaseValue', base_value,'LineWidth',2,'Color','b');
xlabel('Frequency(kHz)');
ylabel('Magnitude(dB)');
ymin = -140 ; ymax = 0;
ylim([ymin, ymax]);
xmax = size(xz); xmax = xmax(2);
xlim([0,xz(xmax)]);
SNDR = roundn(SNDR,-2) ;
SFDR = roundn(SFDR,-2) ;
ENOB = roundn(ENOB,-2) ;
THD = roundn(THD,-2) ;
txt = {['ENOB=' num2str(ENOB) 'bit'], ['SNDR=' num2str(SNDR) 'dB'],['SFDR=' num2str(SFDR) 'dB'] ,['THD=' num2str(THD) 'dB']};
text(xz(xmax)*0.64,(ymin+ymax)*0.17,txt,'FontSize',14);

%%%%%%%%%%%%%%%%%%%%%%% 进行校准，插入dither%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
ns=65536; %校准sample数
weight_cal=zeros(ns,18); %存储校准位数的矩阵

u=zeros(1,18);

uk =2^(-10);%校准因子
u = [uk,uk,uk,uk,uk,uk,uk,uk,uk,uk,uk,uk,uk,uk,uk,uk,uk,uk];

% u=2^(-17);
% u = weight*uk;
%u(15:18)=u(15:18)*8;
%u(10:14)=u(10:14)*4;
%u(5:9)=u(5:9)*2;%构成收敛系数矩阵
ud=u(7);
%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:ns
Vip_cal(i,1) = 0.45*Vref*sin(0.1*i*delta_ph)+Vcm;% defining input signal 输入单频信号，用sar adc对其进行转换，并将转换结果放到数组adout中
Vin_cal(i,1) = -0.45*Vref*sin(0.1*i*delta_ph)+Vcm;
% Vip_cal(i,1) = 0.45*Vref*sin(2*pi*1/500*i)+Vcm;% defining input signal 输入单频信号，用sar adc对其进行转换，并将转换结果放到数组adout中
% Vin_cal(i,1) = -0.45*Vref*sin(2*pi*1/500*i)+Vcm;
end


[weight_cal,err] = cal_dither(Wdit_real,weight,ns,u,ud,Vip_cal,Vin_cal,Vref,Vcm,M,L,Cm_p,...
    Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n,Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,...
    Comp_os,del_Compvn,del_ktc_p,del_ktc_n,Wda,WLda,W_Cc,WM_dummy,WL_dummy,Wdit,Cdit_p,Cdit_n);
weight_final = weight_cal(end,:);
figure(2);
subplot(size(weight_cal,2),1,1);    plot(weight_cal(:,1));
subplot(size(weight_cal,2),1,2);    plot(weight_cal(:,2));
subplot(size(weight_cal,2),1,3);    plot(weight_cal(:,3));
subplot(size(weight_cal,2),1,4);    plot(weight_cal(:,4));
subplot(size(weight_cal,2),1,5);    plot(weight_cal(:,5));
subplot(size(weight_cal,2),1,6);    plot(weight_cal(:,6));
subplot(size(weight_cal,2),1,7);    plot(weight_cal(:,7));
subplot(size(weight_cal,2),1,8);    plot(weight_cal(:,8));
subplot(size(weight_cal,2),1,9);    plot(weight_cal(:,9));
subplot(size(weight_cal,2),1,10);    plot(weight_cal(:,10));
subplot(size(weight_cal,2),1,11);    plot(weight_cal(:,11));
subplot(size(weight_cal,2),1,12);    plot(weight_cal(:,12));
subplot(size(weight_cal,2),1,13);    plot(weight_cal(:,13));
subplot(size(weight_cal,2),1,14);    plot(weight_cal(:,14));
subplot(size(weight_cal,2),1,15);    plot(weight_cal(:,15));
subplot(size(weight_cal,2),1,16);    plot(weight_cal(:,16));
subplot(size(weight_cal,2),1,17);    plot(weight_cal(:,17));
subplot(size(weight_cal,2),1,18);    plot(weight_cal(:,18));
%校准后转换
for i = 1:d_len
    ctrl=0;
    Vip = 0.49*Vref*sin(i*delta_ph)+Vcm; % defining input signal 输入单频信号，幅度近似满量程，用sar adc对其进行转换，并将转换结果放到数组adout中
    Vin = -0.49*Vref*sin(i*delta_ph)+Vcm;
    dout = adc_sar(Vip,Vin,Vref,Vcm,M,L,Cm_p,Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n,Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,Comp_os,del_Compvn,del_ktc_p,del_ktc_n,Wda,WLda,W_Cc,WM_dummy,WL_dummy,Wdit,Cdit_p,Cdit_n,ctrl); 
    dout=2*dout-1;
    adout(i) = dout * weight_final';
end 
[pow,SNR,SNDR,ENOB,SFDR,THD,HD] = calculate_dynamic_spec(adout,OSR);
figure(3);
base_value=-140;
xz = 0:d_len/2-1;
xz = xz / (d_len/2) *500 * OSR;
stem(xz, 10*log10(pow), 'Marker', 'none','BaseValue', base_value,'LineWidth',2,'Color','b');
xlabel('Frequency(kHz)');
ylabel('Magnitude(dB)');
ymin = -140 ; ymax = 0;
ylim([ymin, ymax]);
xmax = size(xz); xmax = xmax(2);
xlim([0,xz(xmax)]);
SNDR = roundn(SNDR,-2) ;
SFDR = roundn(SFDR,-2) ;
ENOB = roundn(ENOB,-2) ;
THD = roundn(THD,-2) ;
txt = {['ENOB=' num2str(ENOB) 'bit'], ['SNDR=' num2str(SNDR) 'dB'],['SFDR=' num2str(SFDR) 'dB'] ,['THD=' num2str(THD) 'dB']};
text(xz(xmax)*0.64,(ymin+ymax)*0.17,txt,'FontSize',14);





