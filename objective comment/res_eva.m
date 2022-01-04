function [SNRI,SNRO,segSNRI,segSNRO,LSDI,LSDO,PESQ_I,PESQ_O,STOI_I,STOI_O]=res_eva(spe,noisy,eha,fs,frame,fstep)
if nargin==4
    frame=144;
    fstep=72;
else 
    if nargin==5
        fstep=72;
    end
end

% res_eva result evaluation, including SNR, SSNR, LSD(log-spectral
% distortion), PESQ, STOI
%
%Input: spe: clean signal; noisy: noisy signal; eha: processed signal
%      frame: length of frame, fstep: length of step(default: 144 72)
%Output:  SNRI£¬SNRO        SNR of the input and output signal compared to
%the noisy signal
%         segSNRI£¬segSNRI  SSNR of the input and output signal compared to
%the noisy signal
%         LSDI£¬LSDO        LSD of the input and output signal compared to
%the noisy signal
%         PESQ_I PESQ_O     PESQ of the input and output signal compared to
%the noisy signal
%
%               Copyright (c) 2010. Infocarrier.
%               All rights reserved. 
%% Align the three audio signals
le=length(eha);
spe=spe(1:le);
noisy=noisy(1:le);
noi=noisy-spe;
delta=eha-spe;
%% Caluate SNRI and SNRO
SNR1=mean(spe.^2)/mean(noi.^2);
SNRI=10*log10(SNR1);

SNR1=mean(spe.^2)/mean(delta.^2);
SNRO=10*log10(SNR1);

%% Calculate segSNRI and SNRO
N=frame;
M=fstep;
ss=fix(le/fstep); 
ts=ss-3;
SNRt=zeros(1,ss);
for t=1:ts
    SNRt(t)=10*log10(sum(spe((t-1)*M+1:(t-1)*M+N).^2)/sum(noi((t-1)*M+1:(t-1)*M+N).^2));
end
SNRtp=min(max(SNRt,-10),35);
segSNRI=sum(SNRtp)/ts;

for t=1:ts
    SNRt(t)=10*log10(sum(spe((t-1)*M+1:(t-1)*M+N).^2)/...
sum((spe((t-1)*M+1:(t-1)*M+N)-eha((t-1)*M+1:(t-1)*M+N)).^2));% ¹«Ê½44.95,96
end
SNRtp=min(max(SNRt,-10),35);
segSNRO=sum(SNRtp)/ts;

%% Calculate LSDI andLSDO

%%% clear signal
speX=spectrogram(spe,frame,frame-fstep,frame);
speX=20*log10(abs(speX));%speX(K,T),T is the time
theta=max(max(speX))-50;
LspeX=max(speX,theta);
%%% noisy signal
noisY=spectrogram(noisy,frame,frame-fstep,frame);
noisY=20*log10(abs(noisY));
thetaY=max(max(noisY))-50;
LnoisY=max(noisY,thetaY);
%%% processed signal
speX1=spectrogram(eha,frame,frame-fstep,frame);
speX1=20*log10(abs(speX1));
theta1=max(max(speX1))-50;
LspeX1=max(speX1,theta1);
%%% Input LSD
LnoisY(1,:)=0;
LspeX(1,:)=0;
LspeX1(1,:)=0;%Set the first number of the Fourier coefficient as 0
LSDI=(1/ts)*sum((2/N*sum((LnoisY-LspeX).^2)).^(1/2));
%%% Output LSD
LSDO=(1/ts)*sum((2/N*sum((LspeX-LspeX1).^2)).^(1/2));

%% Calculate PESQ and STOI
addpath('PESQ');
fname_noisy='temp_noisy.wav';
fname_spe='temp_spe.wav';
fname_eha='temp_eha.wav';
audiowrite(fname_noisy,noisy,fs);
audiowrite(fname_spe,spe,fs);
audiowrite(fname_eha,eha,fs);
PESQ_I=pesq(fname_spe,fname_noisy); 
PESQ_O=pesq(fname_spe,fname_eha); 
STOI_I=stoi(fname_spe,fname_noisy);
STOI_O=stoi(fname_spe,fname_eha);
delete(fname_noisy);
delete(fname_spe);
delete(fname_eha);


