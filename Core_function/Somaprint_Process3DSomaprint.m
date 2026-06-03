function [idcell_zoutput,data_idz,data_globalmapscore]=Somaprint_Process3DSomaprint(centroid1,centroid2_tform,score_weighted_3D,lambda,gmmfilter)

    %% ------- 3D Z-stack processing -----
    data_globalmapscore=zeros([length(centroid1),length(score_weighted_3D)]);
    for jjjj=1:length(score_weighted_3D);
        if length(score_weighted_3D{jjjj})>=3;
            [id_output1,id_output2,score_temp,output_option]=Somaprint_ComputeMatchStatistics(score_weighted_3D{jjjj}{length(score_weighted_3D{jjjj})},centroid1,centroid2_tform{jjjj},2,.05,lambda,gmmfilter);
            if length(id_output2)>0;
                data_globalmapscore(id_output1,jjjj)=score_temp(1:length(id_output1),3);
            end
        else; 
            data_globalmapscore(:,jjjj)=0;
        end
    end
    
    % Plot sorted the scorses heatmaps
    [temp,order]=max(data_globalmapscore,[],2);[~,idx]=sort(order);
    figure(1);clf;imagesc(data_globalmapscore(idx,:));colormap(hot(256));
    set(gca,'Visible','off');colorbar;set(gca,'FontSize',25,'LineWidth',2)


    %% ---- Plot Heat map and global map ----
    
    idcell_zoutput=find(max(data_globalmapscore,[],2)>0);data_idz=[];
    for i=1:length(idcell_zoutput);
        data_idz(i,:)=find(data_globalmapscore(idcell_zoutput(i),:)==max(data_globalmapscore(idcell_zoutput(i),:)));
    end
    
    % ---- GLobal map ----
    fullHot=parula(1+round((max(data_idz)-min(data_idz))*1.2));
    plot_color= fullHot(1:(max(data_idz)-min(data_idz)+1),:);
    
    score=max(data_globalmapscore,[],2);
    figure(7);clf;
    fprintf(['Total number of cell:', num2str(length(idcell_zoutput)),'\n'])
    for i=1:length(idcell_zoutput);
        plot(centroid1(idcell_zoutput(i),2),centroid1(idcell_zoutput(i),1),'.','Color',plot_color(data_idz(i)-min(data_idz)+1,:),'MarkerSize',20);hold on; % Need to reserse the X and Y!
    end;
    colorbar;colormap(plot_color);
    set(gca,'LineWidth',3,'FontSize',25,'box','on','XTick',[],'YTick',[]);set ( gca, 'ydir', 'reverse');set(gca,'Visible','off')
    plot_text=sprintf('Matched cells: %d, Z plane starting from z = %d to z = %d',length(idcell_zoutput), min(data_idz),max(data_idz));
    annotation('textbox', [0.03, 0.01, 0.8, 0.05], 'String', plot_text,'FontSize', 12.5, 'HorizontalAlignment', 'center', 'EdgeColor', 'none');


end