function MV = maeOwn(blockIn,starty,startx,width,height,newImage) %always for 16x16
error = 100000;
for xdir = 1:width-16
    for ydir = 1:height-16
        errortemp = sum(sum(abs(blockIn - newImage(ydir:ydir+15,xdir:xdir+15))));
        if errortemp < error
            error = errortemp;
            MV = [xdir-startx,ydir-starty];
        
        end           
    end
end









