function result = calibration(Bit, ~, ~,Vref,Vcm,M,L,Cm_p,Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n,Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,Comp_os,del_Compvn,del_ktc_p,del_ktc_n,Wda,WLda,times) % calibration model
L_real=5; %%低位的实际位数
CLt_p=sum(Cl_p)+Cd2_p;
CMt_p=sum(Cm_p)+Cd1_p;
CLt_n=sum(Cl_n)+Cd2_n;
CMt_n=sum(Cm_n)+Cd1_n;
CLtp_p=CLt_p+Cp2_p;%LSB段总电容+寄生电容 p端
CLtp_n=CLt_n+Cp2_n;%LSB段总电容+寄生电容 n端
CMtp_p=CMt_p+Cp1_p;%MSB端总电容+寄生电容 p端
CMtp_n=CMt_n+Cp1_n;%MSB段总电容+寄生电容 n端
Cap_p=Ca_p+Cp3_p;%桥结电容带寄生电容
Cap_n=Ca_n+Cp3_n;
W_new(1:times) = 0;
Wda_real = Wda.*2^L_real;%     2^L_real是用来调整数字域中的权重
Wall(1:M+L) = [Wda_real WLda]; %所有位真实权重

for j = 1:times
    result_p = 0; 
    result_n = 0; 
    Vall_p(1:M+L)=0;
    Vall_n(1:M+L)=0;  %所有位对应的下极板开关状态
    Vdum1_p = Vcm + sqrt(del_ktc_p)*randn(1,1);%定义采样过程的噪声
    Vdum1_n = Vcm + sqrt(del_ktc_n)*randn(1,1);
    Vdum2_p = Vcm;
    Vdum2_n = Vcm;
    Vall_p(1:M+L) = Vcm;
    Vall_n(1:M+L) = Vcm;
    VMdam_p(1:M) = Vdum1_p;
    VMdam_n(1:M) = Vdum1_n;
    VLdam_p(1:L) = Vall_p(M+1:M+L);%LSB段电容底板均接到Vcm
    VLdam_n(1:L) = Vall_n(M+1:M+L);
    Qi_p = Vcm*(Cap_p+CMtp_p - Cap_p * Cap_p / (CLtp_p + Cap_p)) - VMdam_p*rot90(Cm_p,3) - Vdum1_p*Cd1_p - Cap_p*(VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)/(CLtp_p + Cap_p);
    Qi_n = Vcm*(Cap_n+CMtp_n - Cap_n * Cap_n / (CLtp_n + Cap_n)) - VMdam_n*rot90(Cm_n,3) - Vdum1_n*Cd1_n - Cap_n*(VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)/(CLtp_n + Cap_n);
    %以上两句是采样到顶板的电荷
    Vdum1_p = Vcm;
    Vdum1_n = Vcm;
    Vall_n(M+L-Bit+1) = Vref;   %开始校准那一位电容的n端电容底板接到VREF，p端电容底板接到0
    Vall_p(M+L-Bit+1) = 0;
    for i=L+M-Bit+2:M+L
        VMdam_p(1:M) = Vall_p(1:M);
        VMdam_n(1:M) = Vall_n(1:M);
        VLdam_p(1:L) = Vall_p(M+1:M+L);
        VLdam_n(1:L) = Vall_n(M+1:M+L);
        Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
        Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
    %     Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vcm*Cd2_p)*Cap_p/(CLtp_p+Cd2_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
    %     Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vcm*Cd2_n)*Cap_n/(CLtp_n+Cd2_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
        Z=Vp-Vn; %比较器的差分输入大小
        if  Z > Comp_os+del_Compvn*randn(1,1) 
            Vall_p(i) = 0; Vall_n(i) = Vref;  
            result_p= result_p - Wall(i);
        else
            Vall_p(i)= Vref ; Vall_n(i)=0;%比较得结果并移动对应电容的下极板（接Vref or gnd）；
            result_p= result_p + Wall(i);
        end  
    end
    VMdam_p(1:M) = Vall_p(1:M);
    VMdam_n(1:M) = Vall_n(1:M);
    VLdam_p(1:L) = Vall_p(M+1:M+L);
    VLdam_n(1:L) = Vall_n(M+1:M+L);
    Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
    Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
    % Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vcm*Cd2_p)*Cap_p/(CLtp_p+Cd2_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
    % Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vcm*Cd2_n)*Cap_n/(CLtp_n+Cd2_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
    Z=Vp-Vn;
    if Z < Comp_os+del_Compvn*randn(1,1)
        result_p = result_p+1/2;
    else
        result_p = result_p-1/2;
    end
    
    %以上是产生force0
    
    Vall_p(1:M+L) = Vcm;
    Vall_n(1:M+L) = Vcm; 
    Vall_p(M+L-Bit+1) = Vref;   %开始校准那一位电容的p端电容底板接到VREF，n端电容底板接到0
    Vall_n(M+L-Bit+1) = 0;
    for i=L+M-Bit+2:M+L
        VMdam_p(1:M) = Vall_p(1:M);
        VMdam_n(1:M) = Vall_n(1:M);
        VLdam_p(1:L) = Vall_p(M+1:M+L);
        VLdam_n(1:L) = Vall_n(M+1:M+L);
        Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
        Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
    %     Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vcm*Cd2_p)*Cap_p/(CLtp_p+Cd2_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
    %     Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vcm*Cd2_n)*Cap_n/(CLtp_n+Cd2_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
        Z=Vp-Vn; %比较器的差分输入大小
        if  Z > Comp_os+del_Compvn*randn(1,1) 
            Vall_p(i) = 0; Vall_n(i) = Vref; 
            result_n= result_n - Wall(i);
        else
            Vall_p(i)= Vref ; Vall_n(i)=0;%比较得结果并移动对应电容的下极板（接Vref or gnd）；
            result_n= result_n + Wall(i);
        end  
    end
    
   
    VMdam_p(1:M) = Vall_p(1:M);
    VMdam_n(1:M) = Vall_n(1:M);
    VLdam_p(1:L) = Vall_p(M+1:M+L);
    VLdam_n(1:L) = Vall_n(M+1:M+L);
    Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
    Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
    % Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vcm*Cd2_p)*Cap_p/(CLtp_p+Cd2_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
    % Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vcm*Cd2_n)*Cap_n/(CLtp_n+Cd2_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
    Z=Vp-Vn;
    if Z < Comp_os+del_Compvn*randn(1,1)
        result_n = result_n+1/2;
    else
        result_n= result_n-1/2;
    end
    W_new(j) = result_p-result_n;
end
   



if Bit>L
    result = round(sum(W_new)/times)/2^(L_real+1);   %检查被校准的这位电容是在高位还是低位，如果是高位的话则需要÷缩放比例
else 
    result = round(sum(W_new)/times)/2;
end

   %以上是产生force1

%****************************************************************************************************************************************************%
% L_real=5; %%低位的实际位数
% CLt_p=sum(Cl_p)+Cd2_p;
% CMt_p=sum(Cm_p)+Cd1_p;
% CLt_n=sum(Cl_n)+Cd2_n;
% CMt_n=sum(Cm_n)+Cd1_n;
% CLtp_p=CLt_p+Cp2_p;%LSB段总电容+寄生电容 p端
% CLtp_n=CLt_n+Cp2_n;%LSB段总电容+寄生电容 n端
% CMtp_p=CMt_p+Cp1_p;%MSB端总电容+寄生电容 p端
% CMtp_n=CMt_n+Cp1_n;%MSB段总电容+寄生电容 n端
% Cap_p=Ca_p+Cp3_p;%桥结电容带寄生电容
% Cap_n=Ca_n+Cp3_n;
% result = 0; 
% result_p = 0; 
% result_n = 0; 
% Vall_p(1:M+L)=0;
% Vall_n(1:M+L)=0;  %所有位对应的下极板开关状态
% Wda_real = Wda.*2^L_real;
% Wall(1:M+L) = [Wda_real WLda]; %所有位真实权重
% Vdum1_p = Vcm + sqrt(del_ktc_p)*randn(1,1);
% Vdum1_n = Vcm + sqrt(del_ktc_n)*randn(1,1);
% Vdum2_p = Vcm;
% Vdum2_n = Vcm;
% Vall_p(1:M+L) = Vcm;
% Vall_n(1:M+L) = Vcm;
% VMdam_p(1:M) = Vdum1_p;
% VMdam_n(1:M) = Vdum1_n;
% VLdam_p(1:L) = Vall_p(M+1:M+L);
% VLdam_n(1:L) = Vall_n(M+1:M+L);
% Qi_p = Vcm*(Cap_p+CMtp_p - Cap_p * Cap_p / (CLtp_p + Cap_p)) - VMdam_p*rot90(Cm_p,3) - Vdum1_p*Cd1_p - Cap_p*(VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)/(CLtp_p + Cap_p);
% Qi_n = Vcm*(Cap_n+CMtp_n - Cap_n * Cap_n / (CLtp_n + Cap_n)) - VMdam_n*rot90(Cm_n,3) - Vdum1_n*Cd1_n - Cap_n*(VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)/(CLtp_n + Cap_n);
% % Qi_p = Vcm * (CMtp_p + Cap_p) - (Vip+sqrt(del_ktc_p)*randn(1,1))*CMt_p - Vcm*(sum(Cl_p) + Cd2_p + Cap_p)/(CLtp_p + Cd2_p +Cap_p)* Cap_p ;
% % Qi_n = Vcm * (CMtp_n + Cap_n) - (Vin+sqrt(del_ktc_n)*randn(1,1))*CMt_n - Vcm*(sum(Cl_n) + Cd2_n + Cap_n)/(CLtp_n + Cd2_n +Cap_n)* Cap_n ;
% Vdum1_p = Vcm;
% Vdum1_n = Vcm;
% Vall_n(M+L-Bit+1) = Vref;
% Vall_p(M+L-Bit+1) = 0;
% for i=L+M-Bit+2:M+L
%     VMdam_p(1:M) = Vall_p(1:M);
%     VMdam_n(1:M) = Vall_n(1:M);
%     VLdam_p(1:L) = Vall_p(M+1:M+L);
%     VLdam_n(1:L) = Vall_n(M+1:M+L);
%     Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
%     Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
% %     Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vcm*Cd2_p)*Cap_p/(CLtp_p+Cd2_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
% %     Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vcm*Cd2_n)*Cap_n/(CLtp_n+Cd2_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
%     Z=Vp-Vn; %比较器的差分输入大小
%     if  Z > Comp_os+del_Compvn*randn(1,1) 
%         Vall_p(i) = 0; Vall_n(i) = Vref;  
%     else
%         Vall_p(i)= Vref ; Vall_n(i)=0;%比较得结果并移动对应电容的下极板（接Vref or gnd）；
%         result_p= result_p + 2*Wall(i);
%     end  
% end
% VMdam_p(1:M) = Vall_p(1:M);
% VMdam_n(1:M) = Vall_n(1:M);
% VLdam_p(1:L) = Vall_p(M+1:M+L);
% VLdam_n(1:L) = Vall_n(M+1:M+L);
% Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
% Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
% % Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vcm*Cd2_p)*Cap_p/(CLtp_p+Cd2_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
% % Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vcm*Cd2_n)*Cap_n/(CLtp_n+Cd2_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
% Z=Vp-Vn;
% if Z < Comp_os+del_Compvn*randn(1,1)
%     result_p = result_p+1/2;
% end
% 
% 
% 
% Vall_p(1:M+L) = Vcm;
% Vall_n(1:M+L) = Vcm; 
% Vall_p(M+L-Bit+1) = Vref;
% Vall_n(M+L-Bit+1) = 0;
% for i=L+M-Bit+2:M+L
%     VMdam_p(1:M) = Vall_p(1:M);
%     VMdam_n(1:M) = Vall_n(1:M);
%     VLdam_p(1:L) = Vall_p(M+1:M+L);
%     VLdam_n(1:L) = Vall_n(M+1:M+L);
%     Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
%     Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
% %     Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vcm*Cd2_p)*Cap_p/(CLtp_p+Cd2_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
% %     Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vcm*Cd2_n)*Cap_n/(CLtp_n+Cd2_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
%     Z=Vp-Vn; %比较器的差分输入大小
%     if  Z > Comp_os+del_Compvn*randn(1,1) 
%         Vall_p(i) = 0; Vall_n(i) = Vref; 
%     else
%         Vall_p(i)= Vref ; Vall_n(i)=0;%比较得结果并移动对应电容的下极板（接Vref or gnd）；
%         result_n= result_n + 2*Wall(i);
%     end  
% end
% %最后一次比较
% VMdam_p(1:M) = Vall_p(1:M);
% VMdam_n(1:M) = Vall_n(1:M);
% VLdam_p(1:L) = Vall_p(M+1:M+L);
% VLdam_n(1:L) = Vall_n(M+1:M+L);
% Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum1_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vdum2_p*Cd2_p)*Cap_p/(CLtp_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
% Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum1_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vdum2_n*Cd2_n)*Cap_n/(CLtp_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
% % Vp = (Qi_p + VMdam_p*rot90(Cm_p,3) + Vdum_p*Cd1_p + (VLdam_p*rot90(Cl_p,3) + Vcm*Cd2_p)*Cap_p/(CLtp_p+Cd2_p+Cap_p))/(CMtp_p + Cap_p - Cap_p*Cap_p/(CLtp_p+Cap_p)); 
% % Vn = (Qi_n + VMdam_n*rot90(Cm_n,3) + Vdum_n*Cd1_n + (VLdam_n*rot90(Cl_n,3) + Vcm*Cd2_n)*Cap_n/(CLtp_n+Cd2_n+Cap_n))/(CMtp_n + Cap_n - Cap_n*Cap_n/(CLtp_n+Cap_n)); 
% Z=Vp-Vn;
% if Z < Comp_os+del_Compvn*randn(1,1)
%     result_n = result_n+1;
% end
% 
% 
% if Bit>L
%     result = (result_p-result_n)/2^(L_real+1);
% else 
%     result = (result_p-result_n)/2;
% end

 