function d=dprime(A, B)

d=(mean(A)-mean(B))/sqrt((std(A)^2+std(B)^2)/2);
d=abs(d);

end
