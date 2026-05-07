function y=normimage(x,method);

if nargin<2;
    method=2;
end

if method==0;
    y=x;
end

x=double(x);
% Just mini-max normalization
if method==1;
    x_min=min(min(x));
    x_max=max(max(x));
    y=(x-x_min)./x_max;
end

% Auto adjustment
if method==2;
    min_cut=0.05;
    max_cut=0.95;

    temp=sort(reshape(x,[],1),'ascend');
    l=length(temp);
    x_min=temp(round(l*min_cut));
    x_max=temp(round(l*max_cut));
    x(x>x_max)=x_max;
    x(x<x_min)=x_min;
    y=(x-x_min)./(x_max-x_min);
end

end