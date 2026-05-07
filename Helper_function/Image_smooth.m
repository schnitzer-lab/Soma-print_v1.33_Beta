function y=Image_smooth(x)
    
    y=x;
    [m,n]=size(x);

    while length(find(isnan(y)==1))>0
        disp(length(find(isnan(y)==1)));
        id_nan=find(isnan(y)==1); 
        for i=1:length(id_nan);
            [row, col] = ind2sub(size(x), id_nan(i));
            id_row=intersect(row-1:row+1,1:m);
            id_col=intersect(col-1:col+1,1:n);
            y(row,col)=mean(mean(y(id_row,id_col),'omitnan'),'omitnan');
        end

    end
    %y=round(y);
    
end