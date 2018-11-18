clc
close all
clear all

% Task 1
% Task 1.1

vid = VideoReader('Trees1.avi')
width = vid.width;
height = vid.height;

video = struct('frames',zeros(height,width));

nrFrames = round(vid.Duration * vid.FrameRate);
for i = 1:nrFrames
video(i).frames = readFrame(vid);
end

f1 = mat2gray(video(1).frames(:,:,1));


% Task 1.2
F1 = dct2(f1);



% Task 1.3
r = 0.9;
forSort = reshape(F1,1,width*height);
temp = sort(abs(forSort),'ascend');
th = (temp(round(r*width*height)));

zer = abs(F1) >= th;

F1_comp = F1.*zer;
f1_comp = idct2(F1_comp); 

error = abs(f1-f1_comp)
error_mag = 30.*error


MSE = 1/(height*width)*sum(sum((f1-f1_comp).^2));
MAX = 255;
PSNR = 10*log10((MAX^2)/(MSE))

% meanf1 = mean(f1(:))
% varf1 = var(f1(:))
% 
% meanf1_comp = mean(f1_comp(:))
% varf1_comp = var(f1_comp(:))
% covf1 = cov(f1_comp,f1)
% SSIM = ((2*meanf1*meanf1_comp + c1)*(2*cov))/(1);

SSIM = ssim(f1_comp,f1)

subplot(2,2,1)
imshow(f1)
title('Original image')

subplot(2,2,2)
imshow(F1),colormap(gca,jet)
title('DCT domain of Image')

subplot(2,2,3)
imshow(f1_comp)
title('Compressed image')

subplot(2,2,4)
imshow(error_mag)
title('Magnified error')




%% Task 1.2

clc
clear all
close all

vid = VideoReader('Trees1.avi')
width = vid.width - 1;
height = vid.height - 1;

video = struct('frames',zeros(height,width));

nrFrames = round(vid.Duration * vid.FrameRate);
for i = 1:nrFrames
video(i).frames = readFrame(vid);
end

f1 = mat2gray(video(1).frames(1:height,1:width,1));

win = 8;
for i = 1:width/win
    for j = 1:height/win
        F1((j-1)*win+1:j*win,(i-1)*win+1:i*win) = dct2(f1((j-1)*win+1:j*win,(i-1)*win+1:i*win));
    end
end


r = 0.97;
forSort = reshape(F1,1,width*height);
temp = sort(abs(forSort),'ascend');
th = (temp(round(r*width*height)));

zer = abs(F1) > th;

F1_comp = F1.*zer;


for i = 1:width/win
    for j = 1:height/win
        f1_comp((j-1)*win+1:j*win,(i-1)*win+1:i*win) = idct2(F1_comp((j-1)*win+1:j*win,(i-1)*win+1:i*win));
        
    end
end

error = abs(f1-f1_comp);
error_mag = 30.*error;



PSNR = psnr(f1_comp,f1)
SSIM = ssim(f1_comp,f1) 


% subplot(2,2,1)
% imshow(f1)
% title('Original image')
% 
% subplot(2,2,2)
% imshow(F1),colormap(gca,jet)
% title('DCT domain of Image')
% 
% subplot(2,2,3)
% imshow(f1_comp)
% title('Compressed image')
% 
% subplot(2,2,4)
% imshow(error_mag)
% title('Magnified error')

figure 
imshow(f1_comp)


%% Task 1.3

clc
%clear all 
close all

vid = VideoReader('Trees1.avi')
width = vid.width;
height = vid.height;

video = struct('frames',zeros(height,width));

nrFrames = round(vid.Duration * vid.FrameRate);
for i = 1:nrFrames
video(i).frames = readFrame(vid);
end

f1 = mat2gray(video(1).frames(:,:,1));

imwrite(f1,'imagetest.bmp')



%wavemenu

f1_comp = mat2gray(imread('image_compressed.bmp'));


error = abs(f1 - f1_comp);
error_mag = 30.*error;



PSNR = psnr(f1_comp,f1)
SSIM = ssim(f1_comp,f1) 


subplot(2,2,1)
imshow(f1)
title('Original image')

subplot(2,2,2)
image(wavecoeff)
title('DCT domain of Image')

subplot(2,2,3)
imshow(f1_comp)
title('Compressed image')

subplot(2,2,4)
imshow(error_mag)
title('Magnified error')
