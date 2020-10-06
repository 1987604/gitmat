clear;clc;

% FWHM = 0.07060; %���ȫ�� 0.06024156668nm �� 0.15 cm-1  % 0.07460  %0.102 
HWHM = 0.0373; %�����

concentration = 600*1e-6;  % ���������Ũ�� 0.01, 0.1, 0.2, 0.3, 0.5, 0.7
f_saw = 10; % ���Ƶ��10,20,30,40,50,60,70,80,90,100

n = 2.2; % ���Ʊ�[0.2��0.6��0.8,1��1.2��1.4]�����Ʊ�Ϊ����ѵ��Ʊ�Խ �󣬷���Խ���ã�������ԽС����ֵԽС��
f_modulation =  n * HWHM; % ����������Ʊ�[0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7]

fre_mdulation = 10; % Ƶ�ʵ��Ʊ�Ϊ  ʱ��ֵ���[0.04e6, 0.06e4,0.08e4,0.1e4, 0.4e4, 0.8e4,1e4,2e4,4e4,8e4]
f_sin = fre_mdulation *  10^3; %���ҵ���Ƶ��200kHz  ��ͬ���Ʊ�(���Ҳ�/��ݲ�)[5.6k��5.8k��6k��6.2k��6.5k]

sample_rate_num = 1;
f_sample  = sample_rate_num * 10^6; % ����Ƶ��1MHz * ��������r
N_sin = f_sample / f_sin ; % �������ɼ������е�ÿ�����Ҳ��ɼ��ĵ���
disp("ÿ����ݷ�Χ���Ҳ�����"+ f_sin / f_saw);
disp("ÿ�����Ҳ�����������"+ N_sin);
% 1 ԭʼ����
sample_time = 1 * 1/f_saw; %  1������
t = 0:sample_time/(f_sample/f_saw):sample_time; % sample_time���ڲɼ�f_sample+1����
noise = rand(1,f_sample+1);
% noise =  dsp.ColoredNoise;
% noise=0;
% saw_line = 2000 + 80 * t;
% ���Ĳ��� 2004.01946nm
saw_line = sawtooth(2 * pi * f_saw * t);  % 4989.966cm-1  y=0.075
% saw_line = 2004 + ( fx / sample_time) * (t - sample_time / 2); % ���ɨ���ź�
sin_line = sin(2 * pi * f_sin*t ); % �������Ƶ������ź�

%  scanvalueΪɨ����ȣ�f_modulationΪ���Ʒ���
scanvalue = 1;
multi_line = scanvalue * saw_line + f_modulation * sin_line; % ����Ƶ�ʵ���
% figure(1);
% plot(t,multi_line);
% title("Ƶ�ʵ����ź�");

%��Դ�ź������ 70Ϊֱ��ƫ��i0��20�ǹ�ǿ����ϵ��m����ʽΪi(t) = i0*(1+m*[cos(wt)+sawtooth(t)])
% ���չ�ǿ, ����Ľ����Ҫ����һ��ģ������ ��λ mW��
% light = 3 + ( 2.4 / sample_time ) * (t - sample_time / 2) + (f_modulation/0.029 * 0.04) * sin(2 * pi *f_sin*t ) + noise;
% light = 3.8 + 0.29 * sawtooth(2*pi*f_saw *t) + (f_modulation/0.029*0.05) * sin(2 * pi *f_sin*t );
% light = 70 + 20*sawtooth(2*pi*f_saw*t)+20*f_modulation*sin(2*pi*f_sin*t);
light = 70  + 20 * multi_line;

%�����ź������ 2004Ϊ������������Ĳ���v0��f_modulationΪ��������ϵ��n����ʽΪv(t) = v0*(1+n*[cos(wt)+sawtooth(t)])
x = 1;  % �޸�ɨ�貨����Χ
multi_signal = 2004 + x * multi_line;
% 2 lorentz��������
St =   (HWHM/(2*pi)) ./((multi_signal - 2004.01946).^2 + (HWHM/2)^2);
% St =   (HWHM/(2*pi)) ./(().^2 + (HWHM/2)^2);
% St =   (HWHM/(pi)) ./((saw_line + 2004.01946- 2004.01946).^2 + (HWHM)^2);
% St = St/max(St);
% plot(St);
% Ũ��*ѹ��*����ϵ��*���*���պ���
% NPLS = -1 *concentration * 1.32e-21 * 2.687e19 * 1 * 16 * St;  
NPLS = -1 * concentration  * 2.687e19 * (273.15/298) * 1.28e-21  * 1 *1600 * St;
% NPLS = -1 * concentration  *(273.15/298)* 1.28e-21  * 1 *1600 * St;

% absorbtion = light .* exp(NPLS)+ noise;
absorption1 = light .* exp(NPLS);
abs = (light - absorption1) ./ light;
figure(2);
plot(t,abs);
xlabel("һ������/t");
title("������")
% % 
figure(3);
plot(t,absorption1);
xlabel("ʱ��/t");
ylabel("͸���ǿ��");
title("͸���ǿ����ʱ���ϵ")
% ��һ��
% absorption = wdenoise(absorption1,9,'NoiseEstimate','LevelIndependent');
absorption = absorption1;
absorption_min = min(absorption);
absorption_max = max(absorption);
absorption_after = 1e2 * (absorption - absorption_min)/ (absorption_max-absorption_min); % ���չ�һ��
% figure(9)
% plot(absorption_after);
%%%%%%%%%%%%%%%%%%%%%%%%         Allan����              %%%%%%%%%%%%%%%%%%
% [avar,tau] = allanvar(absorption_after,'octave');
% figure(11);
% loglog(tau,avar)
% xlabel('\tau')
% ylabel('\sigma^2(\tau)')
% title('Allan Variance')
% grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3 ���ƽ������
%������������������Ŵ���

times = 2; 
phi = pi/4;
ref_sin = 1*sin(2*pi*times*f_sin*t+phi);
ref_cos = 1*sin(2*pi*times*f_sin*t+phi+pi/2);
ref_2f_sin = ref_sin .* absorption_after;
ref_2f_cos = ref_cos .* absorption_after;
% figure(8)

% subplot(211)
% title("���Ҳο��ź��������ź����")
% plot(t,ref_2f_sin,"r");
% subplot(212)
% title("���Ҳο��ź��������ź����")
% plot(t,ref_2f_cos);

% �˲���
% WP =6e-06; WS = 4e-4; % �ֶ����ð����ַ��˲�������
WP = f_saw*2*4/f_sample; WS = f_sin*2*0.8/f_sample;%WP = f_saw*1.2/Fs; WS = f_sin*1.75/Fs;
% % WP = f_saw*1/f_sample; WS = f_saw*10/f_sample;
disp("ͨ����ֹƵ�ʣ�"+WP+"�������ֹƵ�ʣ�"+WS);
[N,WN] = buttord(WP,WS,3,60);
[B,A]= butter(N,WN);%butter
filter_2f_sin0 = filter(B,A,ref_2f_sin);
filter_2f_sin1 = filter(B,A,filter_2f_sin0);
filter_2f_sin2 = filter(B,A,filter_2f_sin1);
filter_2f_cos0 = filter(B,A,ref_2f_cos);
filter_2f_cos1 = filter(B,A,filter_2f_cos0);
filter_2f_cos2 = filter(B,A,filter_2f_cos1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(6)
% subplot(211);
% plot(filter_2f_sin0);
% title("sin��һ���˲�")
% subplot(212)
% plot(filter_2f_sin1);
% title("sin�ڶ����˲�")

figure(7)
subplot(311);
plot(filter_2f_cos0);
title("cos��һ���˲�")
subplot(312)
plot(filter_2f_cos1);
title("cos�ڶ����˲�")
subplot(313)
plot(filter_2f_cos2);
title("cos�������˲�")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
answer_one = -1*((filter_2f_cos1) + (filter_2f_sin1)); % ֱ�ӽ��n��г��
% answer = sqrt(((filter_2f_sin) + (filter_2f_cos)).^2); %��ԭʼͼ��ת��y������
answer = sqrt((filter_2f_cos1).^2 + (filter_2f_sin1).^2); % �����г���ķ�ֵ
% maxvalue = abs(min(answer)); %ԭʼ���ε���Сֵ�ľ���ֵ��Ϊг����ֵ

maxvalue = max(answer_one); 
minvalue = min(answer);
mode_num = mode(noise);
SNR_number = 10 * log10((maxvalue - minvalue) / mode_num);
disp("����г����ֵ: " + maxvalue);
disp("��������: " + mode_num);
disp("�������ֵ(SNR): " +  SNR_number);
figure(4);
plot(t,answer_one);
% plot(answer(floor(0.2*length(answer)):floor(0.9*length(answer))));
% plot(t,answer_one);
xlabel("������");
ylabel("��ֵ/mV");
% legend("1","2","3","4")
hold on

% [a,b] = fit(x',y',"poly1");

% Ũ�ȱ仯д���ļ���
% fid = fopen("sim/concentrationData.txt","a+");
% % fprintf(fid," %f",concentration);
% fprintf(fid," %f",answer);
% fprintf(fid,"\n");
% fclose("all");
% ���Ʊ仯д���ļ�


% fclose("all");