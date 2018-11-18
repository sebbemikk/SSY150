clc
clear all

photo=imread('lena.bmp');
frame=mat2gray(photo);
figure
imshow(frame)
[row,colum]=size(frame);
block_size=16;
ratio=0.5;% compression ratio
packet_loss_rate=0.03;

%% ===========Block1=====================
DCT=zeros(size(frame));
N=16*16;% pixels in one block
N1=round(ratio*16^2);% discarded dct coeficiences
for i=1:row/16
    for j=1:colum/16
        block=frame((i-1)*16+1:i*16,(j-1)*16+1:j*16);
        BLOCK=dct2(block);        
        DCT((i-1)*16+1:i*16,(j-1)*16+1:j*16)=BLOCK;
    end
end
%====zigzag scanning==========
sequences=[];
for i=1:row/16
    for j=1:colum/16        
        block=DCT((i-1)*16+1:i*16,(j-1)*16+1:j*16);
        scanned_block=zigzag(block);
        seq=scanned_block(1:N-N1);% discard the last N1 DCT coeficient
        sequences=[sequences,seq];
    end
end

%% ============Block2==================
% quantization
left_boundary=min(sequences);
right_boundary=max(sequences);
partition=linspace(left_boundary,right_boundary,257);
index=quantiz(sequences, partition(2:end-1));

codebook=linspace(left_boundary,right_boundary,256);% create a codebook


%% ===========Block3==========
% =====packetizer=========
k=127;
num_row=ceil(length(index)/k);
packets=zeros(num_row,k);
for j=1:num_row
    if j*k<=length(index)
        packets(j,:)=index((j-1)*k+1:j*k);
    else
        packets(j,1:length(index)-(j-1)*k)=index((j-1)*k+1:end);
    end    
end
% packets is now an array, where each row represents one packet


%% ===========Block4==========
% =====RS encoder=========
m=8;
n=2^m-1;
msgwords=gf(packets,m);
codes=rsenc(msgwords, n, k);
[num_packets, size_packets]=size(codes);


%% ===========Block5==========
% =====Interleaving=========
forInt=reshape(codes.',1,[]);% matrix to sequence

[Nrows,Ncols]=size(codes);
Interleaved=matintrlv(forInt,Nrows,Ncols);

intrlv_codes=reshape(Interleaved,Ncols,Nrows);% sequence to matrix, each colum is a packet
intrlv_codes=intrlv_codes.'; %transpose, each row is a packet
% intrlv_codes = codes;


%% ===========Block7==========
method=input('please enter noise type, 0 for bit_error and 1 for packet_loss:');
switch(method)    
    case{0}
        % ===step5.1=======b
        max_error=floor((n-k)/2);
        %t=randi([0,max_error],1);
        t=60;
        % noise = (1 + randint(nw, n, 2^m -1)).* randerr(nw, n, t);
        noise =randi( 2^m -1,num_packets,n).* randerr(num_packets, n, t);
        codes_noisy = intrlv_codes + noise;
%         [de_codes,n_errs,corr_codes]=rsdec(codes_noisy, n, k);
           
    case{1}
        %=====step 5.2=======
        codes_noisy=intrlv_codes;
        e_packet=zeros(1, n);
        errorpacket=gf(e_packet,m);
        n_erropack=round(num_packets*packet_loss_rate);
        loss_packets=randi([1,num_packets],1,n_erropack);
        for i=loss_packets
            codes_noisy(i, :) = errorpacket;
        end
%         [de_codes,n_errs,corr_codes]=rsdec(codes_noisy, n, k);
end


% ===========Block8==========
% =====Deinterleaving=========
forDei=reshape(codes_noisy.',1,[]);
deinterleaved=matdeintrlv(forDei,Nrows,Ncols);
deintr_codes=reshape(deinterleaved,Ncols,Nrows);
deintr_codes=deintr_codes.';
% deintr_codes = codes_noisy;


% ===========Block9==========
% =====RS decoder=========
codes_noisy=deintr_codes;
dec_msg=rsdec(codes_noisy,n,k);% decoded packets
% isequal(dec_msg,msgwords)


% ===========Block10==========
%=========depacketizer========
packets=dec_msg;
depackets=reshape(packets.',1,[]);
depackets=depackets(1:length(index));


% ===========Block11==========
%=========quantization indices to quantized value========
quantized_value=codebook(depackets.x+1);


% ===========Block12==========
%====inverse zigzag scanning==========
r_frame=zeros(size(frame));
for i=1:row/16
    for j=1:colum/16
        no_block=16*(i-1)+j;
        seq=quantized_value((no_block-1)*(N-N1)+1:no_block*(N-N1));
        temp=[seq,zeros(1,N1)];
        
        r_block=inverse_zigzag(temp);
        r_frame((i-1)*16+1:i*16,(j-1)*16+1:j*16)=r_block;      
    end
end

inverse_DCT=zeros(size(frame));
for i=1:row/16
    for j=1:colum/16
        temp=r_frame((i-1)*16+1:i*16,(j-1)*16+1:j*16);
        inverse_DCT((i-1)*16+1:i*16,(j-1)*16+1:j*16)=idct2(temp);
       
    end
end

figure
subplot(1,2,1)
imshow(frame)
title("Original image from source")
subplot(1,2,2)
imshow(inverse_DCT)
title("Reconstructed image at reciever")

PSNR = psnr(inverse_DCT,frame)
SSIM = ssim(inverse_DCT,frame)

