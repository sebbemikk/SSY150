% Task 2: Nonstationary Speech Signals: Modeling, Analysis and Synthesis
%
clc
close all
%%   %======Step 2.1======
p=12;
y=input('do you want to record a new audio signal(1 for yes, and 0 for no):')
% ==========record sound===========
Fs=12000;
RecordTime=15;
if y==1
    recObj = audiorecorder(Fs,16,1);
    disp('Start speaking.')
    pause(0.5)
    recordblocking(recObj, RecordTime);
    disp('End of Recording.');
    myRecording = getaudiodata(recObj);% get recorded audio signal
    
    % ===========save recorded sound=====
    filename='MySentence.wav';
    audiowrite(filename,myRecording,12000)
    
    InData=audioread('MySentence.wav');
      %  soundsc(InData,Fs)
else
    % ==========read saved file and replay===
    InData=audioread('MySentence.wav');
%         soundsc(InData,Fs)
end

plot(InData)% Mysentence

%% %============Step 2.2================
BlockTime=0.02;
BlockLength=Fs*BlockTime;
TotalBlocks=RecordTime/BlockTime

LPC_A=zeros(TotalBlocks,p+1);

for i=1:TotalBlocks
    LPC_A(i,:)=lpc(InData((i-1)*BlockLength+1:i*BlockLength),p);
end

%% %============Step 2.3================
% Block-based estimation of residual sequence eˆ(n):
e_hat=zeros(size(InData));
e_hat(1:BlockLength)=filter(LPC_A(1,:),1,InData(1:BlockLength));
for i=2:TotalBlocks
    temp=filter(LPC_A(i,:),1,InData((i-1)*BlockLength-p+1:i*BlockLength));
    e_hat((i-1)*BlockLength+1:i*BlockLength)=temp(p+1:end);
    
end

figure
plot(InData)
hold on
plot(e_hat)
xlabel('t')
ylabel('s(n), e_hat(n)')
title('speech signal and residual signal')
legend('original speech signal', 'residual signal')
hold off

figure
subplot(2,1,1)
plot(InData(100*BlockLength+1:101*BlockLength))
hold on
plot(e_hat(100*BlockLength+1:101*BlockLength))
xlabel('t')
ylabel('s(n), e_hat(n)')
title('speech signal and residual signal')
legend('original speech signal', 'residual signal')

subplot(2,1,2)
plot(InData(200*BlockLength+1:201*BlockLength))
hold on
plot(e_hat(200*BlockLength+1:201*BlockLength))
xlabel('t')
ylabel('s(n), e_hat(n)')
title('speech signal and residual signal')
legend('original speech signal', 'residual signal')


%% %============Step 2.4================
% Block-based speech re-synthesis:
s_hat=zeros(size(e_hat));
s_hat(1:BlockLength)=filter(1,LPC_A(1,:),e_hat(1:BlockLength));

for i=2:TotalBlocks
    for j=1:BlockLength
        temp=flipud(s_hat((i-1)*BlockLength+j-p:(i-1)*BlockLength+j-1));% to get [s(n-1), s(n-2),...s(n-p)]
        s_hat((i-1)*BlockLength+j)=e_hat((i-1)*BlockLength+j)-LPC_A(i,2:end)*temp;
    end   
end

figure
plot(s_hat)
% soundsc(s_hat,Fs)





%    Task 3: Re-synthesize Speech by Using K Most Significant
%    Residuals/Blockas the Excitations

%% %============Step 3.1================

K=200;
mod_ehat=zeros(size(e_hat));
for i=1:TotalBlocks
    [desc_vector, location]=sort(abs(e_hat((i-1)*BlockLength+1:i*BlockLength)),'descend'); %sort abs(ehat) with descending
    K_location=location(1:K)+(i-1)*BlockLength;% take the location of K significant value
    mod_ehat(K_location)=e_hat(K_location);
end


%% %============Step 3.2================

new_shat=zeros(size(mod_ehat));
new_shat(1:BlockLength)=filter(1,LPC_A(1,:),mod_ehat(1:BlockLength));
for i=2:TotalBlocks
    for j=1:BlockLength
        temp=flipud(new_shat((i-1)*BlockLength+j-p:(i-1)*BlockLength+j-1));% to get [s(n-1), s(n-2),...s(n-p)]
        new_shat((i-1)*BlockLength+j)=mod_ehat((i-1)*BlockLength+j)-LPC_A(i,2:end)*temp;
    end   
end

figure
subplot(3,1,1)
plot(InData)
axis([0,180000 ,-0.1,0.1])
xlabel('t')
ylabel('s(n)')
title('speech signal')


subplot(3,1,2)
plot(new_shat)
axis([0,180000 ,-0.1,0.1])
xlabel('t')
ylabel('mod_shat(n)')
title('re-synthesized signal')


subplot(3,1,3)
plot(mod_ehat)
axis([0,180000 ,-0.1,0.1])
xlabel('t')
ylabel('mod_shat(n)')
title('modified residual signal')



soundsc(new_shat,Fs)



%% %========================================================
% ========================Task 4===========================
% Using Cepstrum to Estimate Pitch Periods in VoicedSpeech


s=InData;

HamWindow=hamming(BlockLength);% creat Hamming window
figure 
hold on
for i=5:5%TotalBlocks
    
    x_i=s((i-1)*BlockLength+1:i*BlockLength);% take samples
    x_i=x_i.*HamWindow;% Multiplied with Hamming window

    padding_factor=100;
    x_i=[x_i;zeros(padding_factor*length(x_i),1)];% zero padding
    
    
%     C=abs(ifft(log10(abs(fft(x_i)))));
    C=abs(ifft(log(abs(fft(x_i)))));
   
    
    
    c2=C+i*1;
    plot(c2)
end




%%%========================================================
% ========================Task 5===========================
% Objective Measures for Synthetic Speech Quality

new_A=zeros(size(LPC_A));
for i=1:TotalBlocks
    new_A(i,:)=lpc(new_shat((i-1)*BlockLength+1:i*BlockLength),p) ;       
end

% l=0:p;
% 
% angle=@(w) exp(-j*l*w)
% 
% 
% for i=1:TotalBlocks
%     
% 
%     A=@(w) 1/abs(LPC_A(i,:)*(angle(w).'));
% end




B=Fs/2;
w_max=2*pi*B/Fs;
w=0:0.01:w_max;
d=zeros(1,TotalBlocks);
N_samples=100;
for i=1:TotalBlocks
    A_s=fft(LPC_A(i,:),N_samples);
    A_s=1./abs(A_s);%spectrum of original signal
     
    A_shat=fft(new_A(i,:),N_samples);
    A_shat=1./abs(A_shat);%spectrum of re_synthesized signal
    
    d(i)=mean(10*log10(abs(A_s-A_shat).^2));
end

temp1=fft(LPC_A(100,:),N_samples);
temp1=1./abs(temp1);
temp2=fft(new_A(100,:),N_samples);
temp2=1./abs(temp2);

P_s=abs(temp1).^2;
P_shat=abs(temp2).^2;
figure

plot(linspace(0,w_max,N_samples),P_s)
xlabel('$\omega$','interpreter','latex')
ylabel('$P(w)$','interpreter','latex')
hold on
plot(linspace(0,w_max,N_samples),P_shat)
legend({'$P_s(\omega_m)$','$P_{\bar{s}}(\omega_m)$'},'interpreter','latex')

figure
plot(d)
xlabel('Block  $i$','interpreter','latex')
ylabel('$d(i)$','interpreter','latex')


