function[weight_cal] = cal_dither(Wdit_real,weight,ns,u,ud,Vip_cal,Vin_cal,Vref,Vcm,M,L,Cm_p,...
    Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n,Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,...
    Comp_os,del_Compvn,del_ktc_p,del_ktc_n,Wda,WLda,W_Cc,WM_dummy,WL_dummy,Wdit,Cdit_p,Cdit_n)
%在ADC_core的基础上引入weight信息，ns是用于校准的样本数，u,ud是LMS收敛系数
  
%%收敛系数
err = zeros(ns,1);
weight_cal = zeros(ns,18);
weight_cal(1,:) = weight;
weight_curr=zeros(1,18);
delta_d_cal = zeros(ns,1);
delta_d_cal(1,1) = Wdit_real;

data_raw1=zeros(ns,18);
data_raw2=zeros(ns,18);
data_dig1=zeros(ns,1);
data_dig2=zeros(ns,1);
dout1=zeros(1,18);
dout2=zeros(1,18);
%%%%%开始转换%%%%%%%%%
for i = 1:ns
    weight_curr=weight_cal(i,:);
    ctrl=1; %插入正dither
    dout1 = adc_sar(Vip_cal(i,1),Vin_cal(i,1),Vref,Vcm,M,L,Cm_p,Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n,Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,Comp_os,del_Compvn,del_ktc_p,del_ktc_n,Wda,WLda,W_Cc,WM_dummy,WL_dummy,Wdit,Cdit_p,Cdit_n,ctrl); 
    dout1=2*dout1-1;
    data_raw1(i,:)=dout1;
    data_dig1(i,1) = dout1 * weight_curr';
    
    ctrl=-1;
    dout2= adc_sar(Vip_cal(i,1),Vin_cal(i,1),Vref,Vcm,M,L,Cm_p,Cm_n,Cl_p,Cl_n,Cd1_p,Cd1_n,Cd2_p,Cd2_n,Ca_p,Ca_n,Cp1_p,Cp1_n,Cp2_p,Cp2_n,Cp3_p,Cp3_n,Comp_os,del_Compvn,del_ktc_p,del_ktc_n,Wda,WLda,W_Cc,WM_dummy,WL_dummy,Wdit,Cdit_p,Cdit_n,ctrl); 
    dout2=2*dout2-1;
    data_raw2(i,:)=dout2;
    data_dig2(i,1) = dout2 * weight_curr';

err(i,1) = data_dig1(i,1) - data_dig2(i,1) - 2*delta_d_cal(i);%误差
for j=1:18
    weight_cal(i+1,j) = weight_cal(i,j) - u(j) * err(i) * (data_raw1(i,j) - data_raw2(i,j));
end
  %weight_cal(i+1,18) = weight_cal(i,18);
    delta_d_cal(i+1) = delta_d_cal(i) + ud * err(i);
end

end

