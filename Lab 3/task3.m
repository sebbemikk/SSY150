clc
clear all
t=[0:0.1:10*pi];
signal=sin(t);
figure
plot(t,signal)
hold on

partition=linspace(-1,1,257);
index=quantiz(signal, partition(2:end-1));
% partition=linspace(-1,1,257);% step 1.2 , 1.3 done together
% codebook=linspace(-1,1,256);
% [index,quan_signal]=quantiz(signal,partition(2:end-1),codebook);
codebook=linspace(-1,1,256);
quan_signal=codebook(index+1);%step1.3
plot(t,quan_signal,'*')% step 1.4

%%
k=127
num_row=ceil(length(index)/k);
% =====packetizer=========
packets=zeros(num_row,k);
for j=1:num_row
    if j*k<=length(index)
        packets(j,:)=index((j-1)*k+1:j*k);
    else
        packets(j,1:length(index)-(j-1)*k)=index((j-1)*k+1:end);
    end    
end
 

%======RS encoder============
m=8;
n=2^m-1;
msgwords=gf(packets,m);


codes=rsenc(msgwords, n, k);

%======RS decoder============
dec_msg=rsdec(codes,n,k);% decoded packets

isequal(dec_msg,msgwords)
%=========depacketizer========
packets=dec_msg;
depackets=reshape(packets.',1,[]);
depackets=depackets(1:length(index));

r_signal=codebook(depackets.x+1);
figure
plot(t,signal)
hold on
plot(t,r_signal,'*')% step 1.4


% 
