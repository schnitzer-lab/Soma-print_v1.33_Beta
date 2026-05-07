function PlotCenterImage(x,plot_color,id_cell,input_fontsize);
if exist('plot_color')==0;
    plot_color=[.7 .7 .7];
end

if exist('input_fontsize')==0;
    input_fontsize=0;
end

if exist('id_cell')==0;
    id_cell=1:size(x,1);
end

    for i=1:length(id_cell);
        plot(x(id_cell(i),2),x(id_cell(i),1),'o','Color',plot_color); % X/Y inverted
        hold on;
        if input_fontsize>0;
            text(x(id_cell(i),2),x(id_cell(i),1),num2str(id_cell(i)),'FontSize',input_fontsize,'Color',plot_color);
        end

    end
end