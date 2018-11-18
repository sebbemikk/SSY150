% Task 1: Stationary (Single Tone) Speech Signals: Modeling, Analysis and Synthesis
% 

clc 
close all

%%   %======Step 1.1======
y=input('do you want to record a new audio signal(1 for yes, and 0 for no):')

% ==========record sound===========
Fs=12000;
if y==1
recObj = audiorecorder(Fs,16,1);
disp('Start speaking.')
recordblocking(recObj, 3);
disp('End of Recording.');
% play(recObj);% play the audio signal
myRecording = getaudiodata(recObj);% get recorded audio signal

% ===========save recorded sound=====
filename='MyVowel.wav'
audiowrite(filename,myRecording,12000) 
end

% ==========read saved file and replay===
InData=audioread('MyVowel.wav');

%  soundsc(InData,Fs)
figure
plot(InData)% plot the recorded sound wave form 

%% ================Step 1.2=================
p=12;
T_sample=0.3;% speech block of 300ms
start=randi([1,30000],1);% take a random start of the taken samples
RandomBlock=InData(start:start+Fs*T_sample-1);


[A,Variance]=lpc(RandomBlock,p);


%% ================Step 1.3=================
x=InData;
e_hat = filter(A,1,x);  % compute residuals

                  
figure
plot(x,'--','LineWidth',1.5)% plot original audio signal
hold on
plot(e_hat)% plot residuals 

%% ================Step 1.4=================
s_hat=filter(1,A,e_hat);%re-synthesized speech signal sˆ(n)

plot(s_hat,'-','LineWidth',.5)% plot re-synthesized signal
axis([6000,6500,-0.2,0.2])
soundsc(s_hat,Fs)



