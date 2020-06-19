
clear;
clear all;
subdir='C:\Users\DELL\Desktop\LABVIEW\����궨ʵ������4.21\����궨ʵ������4.21\Standard-501ppm\';
FL=dir(subdir);
FL(1:2)=[];%ȥ������Ҫ�ı���
r=zeros(1,length(FL));
for i=2:7
 AA=load([subdir FL(i).name]);
%AA=load('D:\DATA\101601\OR_100_100K_5M_003.txt');
A2=AA(:,2);
f_saw=50;%���Ƶ��100
f_sin=200*10^3;%����Ƶ��100K
Fs= 10*10^6;%����Ƶ��5M
N_sin=Fs/f_sin; %N_saw=Fs/f_saw;
%N_saw=10000;
%N_saw=20001;
N_saw=40001;
N=N_saw;
t = 0:1/Fs:((N_saw-1)/Fs); 
%328-200=128,
       I1=A2(60000:100000)';%��ȡ����һ������
     %I1=AA';
   figure(1)
 subplot(211);
 plot(I1)
 title('��ȡ�ź�');
 xlabel('��������');
 ylabel('�źŷ�ֵ');
 hold on
     I=wden(I1,'heursure','s','one',1,'sym11');%rbio2.2С��ȥ��
%   figure(1)
%  subplot(212);
%  plot(I)
%  title('ȥ���ź�');
%  xlabel('��������');
 %ylabel('�źŷ�ֵ');
 %%%��һ��
 MinValue=min(I);
 MaxValue=max(I);
   
 I_normal=(I-MinValue)/(MaxValue-MinValue);%��һ��֮������
%    figure(1)
%  subplot(212);
%  plot(I_normal)
%  title('��һ���ź�');
%  xlabel('��������');
%  ylabel('�źŷ�ֵ');
%   hold on
   %*SCAL='one' ��������       
%*SCAL='sln'   
%���ݵ�һ���ϵ������������Ĺ�����������ֵ��     
%*SCAL='mln'  
%���ݲ�ͬ������������������ֵ��

%     snr1(i)=SNR_singlech(I,I1);
%     snr2(i)=SNR_singlech(I_0,I2);

    ref_2f_sin =I_normal.*sin(4*pi*f_sin*t);  
    ref_2f_cos =I_normal.*cos(4*pi*f_sin*t+1); 
         
     mul2f_sin = 100*(ref_2f_sin).*I_normal;         
     mul2f_cos = 100*(ref_2f_cos).*I_normal;              %��1·�źŷֱ����

%%%%%%%%%%%%%%% ������˹�˲������ %%%%%%%%%%%%%%%%
%Wp = f_saw*2/Fs; Ws = f_sin*1/Fs;    %ͨ����ֹƵ��=f_saw=100Hz,�����ֹƵ��=f_sin=30kHz,����Ƶ��Fs=30000000Hz.���Բ����ʵ�һ�룬���й�һ��
% Wp = f_saw*1.3/Fs; Ws = f_sin*1.5/Fs;
% [n,Wn] = buttord(Wp,Ws,3,85);   %ͨ�����˥��1dB�������С˥��50dB��

%  wp = f_saw*0.1/Fs; ws = f_sin*1/5/Fs;%wp = f_saw*1.5/Fs; ws = f_sin*2.2/Fs;
% [n,Wn] = buttord(wp,ws,3,60);
% [b,a]=butter(n,Wn);%butter  

% WP = f_saw*2.05/Fs; WS = f_sin*1.85/Fs;%WP = f_saw*1.2/Fs; WS = f_sin*1.75/Fs;
% % [N,WN] = buttord(WP,WS,1,55);
% [B,A]=butter(N,WN);%butter
% %[n,Wn] = ellipord(WP,WS,3,55);%cheb2ord
%  [B,A]=butter(n,Wn);    %butter������Ƶ�ͨ����ͨ����ͨ���ʹ������ֺ�ģ��İ�����˹�˲�����
WP = f_saw*20/Fs; WS = f_sin*1/Fs;%WP = f_saw*1.2/Fs; WS = f_sin*1.75/Fs;
[N,WN] = buttord(WP,WS,0.3,50);
[B,A]=butter(N,WN);%butter
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�ڶ�·�ź��˲�%%%%%%%%%%%%%%%%%%%
filter_2f_cos0 = filter(B,A,ref_2f_sin);
%  figure(2)
%  subplot(211);
%  plot(filter_2f_cos0)
 %axis([10000,25000,-20,20]);
%  title('cos�źŵ�һ���˲�');
%  xlabel('��������');
%  ylabel('�źŷ�ֵ');
%  %axis([10000,25000,-20,20]);
%   hold on
filter_2f_cos = filter(B,A,filter_2f_cos0);
 figure(3)
 subplot(211);
 plot(filter_2f_cos)
 %axis([10000,25000,-20,20]);
 title('cos�źŵڶ����˲�');
 xlabel('��������');
 ylabel('�źŷ�ֵ');
 hold on
filter_2f_sin0 = filter(B,A,ref_2f_cos);
%  figure(2)
%  subplot(212);
%  plot(filter_2f_sin0)
%   title('sin�źŵ�һ���˲�');
%  xlabel('��������');
%  ylabel('�źŷ�ֵ');
 %axis([10000,25000,-20,20]);
 %%%   hold on
filter_2f_sin = filter(B,A,filter_2f_sin0);
 figure(3)
 subplot(212);
 plot(filter_2f_sin)
  %axis([10000,25000,-20,20]);
  title('sin�źŵڶ����˲�');
 xlabel('��������');
 ylabel('�źŷ�ֵ');
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

  
%���ֵ
%   Z(i)=max(filter_2f_cos(13500:17200));
% 
%   figure(2)
%   subplot(211)
%   plot(Z)

end
%y=(x-MinValue)/(MaxValue-MinValue); %����һ��0 1 ֮�䣩
% figure(5)
% plot(ymax);
% hold on
%zz=max(result(30000:45000))
%nihe=Z(45:126);
%T=Z';
%T_1=Z1';

mean( maxresult(2:7))