function [pow,SNR,SNDR,ENOB,SFDR,THD,HD] = calculate_dynamic_spec(u,OSR)
d_len = length(u);
u = u-mean(u);   % 去直流分量
%u = u.*rot90(kaiser(d_len,18));   % 加窗处理，抑制频谱泄漏效应
pow = fft(u).*conj(fft(u));  %用fft求功率谱

d_len2 = floor(d_len/2);                %
d_len_wo_osr = d_len2/OSR;
pow = pow(1:d_len2);          %因功率谱对称，故截取其1/2
pow = pow/max(pow);      %功率谱归一化，最大功率谱线为1

% find the signal bin number
fin = find(pow(1:d_len2)==1);      %fin为最大谱线位置，即输入信号频率
% set the main lobe width of the input signal
widm = 0;          %设置信号的主瓣宽度，主瓣的宽度=2*widm+1，通常令widm=5，对于整数个周期采样，令widm=0即可
widmh = 0;       % 设置用于寻找谐波位置的范围，通常令widmh=2，对于整数周期采样，另widmh=0即可
         %pow(fin-widm-40:fin-widm-1)=0; pow(fin+widm+1:fin+widm+40)=0; 
%*****************求直流失调功率**************************************
Pdc = sum(pow(1:widm));
%*****************求信号总功率****************************************
Ps = sum(pow(fin-widm:fin+widm));
% 定义谐波位置和大小的数组变量
Fh = []; Ph=[];   %Fh存放谐波位置，Ph存放谐波功率
%*****************寻找谐波位置和其幅值********************************
hd_num = 9;
for har_num=1:hd_num
%      tone=rem((har_num*(fin-1)+1)/d_len, 1);
%      if tone>0.5  tone=1-tone; end
%      Fh = [Fh tone];
%      har_peak = max(pow(round(tone*d_len)-widmh:round(tone*d_len)+widmh));
%      har_bin = find(pow(round(tone*d_len)-widmh:round(tone*d_len)+widmh)==har_peak);
%      har_bin = har_bin+round(tone*d_len)-widmh-1;
%      Ph = [Ph sum(pow(har_bin-widmh:har_bin+widmh))];
%对于整数个周期的数据
     tone=rem((har_num*(fin-1)+1), d_len); %对于整数个周期的数据
     if tone>d_len/2 tone=d_len-tone+2; end  %对于整数个周期的数据
     Fh = [Fh tone]; %Fh = [Fh tone/d_len];
     if tone == 0 tone=1; end          % ??? 对于整数个周期的数据
     har_peak = max(pow(tone-widmh:tone+widmh));
     har_bin = find(pow(tone-widmh:tone+widmh)==har_peak);
     har_bin = har_bin+tone-widmh-1;
     Ph = [Ph max(pow(har_bin-widmh:har_bin+widmh))]; %对于整数个周期的数据
     %Ph = [Ph sum(pow(har_bin-widmh:har_bin+widmh))]; 
 end
%*****************求总谐波失真功率********************************
Pd = sum(Ph(2:hd_num));
%*****************求噪声功率********************************
Pn = sum(pow)-Pdc-Ps-Pd;
%*****************求ADC动态指标**********************************
SNDR = 10*log10(Ps/(sum(pow(1:d_len_wo_osr))-Ps-Pdc));  %求SNDR
SNR = 10*log10(Ps/Pn);        
THD = 10*log10(Pd/Ph(1));
har_bin = find(pow(1:end)==1);
       %pow(fin-widm-40:fin-widm-1)=0; pow(fin+widm+1:fin+widm+40)=0;
%SFDR = 10*log10(1/max(max(pow(widmh+1:har_bin-widm-1)),max(pow(har_bin+widm+1:end))));
if har_bin==d_len2      
SFDR = 10*log10(1/max(pow(widmh+1:har_bin-widm-1)));
else
SFDR = 10*log10(1/max(max(pow(widmh+1:har_bin-widm-1)),max(pow(har_bin+widm+1:end))));
end

HD = 10*log10(Ph(1:hd_num)/Ph(1));
ENOB = (SNDR-1.76)/6.02;
