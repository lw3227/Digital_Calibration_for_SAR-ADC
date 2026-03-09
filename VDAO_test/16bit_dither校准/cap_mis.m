Cu=5.8;
del_Cu=0.03;
Wdit=1;
k=1;
M = 11; Wda = [1 1 1 1 1 1 1 1 1 1 1 1];   %高段位电容
L = 6; WLda=[1 1 1 1 1 1 1];   %低段位电容
Wdit=1; %dither插入电容的权重
WM_dummy = 1;   % 高位dummy
WL_dummy = 1;   % 低位dummy
W_Cc = 1;       % 桥接对应权重                             



Cdit_p =  Wdit*k*Cu + sqrt( Wdit*k)*fix((del_Cu*randn(1,1)*100))/100;
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