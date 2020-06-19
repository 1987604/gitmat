clear;clc;
concentration = 0.6;  % 气体体积比浓度 0.01, 0.1, 0.2, 0.3, 0.5, 0.7
f_saw = 10; % 锯齿频率10
f_modulation =  0.06 ; % 正弦振幅调制比[0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7]
fre_mdulation = 1; % 频率调制比[0.04e4, 0.06e4,0.08e4,0.1e4, 0.4e4, 0.8e4,1e4,2e4,4e4,8e4]
f_sin = fre_mdulation * 100 * 10^3; %正弦调制频率200kHz  不同调制比(正弦波/锯齿波)[5.6k，5.8k，6k，6.2k，6.5k]
f_sample  = 1 * 10^6; % 采样频率1MHz
N_sin = f_sample / f_sin ; % 在整个采集过程中的正弦波个数
HWHM = 0.9954; %半峰半宽

% 1 原始波形
sample_time = 0.1;
t = linspace(0,0.1,10^6); % 0.1秒内采集10万个点
noise = rand(1,10^6) /10;
saw_line = 2000 + 80*t; % 锯齿扫描信号
sin_line = f_modulation * sin(2 * pi *f_sin*t ); % 经过调制的正弦信号
% figure(1);
multi_line = saw_line + sin_line; % 吸收频率调制
% plot(t,multi_line);

% 2 lorentz线型吸收
St = (HWHM/(2*pi)) ./((multi_line - 2004).^2 + (HWHM/2)^2);
% 浓度*压力*光程*吸收函数
NPLS = -1 *concentration * 1.32e-21 * 2.687e19 * 1 * 16 * St;
% 吸收光强, 输出的结果需要叠加一个模拟噪声
light = 2 + 20 * t;
% absorbtion = light .* exp(NPLS)+ noise;
absorbtion = light .* exp(NPLS);
% figure(2);
% plot(t,absorbtion_after);

% 归一化
absorbtion_min = min(absorbtion);
absorbtion_max = max(absorbtion);
absorbtion_after = (absorbtion - absorbtion_min)/ absorbtion_max;
%3 调制解调过程
%设计相敏检测器与锁相放大器
ref_sin = sin(2*pi*2*f_sin*t);
ref_cos = cos(2*pi*2*f_sin*t);
ref_2f_sin = ref_sin .* absorbtion_after;
ref_2f_cos = ref_cos .* absorbtion_after;
% 滤波器
WP = f_saw*1/f_sample; WS = f_sin*0.05/f_sample;%WP = f_saw*1.2/Fs; WS = f_sin*1.75/Fs;
[N,WN] = buttord(WP,WS,0.5,50);
[B,A]=butter(N,WN);%butter
filter_2f_cos0 = filter(B,A,ref_2f_sin);
filter_2f_cos = filter(B,A,filter_2f_cos0);
filter_2f_sin0 = filter(B,A,ref_2f_cos);
filter_2f_sin = filter(B,A,filter_2f_sin0);

answer = sqrt((filter_2f_sin).^2 + (filter_2f_cos).^2);
maxvalue = max(answer);
disp(maxvalue);
figure(3);
plot(t,answer);
% [a,b] = fit(x',y',"poly1");

 
% 浓度变化写入文件中
fid = fopen("sim/concentrationData.txt","a+");
fprintf(fid," %f",concentration);
fprintf(fid," %f",answer);
fprintf(fid,"\n");
fclose("all");
% 调制变化写入文件


% fclose("all");