function y=imageaddpad(x,l);

    [m,n,n_cell]=size(x);
    y=zeros(m+2*l,n+2*l,n_cell);
    y(l+1:l+m,l+1:l+n,:)=x;
end