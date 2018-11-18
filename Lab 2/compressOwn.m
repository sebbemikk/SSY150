function f1_comp = compressOwn(f1,width,height)



win = 8;
for i = 1:width/win
    for j = 1:height/win
        F1((j-1)*win+1:j*win,(i-1)*win+1:i*win) = dct2(f1((j-1)*win+1:j*win,(i-1)*win+1:i*win));
    end
end


r = 0.90;
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

