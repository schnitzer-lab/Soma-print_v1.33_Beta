function PlotCellMap(sp_input,coloroption,id_cell2,input_fontsize,linewidth);

[h,w,n_cell]=size(sp_input);

if exist('coloroption')==0;
    coloroption=[0 0.7 0];
else
     if isempty(coloroption)==1
        coloroption=[0 0.7 0];
    end;
end

if exist('id_cell2')==0;
    id_cell2=1:size(sp_input,3);
else;
    if isempty(id_cell2)==1
        id_cell2=1:size(sp_input,3);
    end;
end

if exist('input_fontsize')==0 %| isempty(fontsize)==1;
    input_fontsize=5;
else;
    if isempty(input_fontsize)==1
        input_fontsize=5;
    end;
end

if exist('linewidth')==0 %| isempty(linewidth)==1;;
    linewidth=1.5;
end

if nargin<5;
    id_cell=1:n_cell;
end


for i=1:length(id_cell2);   
    contour_thresh=0.2;
    im=sp_input(:,:,id_cell2(i));
    b=bwboundaries(im > contour_thresh); 
    if isempty(b)==0;
        b=b{1};
        plot((b(:,2)), (b(:,1)), 'LineWidth', linewidth,'Color',coloroption);hold on;

        idx=find((sp_input(:,:,id_cell2(i)))==max(max(sp_input(:,:,id_cell2(i)))));idx=idx(1);
        y_postion=mod(idx,h)+2*rand;
        x_postion=ceil(idx/h)+2*rand;
        if nargin>=4;
            text(x_postion,y_postion,num2str(id_cell2(i)),'FontSize',input_fontsize,'Color',coloroption);
        end
    end
end


end