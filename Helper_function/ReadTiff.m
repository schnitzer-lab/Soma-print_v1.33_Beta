function image=ReadTiff(x,n_ch);

if exist('n_ch')==0;
    
    info=imfinfo(x);
    n_ch=length(info);
end

    
for i=1:length(info)/n_ch;

    for j=1:n_ch;
        image{i}(:,:,j)=imread(x,(i-1)*n_ch+j);
    end

end


    % for i=1:length(info)/n_ch;
    % 
    %     for j=1:n_ch;
    %         image{j}(:,:,i)=imread(x,(i-1)*n_ch+j);
    %     end
    % 
    % end

end