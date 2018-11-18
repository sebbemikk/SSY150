clc
clear all
t=[0:0.1:10*pi];
signal=sin(t);
figure
plot(t,signal)
hold on

partition=linspace(-1,1,257);
index=quantiz(signal, partition(2:end-1));
codebook=linspace(-1,1,256);
quan_signal=codebook(index+1);%step1.3
% partition=linspace(-1,1,257);% step 1.2 , 1.3 done together
% codebook=linspace(-1,1,256);
% [index,quan_signal]=quantiz(signal,partition(2:end-1),codebook);
plot(t,quan_signal,'*')% step 1.4


