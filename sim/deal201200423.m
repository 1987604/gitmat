
clear;
clear all;
subdir='C:\Users\DELL\Desktop\LABVIEW\气体标定实验数据4.21\气体标定实验数据4.21\Standard-501ppm\';
FL=dir(subdir);
FL(1:2)=[];%去掉不需要的变量
r=zeros(1,length(FL));
for i=2:7
 AA=load([subdir FL(i).name]);
%AA=load('D:\DATA\101601\OR_100_100K_5M_003.txt');
A2=AA(:,2);
f_saw=50;%锯齿频率100
f_sin=200*10^3;%调制频率100K
Fs= 10*10^6;%采样频率5M
N_sin=Fs/f_sin; %N_saw=Fs/f_saw;
%N_saw=10000;
%N_saw=20001;
N_saw=40001;
N=N_saw;
t = 0:1/Fs:((N_saw-1)/Fs); 
%328-200=128,
       I1=A2(60000:100000)';%截取其中一段数据
     %I1=AA';
   figure(1)
 subplot(211);
 plot(I1)
 title('截取信号');
 xlabel('采样点数');
 ylabel('信号幅值');
 hold on
     I=wden(I1,'heursure','s','one',1,'sym11');%rbio2.2小波去燥
%   figure(1)
%  subplot(212);
%  plot(I)
%  title('去噪信号');
%  xlabel('采样点数');
 %ylabel('信号幅值');
 %%%归一化
 MinValue=min(I);
 MaxValue=max(I);
   
 I_normal=(I-MinValue)/(MaxValue-MinValue);%归一化之后数据
%    figure(1)
%  subplot(212);
%  plot(I_normal)
%  title('归一化信号');
%  xlabel('采样点数');
%  ylabel('信号幅值');
%   hold on
   %*SCAL='one' 不调整；       
%*SCAL='sln'   
%根据第一层的系数进行噪声层的估计来调整阈值。     
%*SCAL='mln'  
%根据不同的噪声估计来调整阈值。

%     snr1(i)=SNR_singlech(I,I1);
%     snr2(i)=SNR_singlech(I_0,I2);

    ref_2f_sin =I_normal.*sin(4*pi*f_sin*t);  
    ref_2f_cos =I_normal.*cos(4*pi*f_sin*t+1); 
         
     mul2f_sin = 100*(ref_2f_sin).*I_normal;         
     mul2f_cos = 100*(ref_2f_cos).*I_normal;              %第1路信号分别相乘

%%%%%%%%%%%%%%% 巴特沃斯滤波器设计 %%%%%%%%%%%%%%%%
%Wp = f_saw*2/Fs; Ws = f_sin*1/Fs;    %通带截止频率=f_saw=100Hz,阻带截止频率=f_sin=30kHz,采样频率Fs=30000000Hz.除以采样率的一半，进行归一化
% Wp = f_saw*1.3/Fs; Ws = f_sin*1.5/Fs;
% [n,Wn] = buttord(Wp,Ws,3,85);   %通带最大衰减1dB，阻带最小衰减50dB。

%  wp = f_saw*0.1/Fs; ws = f_sin*1/5/Fs;%wp = f_saw*1.5/Fs; ws = f_sin*2.2/Fs;
% [n,Wn] = buttord(wp,ws,3,60);
% [b,a]=butter(n,Wn);%butter  

% WP = f_saw*2.05/Fs; WS = f_sin*1.85/Fs;%WP = f_saw*1.2/Fs; WS = f_sin*1.75/Fs;
% % [N,WN] = buttord(WP,WS,1,55);
% [B,A]=butter(N,WN);%butter
% %[n,Wn] = ellipord(WP,WS,3,55);%cheb2ord
%  [B,A]=butter(n,Wn);    %butter用来设计低通、带通、高通、和带阻数字和模拟的巴特沃斯滤波器。
WP = f_saw*20/Fs; WS = f_sin*1/Fs;%WP = f_saw*1.2/Fs; WS = f_sin*1.75/Fs;
[N,WN] = buttord(WP,WS,0.3,50);
[B,A]=butter(N,WN);%butter
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%第二路信号滤波%%%%%%%%%%%%%%%%%%%
filter_2f_cos0 = filter(B,A,ref_2f_sin);
%  figure(2)
%  subplot(211);
%  plot(filter_2f_cos0)
 %axis([10000,25000,-20,20]);
%  title('cos信号第一次滤波');
%  xlabel('采样点数');
%  ylabel('信号幅值');
%  %axis([10000,25000,-20,20]);
%   hold on
filter_2f_cos = filter(B,A,filter_2f_cos0);
 figure(3)
 subplot(211);
 plot(filter_2f_cos)
 %axis([10000,25000,-20,20]);
 title('cos信号第二次滤波');
 xlabel('采样点数');
 ylabel('信号幅值');
 hold on
filter_2f_sin0 = filter(B,A,ref_2f_cos);
%  figure(2)
%  subplot(212);
%  plot(filter_2f_sin0)
%   title('sin信号第一次滤波');
%  xlabel('采样点数');
%  ylabel('信号幅值');
 %axis([10000,25000,-20,20]);
 %%%   hold on
filter_2f_sin = filter(B,A,filter_2f_sin0);
 figure(3)
 subplot(212);
 plot(filter_2f_sin)
  %axis([10000,25000,-20,20]);
  title('sin信号第二次滤波');
 xlabel('采样点数');
 ylabel('信号幅值');
% 
% hold on
 result=filter_2f_sin.^2+filter_2f_cos.^2;
 maxresult(i)=max(result(29100:29450));
 %r(1,i)=maxresult(i);
% ymax=result';
 figure (4)
  plot(result)
   %axis([10000,25000,0,400]);
  hold on

  
%求峰值
%   Z(i)=max(filter_2f_cos(13500:17200));
% 
%   figure(2)
%   subplot(211)
%   plot(Z)

end
%y=(x-MinValue)/(MaxValue-MinValue); %（归一到0 1 之间）
% figure(5)
% plot(ymax);
% hold on
%zz=max(result(30000:45000))
%nihe=Z(45:126);
%T=Z';
%T_1=Z1';

mean( maxresult(2:7))