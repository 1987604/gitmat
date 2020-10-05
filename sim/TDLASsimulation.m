clear;clc;

% FWHM = 0.07060; %半峰全宽 0.06024156668nm ， 0.15 cm-1  % 0.07460  %0.102 
HWHM = 0.0373; %半峰半宽

concentration = 100*1e-6;  % 气体体积比浓度 0.01, 0.1, 0.2, 0.3, 0.5, 0.7
f_saw = 50; % 锯齿频率10,20,30,40,50,60,70,80,90,100

n = 2; % 调制比[0.2，0.6，0.8,1，1.2，1.4]，调制比为，最佳调制比越 大，峰型越不好，调至比越小，峰值越小，
f_modulation =  n * HWHM; % 正弦振幅调制比[0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7]

fre_mdulation = 20; % 频率调制比为  时幅值最大。[0.04e6, 0.06e4,0.08e4,0.1e4, 0.4e4, 0.8e4,1e4,2e4,4e4,8e4]
f_sin = fre_mdulation *  10^3; %正弦调制频率200kHz  不同调制比(正弦波/锯齿波)[5.6k，5.8k，6k，6.2k，6.5k]

sample_rate_num = 1;
f_sample  = sample_rate_num * 10^6; % 采样频率1MHz * 调整参数r
N_sin = f_sample / f_sin ; % 在整个采集过程中的每个正弦波采集的点数
disp("每个锯齿范围正弦波数："+ f_sin / f_saw);
disp("每个正弦波采样点数："+ N_sin);
% 1 原始波形
sample_time = 1 * 1/f_saw; %  1个周期
t = 0:sample_time/f_sample:sample_time; % sample_time秒内采集f_sample+1个点
noise = rand(1,f_sample+1);
% noise =  dsp.ColoredNoise;
% noise=0;
% saw_line = 2000 + 80 * t;
% 中心波长 2004.01946nm
saw_line = sawtooth(2 * pi * f_saw * t);  % 4989.966cm-1  y=0.075
% saw_line = 2004 + ( fx / sample_time) * (t - sample_time / 2); % 锯齿扫描信号
sin_line = sin(2 * pi * f_sin*t ); % 经过调制的正弦信号

%  scanvalue为扫描幅度，f_modulation为调制幅度
scanvalue = 1;
multi_line = scanvalue * saw_line + f_modulation * sin_line; % 吸收频率调制
% figure(1);
% plot(t,multi_line);
% title("频率调制信号");

%光源信号输出， 70为直流偏置i0，20是光强调制系数m，公式为i(t) = i0*(1+m*[cos(wt)+sawtooth(t)])
% 吸收光强, 输出的结果需要叠加一个模拟噪声 单位 mW。
% light = 3 + ( 2.4 / sample_time ) * (t - sample_time / 2) + (f_modulation/0.029 * 0.04) * sin(2 * pi *f_sin*t ) + noise;
% light = 3.8 + 0.29 * sawtooth(2*pi*f_saw *t) + (f_modulation/0.029*0.05) * sin(2 * pi *f_sin*t );
% light = 70 + 20*sawtooth(2*pi*f_saw*t)+20*f_modulation*sin(2*pi*f_sin*t);

light = 70 *(1 + multi_line);
%波长信号输出， 2004为激光器输出中心波长v0，f_modulation为波长调制系数n，公式为v(t) = v0*(1+n*[cos(wt)+sawtooth(t)])
x = 1;  % 修改扫描波长范围
multi_signal = 2004 + x * (saw_line + f_modulation * sin_line);

% 2 lorentz线型吸收
St =   (HWHM/(2*pi)) ./((multi_signal - 2004.01946).^2 + (HWHM/2)^2);
% St =   (HWHM/(2*pi)) ./(().^2 + (HWHM/2)^2);
% St =   (HWHM/(pi)) ./((saw_line + 2004.01946- 2004.01946).^2 + (HWHM)^2);
% St = St/max(St);
% plot(St);
% 浓度*压力*吸光系数*光程*吸收函数
% NPLS = -1 *concentration * 1.32e-21 * 2.687e19 * 1 * 16 * St;  
NPLS = -1 * concentration  * 2.687e19 * (273.15/298) * 1.28e-21  * 1 *1600 * St;
% NPLS = -1 * concentration  *(273.15/298)* 1.28e-21  * 1 *1600 * St;


% absorbtion = light .* exp(NPLS)+ noise;
absorption1 = light .* exp(NPLS);
abs = (light - absorption1) ./ light;
figure(2);
plot(t,abs);
xlabel("一个周期/t");
title("吸收率")
% % 
figure(3);
plot(t,absorption1);
xlabel("时间/t");
ylabel("透射光强度");
title("透射光强度与时间关系")
% 归一化
% absorption = wdenoise(absorption1,9,'NoiseEstimate','LevelIndependent');
absorption = absorption1;
absorption_min = min(absorption);
absorption_max = max(absorption);
absorption_after = 1e2 * (absorption-absorption_min)/ (absorption_max-absorption_min); % 吸收归一化
% figure(9)
% plot(absorption_after);
%%%%%%%%%%%%%%%%%%%%%%%%         Allan方差              %%%%%%%%%%%%%%%%%%
% [avar,tau] = allanvar(absorption_after,'octave');
% figure(11);
% loglog(tau,avar)
% xlabel('\tau')
% ylabel('\sigma^2(\tau)')
% title('Allan Variance')
% grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3 调制解调过程
%设计相敏检测器与锁相放大器

times = 2; 
phi = pi/4;
ref_sin = 1*sin(2*pi*times*f_sin*t+phi);
ref_cos = 1*sin(2*pi*times*f_sin*t+phi+pi/2);
ref_2f_sin = ref_sin .* absorption_after;
ref_2f_cos = ref_cos .* absorption_after;
% figure(8)

% subplot(211)
% title("正弦参考信号与吸收信号相乘")
% plot(t,ref_2f_sin,"r");
% subplot(212)
% title("余弦参考信号与吸收信号相乘")
% plot(t,ref_2f_cos);

% 滤波器
% WP =6e-06; WS = 4e-4; % 手动设置巴特沃夫滤波器参数
WP = f_saw*4/f_sample; WS = f_sin*0.2/f_sample;%WP = f_saw*1.2/Fs; WS = f_sin*1.75/Fs;
% % WP = f_saw*1/f_sample; WS = f_saw*10/f_sample;
disp("通带截止频率："+WP+"；阻带截止频率："+WS);
[N,WN] = buttord(WP,WS,3,40);
[B,A]= butter(N,WN);%butter
filter_2f_sin0 = filter(B,A,ref_2f_sin);
filter_2f_sin1 = filter(B,A,filter_2f_sin0);
filter_2f_cos0 = filter(B,A,ref_2f_cos);
filter_2f_cos1 = filter(B,A,filter_2f_cos0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(6)
% subplot(211);
% plot(filter_2f_sin0);
% title("sin第一次滤波")
% subplot(212)
% plot(filter_2f_sin1);
% title("sin第二次滤波")

figure(7)
subplot(211);
plot(filter_2f_cos0);
title("cos第一次滤波")
subplot(212)
plot(filter_2f_cos1);
title("cos第二次滤波")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
answer_one = -1*((filter_2f_cos1) + (filter_2f_sin1)); % 直接解调n次谐波
% answer = sqrt(((filter_2f_sin) + (filter_2f_cos)).^2); %将原始图像转至y轴正数
answer = sqrt((filter_2f_cos1).^2 + (filter_2f_sin1).^2); % 求二次谐波的幅值
% maxvalue = abs(min(answer)); %原始波形的最小值的绝对值作为谐波峰值

maxvalue = max(answer); 
minvalue = min(answer);
mode_num = mode(noise);
SNR_number = 10 * log10((maxvalue - minvalue) / mode_num);
disp("二次谐波峰值: " + maxvalue);
disp("噪声众数: " + mode_num);
disp("信噪比数值(SNR): " +  SNR_number);
figure(4);
plot(answer_one);
% plot(answer(floor(0.2*length(answer)):floor(0.9*length(answer))));
% plot(t,answer_one);
xlabel("采样点");
ylabel("幅值/mV");
% legend("1","2","3","4")
hold on

% [a,b] = fit(x',y',"poly1");

% 浓度变化写入文件中
% fid = fopen("sim/concentrationData.txt","a+");
% % fprintf(fid," %f",concentration);
% fprintf(fid," %f",answer);
% fprintf(fid,"\n");
% fclose("all");
% 调制变化写入文件


% fclose("all");