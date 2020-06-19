clear;clc;
concentration = 0.6;  % ���������Ũ�� 0.01, 0.1, 0.2, 0.3, 0.5, 0.7
f_saw = 10; % ���Ƶ��10
f_modulation =  0.06 ; % ����������Ʊ�[0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7]
fre_mdulation = 1; % Ƶ�ʵ��Ʊ�[0.04e4, 0.06e4,0.08e4,0.1e4, 0.4e4, 0.8e4,1e4,2e4,4e4,8e4]
f_sin = fre_mdulation * 100 * 10^3; %���ҵ���Ƶ��200kHz  ��ͬ���Ʊ�(���Ҳ�/��ݲ�)[5.6k��5.8k��6k��6.2k��6.5k]
f_sample  = 1 * 10^6; % ����Ƶ��1MHz
N_sin = f_sample / f_sin ; % �������ɼ������е����Ҳ�����
HWHM = 0.9954; %�����

% 1 ԭʼ����
sample_time = 0.1;
t = linspace(0,0.1,10^6); % 0.1���ڲɼ�10�����
noise = rand(1,10^6) /10;
saw_line = 2000 + 80*t; % ���ɨ���ź�
sin_line = f_modulation * sin(2 * pi *f_sin*t ); % �������Ƶ������ź�
% figure(1);
multi_line = saw_line + sin_line; % ����Ƶ�ʵ���
% plot(t,multi_line);

% 2 lorentz��������
St = (HWHM/(2*pi)) ./((multi_line - 2004).^2 + (HWHM/2)^2);
% Ũ��*ѹ��*���*���պ���
NPLS = -1 *concentration * 1.32e-21 * 2.687e19 * 1 * 16 * St;
% ���չ�ǿ, ����Ľ����Ҫ����һ��ģ������
light = 2 + 20 * t;
% absorbtion = light .* exp(NPLS)+ noise;
absorbtion = light .* exp(NPLS);
% figure(2);
% plot(t,absorbtion_after);

% ��һ��
absorbtion_min = min(absorbtion);
absorbtion_max = max(absorbtion);
absorbtion_after = (absorbtion - absorbtion_min)/ absorbtion_max;
%3 ���ƽ������
%������������������Ŵ���
ref_sin = sin(2*pi*2*f_sin*t);
ref_cos = cos(2*pi*2*f_sin*t);
ref_2f_sin = ref_sin .* absorbtion_after;
ref_2f_cos = ref_cos .* absorbtion_after;
% �˲���
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

 
% Ũ�ȱ仯д���ļ���
fid = fopen("sim/concentrationData.txt","a+");
fprintf(fid," %f",concentration);
fprintf(fid," %f",answer);
fprintf(fid,"\n");
fclose("all");
% ���Ʊ仯д���ļ�


% fclose("all");