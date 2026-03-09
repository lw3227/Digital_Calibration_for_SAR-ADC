function dout = adc_sar(Vip,Vin,Vref,Vcm,M,L,Cm_p,Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n, ...
    Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,Comp_os,del_Compvn,del_ktc_p,del_ktc_n, ...
    Wda,WLda,W_Cc,WM_dummy,WL_dummy,Wdit,Cdit_p,Cdit_n,ctrl) % basic behavior model
%增加Wdit,Cdit_p,Cdit_n,ctrl，用于添加dither
dout=zeros(1,18);

CLt_p=sum(Cl_p)+Cd2_p;
CMt_p=sum(Cm_p)+Cd1_p+Cdit_p;
CLt_n=sum(Cl_n)+Cd2_n;
CMt_n=sum(Cm_n)+Cd1_n+Cdit_n;
CLtp_p=CLt_p+Cp2_p;%LSB段总电容+寄生电容 p端
CLtp_n=CLt_n+Cp2_n;%LSB段总电容+寄生电容 n端
CMtp_p=CMt_p+Cp1_p;%MSB端总电容+寄生电容 p端
CMtp_n=CMt_n+Cp1_n;%MSB段总电容+寄生电容 n端
Cap_p=Ca_p+Cp3_p;%桥结电容带寄生电容
Cap_n=Ca_n+Cp3_n;
Vdum1_p = Vip + sqrt(del_ktc_p)*randn(1,1);%带kt/c噪声的输入输入
Vdum1_n = Vin + sqrt(del_ktc_n)*randn(1,1);
Vdum2_p = Vcm;
Vdum2_n = Vcm;
VMdam_p(1:M) = Vdum1_p;%高段底板初始接Vip Vin，同时含噪声
VMdam_n(1:M) = Vdum1_n;
VLdam_p(1:L) = Vcm;%低段底版初始接Vcm
VLdam_n(1:L) = Vcm;
Vdit1=Vcm;
Vdit_p=0;
Vdit_n=0;

Qi_p = Vcm*(Cap_p+CMtp_p - Cap_p * Cap_p / (CLtp_p + Cap_p)) - VMdam_p*rot90(Cm_p,3) - Vdum1_p*Cd1_p - Cap_p*(VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)/(CLtp_p + Cap_p);
Qi_n = Vcm*(Cap_n+CMtp_n - Cap_n * Cap_n / (CLtp_n + Cap_n)) - VMdam_n*rot90(Cm_n,3) - Vdum1_n*Cd1_n - Cap_n*(VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)/(CLtp_n + Cap_n);
%采样阶段引入的电荷
%Qi_p = Vcm * (CMtp_p + Cap_p) - (Vip+sqrt(del_ktc_p)*randn(1,1))*CMt_p - Vcm*(sum(Cl_p) + Cd2_p + Cap_p)/(CLtp_p + Cd2_p +Cap_p)* Cap_p ;
%Qi_n = Vcm * (CMtp_n + Cap_n) - (Vin+sqrt(del_ktc_n)*randn(1,1))*CMt_n - Vcm*(sum(Cl_n) + Cd_n + Cap_n)/(CLtp_n + Cd2_n +Cap_n)* Cap_n ;
Vall_p(1:M+L)=Vcm;
Vall_n(1:M+L)=Vcm;  %所有位对应的下极板开关
Vdum1_p = Vcm;
Vdum1_n = Vcm;
%%%%
if ctrl==1
    Vdit_p=0;
    Vdit_n=Vref;
end
if ctrl==-1
    Vdit_p=Vref;
    Vdit_n=0;
end
%%%%根据不同的控制调整dither电容下级版电压

for i=1:M+L %开始转换
    VMdam_p(1:M) = Vall_p(1:M);
    VMdam_n(1:M) = Vall_n(1:M);
    VLdam_p(1:L) = Vall_p(M+1:M+L);
    VLdam_n(1:L) = Vall_n(M+1:M+L);
    Vp = (Qi_p + Vdit_p*Cdit_p+VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
    Vn = (Qi_n + Vdit_n*Cdit_n+VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
    %Vp = (Qi_p +VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
    %Vn = (Qi_n +VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
    %Vdit_p*Cdit_p表示dither电容引入的电压改变
    Z=Vp-Vn; %比较器的差分输入大小
    if  Z > Comp_os+del_Compvn*randn(1,1) 
        Vall_p(i) = 0; Vall_n(i) = Vref; 
     
        dout(1,i)=0;%输出数字码
    else
        Vall_p(i)= Vref ; Vall_n(i)=0;

        dout(1,i)=1;%输出数字吗
    end 
end 
VMdam_p(1:M) = Vall_p(1:M);
VMdam_n(1:M) = Vall_n(1:M);
VLdam_p(1:L) = Vall_p(M+1:M+L);
VLdam_n(1:L) = Vall_n(M+1:M+L);
Vp = (Qi_p + Vdit_p*Cdit_p+VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p));  
Vn = (Qi_n + Vdit_p*Cdit_p+VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n));
Z=Vp-Vn; %比较器的差分输入大小
if  Z > Comp_os+del_Compvn*randn(1,1) 
   
    dout(1,18)=0;%输出数字码
else
    
    dout(1,18)=1;%输出数字码

end 

