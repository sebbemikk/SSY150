function output=zigzag(input)
% clc
% input=randi([-1,7],5,5)


[~, N]=size(input);
Vect=zeros(1,N*N);
Vect(1)=input(1,1);
v=1;
for k=1:2*N-1
    
    if k<=N
        if mod(k,2)==0% k is even
            j=k;
            for i=1:k
                Vect(v)=input(i,j);
                v=v+1;
                j=j-1;
            end
        else % k odd
            i=k;
            for j=1:k
                Vect(v)=input(i,j);
                v=v+1;
                i=i-1;
            end
        end
    else
        if mod(k,2)==0 %k even 
            p=mod(k,N);
            j=N;
            for i=p+1:N
                Vect(v)=input(i,j);
                v=v+1;
                j=j-1;
            end
        else % k odd
            p=mod(k,N);
            i=N;
            for j=p+1:N
                Vect(v)=input(i,j);
                v=v+1;
                i=i-1;
            end
        end
    end
end
output=Vect;