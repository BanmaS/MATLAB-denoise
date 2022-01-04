%% - ------------------测试------------------------
function [SNRI,SNRO,segSNRI,segSNRO,LSDI,LSDO,PESQ_I,PESQ_O,STOI_I,STOI_O]=test_one(path,file,noi_snr)
%% 读取文件
[audio_test,fs_test] = audioread([path,file]);

%% 采样率转换
decimationFactor = 2;
src = dsp.SampleRateConverter("InputSampleRate",fs_test, ...
                              "OutputSampleRate",fs_test/decimationFactor, ...
                              "Bandwidth",7920);
fs_test=fs_test/decimationFactor;
L = floor(numel(audio_test)/decimationFactor);
audio_test = audio_test(1:decimationFactor*L);
audio_test = src(audio_test);
noisyAudioTest = Gnoisegen(audio_test,noi_snr);

%% 参数定义
frameLength=0.02; %s
frameOverlap=0.01; %s
windowLength=frameLength*fs_test;
windowOverlap=frameOverlap*fs_test;
N=windowLength;
m=0:N-1;
K=1;%正弦窗阶数
giveMFCCnums=2;
sineWindow=sin((pi * K * (m+1))/(N+1));

i=1;
number_MFCCs=12;
for k=1:number_MFCCs %计算出离散余弦变换的系数
    n=0:2*number_MFCCs-1;
    dctcoef(k,:)=cos((2*n+1)*k*pi/(2*2*number_MFCCs));
end
bank=melbankm(2*number_MFCCs,windowLength,fs_test,0,0.5,'t');
%归一化mel滤波器组系数
bank=full(bank);%稀疏矩阵转为正常矩阵的存储方式
bank=bank/max(bank(:));

i=1;
while windowLength+(i-1)*windowOverlap<size(noisyAudioTest,1)
    noisyFrameTest(i,:)=noisyAudioTest((i-1)*windowOverlap+1:(i-1)*windowOverlap+windowLength);
    noisyFrameTest(i,:)=noisyFrameTest(i,:).*sineWindow;
    s=noisyFrameTest(i,:);
    t=abs(fft(s)); %先fft后取模
    t=t.^2; %取平方
    c=dctcoef*log(bank*t(1:windowLength/2+1)'); %通过Mel滤波器、对数运算和DCT
    MFCC_noisy_test(i,1:number_MFCCs)=c'; %存储结果
    MFCC_noisy_test(i,number_MFCCs+1:number_MFCCs+giveMFCCnums)=getMFCCdet(c',giveMFCCnums);
    i=i+1;
end

%% 加载网络
load('DenoiseNet2_1217_1.mat');

%% 预测
pres=predict(net, MFCC_noisy_test);
g_b=pres;
w_b=get_wb();
% w_b=w_b(:,1:144);
%% -------------------------------------------------------------
r_k=ones(size(g_b,1),windowLength);
for i=1:size(g_b,1)
    temp_gb=g_b(i,:)';
    temp_gba=repmat(temp_gb,1,windowLength);
    gb_wb=temp_gba.*w_b;
    r_k(i,:)=sum(gb_wb);
end

%% ---------------------逆窗重建----------------------
recAudio=zeros(1,108000);
for numberFrame=1:size(noisyFrameTest,1)
    tempNoisyFrame=noisyFrameTest(numberFrame,:);
    tempNoisyFrame=tempNoisyFrame.*sineWindow;
    tempNoisyFrame_f=fft(tempNoisyFrame);
    recNoisyTest=ifft(tempNoisyFrame_f.*r_k(numberFrame,:));
%     recNoisyTest=ifft(tempNoisyFrame_f);
    if numberFrame==1
        recAudioTest(1:N)=recNoisyTest;
    else
        recAudioTest((numberFrame-1)*windowOverlap+1:(numberFrame-2)*windowOverlap+windowLength)...
            =recAudioTest((numberFrame-1)*windowOverlap+1:(numberFrame-2)*windowOverlap+windowLength)+recNoisyTest(1:N/2);
        recAudioTest((numberFrame-2)*windowOverlap+windowLength+1:(numberFrame-1)*windowOverlap+windowLength)=recNoisyTest(N/2+1:N);
    end
    % subplot(4,1,3)
    % plot(tempAudioFrame)
    % subplot(4,1,4)
    % plot(recNoisy)
end

%% 计算重建语音各项指标
% Hd = HPF_2;
% recAudios=filter(Hd,real(recAudioTest)+imag(recAudioTest));
% sound(filter(Hd,audio_test))
% recAudios=real(recAudioTest)+imag(recAudioTest);
recAudios=(real(recAudioTest))';
% recAudios=abs(recAudioTest);
% snr1=calcu_snr(audio_test(1:size(recAudios,1)),noisyAudioTest(1:size(recAudios,1)));
% snr=calcu_snr(audio_test(1:size(recAudios,1)),recAudios');
% sound(audio_test)
% sound(noisyAudioTest)
% sound(recAudios)
[SNRI,SNRO,segSNRI,segSNRO,LSDI,LSDO,PESQ_I,PESQ_O,STOI_I,STOI_O]=res_eva(audio_test,noisyAudioTest,recAudios,fs_test);


