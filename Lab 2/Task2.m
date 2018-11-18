clc
close all
clear all

% Task 1
% Task 1.1

vid = VideoReader('Trees1.avi');
width = vid.width - 1;
height = vid.height - 1;

video = struct('frames',zeros(height,width));

nrFrames = round(vid.Duration * vid.FrameRate);
for i = 1:nrFrames
video(i).frames = readFrame(vid);
end

f1 = mat2gray(video(1).frames(1:end-1,1:end-1,1));
%figure
%imshow(f1)
f1 = compressOwn(f1,width,height);



f2 = mat2gray(video(2).frames(1:end-1,1:end-1,1));
%figure
%imshow(f2)

th = 50/255;

fdiff = f1-f2;
%figure
%imshow(fdiff)
rem = abs(fdiff > th);

fdiff = fdiff .* rem;

comp = zeros(16);

win = 16;
for i = 1:width/win
    for j = 1:height/win
        motBlock((j-1)*win+1:j*win,(i-1)*win+1:i*win) = ~isequal(comp, fdiff((j-1)*win+1:j*win,(i-1)*win+1:i*win));
        
    end
end
%figure
%imshow(motBlock)

% 
f2_mot = zeros(height,width)

Imove = zeros(height/16,width/16,2);
win = 16;
for i = 1:width/win
    for j = 1:height/win
        if  ~isequal(motBlock((j-1)*win+1:j*win,(i-1)*win+1:i*win),comp)
            Imove(j,i,:) = maeOwn(f2((j-1)*win+1:j*win,(i-1)*win+1:i*win),(j-1)*16+1,(i-1)*16+1,width,height,f1);
        end
        
    end
end

subplot(2,2,1)
imshow(f2)
title('New frame')

subplot(2,2,2)
imshow(f1)
title('Old frame')

subplot(2,2,3)
imshow(fdiff)
title('Difference')

subplot(2,2,4)
imshow(motBlock)
title('Motion blocks')

%%


framenewtest = zeros(height,width);
framenewtest1 = f1;

for i = 1:width/win
    for j = 1:height/win
        if ~isequal(motBlock((j-1)*win+1:j*win,(i-1)*win+1:i*win),comp)
            dy = Imove(j,i,2);
            dx = Imove(j,i,1);

            framenewtest((j-1)*win+1:j*win,(i-1)*win+1 :i*win) = f1((j-1)*win+1 + dy :j*win + dy ,(i-1)*win+1 + dx :i*win + dx);
            framenewtest1((j-1)*win+1:j*win,(i-1)*win+1 :i*win) = f1((j-1)*win+1 + dy :j*win + dy ,(i-1)*win+1 + dx :i*win + dx);
            %imshow(framenewtest)
        end
    end
end

disp('ok')


%%
PSNR = psnr(framenewtest1,f2)
SSIM = ssim(framenewtest1,f2)


subplot(2,2,1)
imshow(f2)
title('New frame')

subplot(2,2,2)
imshow(framenewtest)
title('Inter frame compensation')

subplot(2,2,3)
imshow(framenewtest1)
title('Inter and Intra compensation')

error = abs(f2-framenewtest1);
error_mag = 30.*error;

subplot(2,2,4)
imshow(error_mag)
title('Magnified error')



