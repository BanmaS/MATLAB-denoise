%% - ------------------Test a number of signals and get the average evalution value------------------------
% Just for our system (Frequency band method)
clear
close all
clc
addpath('D:\MATLAB\sap-voicebox\voicebox')% If you haven't install voicebox, you need to download it and alter the path to your voicebox's path
%% List files from 'test/'
% Please put the clear signals you want to test into 'test/' before running this
% procedure
namelist = dir('test/*.wav');
len = length(namelist);
path = 'test/';
SNRI = zeros(1,len);
SNRO = zeros(1,len);
segSNRI = zeros(1,len);
segSNRO = zeros(1,len);
LSDI = zeros(1,len);
LSDO = zeros(1,len);
PESQ_I = zeros(1,len);
PESQ_O = zeros(1,len);
STOI_I = zeros(1,len);
STOI_O = zeros(1,len);
for i = 1:len
    file=namelist(i).name;
    [SNRI(i),SNRO(i),segSNRI(i),segSNRO(i),LSDI(i),LSDO(i),PESQ_I(i),PESQ_O(i),STOI_I(i),STOI_O(i)]=test_one(path,file,0);
end
iSNR=mean(SNRO-SNRI);
isegSNR=mean(segSNRO-segSNRI);
iLSD=mean(LSDI-LSDO);
iPESQ=mean(PESQ_O-PESQ_I);
iSTOI=mean(STOI_O-STOI_I);
figure; clf;
subplot(5,1,1),plot(SNRO,'r'),hold on,plot(SNRI,'b'),title(['iSNR=',num2str(iSNR)]);
subplot(5,1,2),plot(segSNRO,'r'),hold on,plot(segSNRI,'b'),title(['isegSNR=',num2str(isegSNR)]);
subplot(5,1,3),plot(LSDO,'r'),hold on,plot(LSDI,'b'),title(['iLSD=',num2str(iLSD)]);
subplot(5,1,4),plot(PESQ_O,'r'),hold on,plot(PESQ_I,'b'),title(['iPESQ=',num2str(iPESQ)]);
subplot(5,1,5),plot(STOI_O,'r'),hold on,plot(STOI_I,'b'),title(['iSTOI=',num2str(iSTOI)]);