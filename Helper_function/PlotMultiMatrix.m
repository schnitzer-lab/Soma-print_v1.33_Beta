function PlotMultiMatrix(varargin);

% 3: 3 states color
% 4: 3 states color, figure plot
% 9: grey, red, blue

    plot_option=0;
% Just to plot a bar graph, normally used for decoder evaluation 
    [~,n]=size(varargin);
    count=1;
    for i=1:n;
        temp=varargin{i};
        if length(temp)>1;
            temp=squeeze(temp);
            idx=find(sum(isnan(temp),2)>0);
            temp(idx,:)=[];
            x{count}=temp;
            count=count+1;
            n_temp=size(temp,2);
        else
            plot_option=temp;
        end
    end

% plot_option 2: 3 + 3
% plot_option 3: 3 colors
% plot_option 5: A,B,C,G
% plot_option 6: two-way plotting, grey and purple
% plot_option 7: two-way, 6 contexts
% plot_option 8: two-way, decoder
% plot_option 9: two-way, light and dark grey, taken from PlotBarMeanSem

% Just to plot a bar graph, normally used for decoder evaluation
    n_group=length(x);
    n=length(x)*n_temp;
    
    for i=1:length(x);
        x_temp=x{i};
        x_temp=squeeze(x_temp);    
        [m(i),~]=size(x_temp);
        X_mean(i:length(x):n)=mean(x_temp,1);
        X_sem(i:length(x):n)=std(x_temp,1)/sqrt(m(i));
        %if m(i)==1;X_sem(i,:)=zeros([1,n_temp(i)]);end
        
    end

    if plot_option==0;plot_color=[0.85 0.85 0.85];%plot_color=[0.2 0.7 0.2];
        b=bar(X_mean,'FaceColor',plot_color,'LineWidth',1.5);hold on;  
        errorbar(X_mean,X_sem,'.k','CapSize',5,'LineWidth',2);
    end;
    
    if plot_option==1;  
        b=bar(X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        color_set=[0.75 0.75 1;1 0.75 0.75;0.5 0.5 0.5;0 0 1;1 0 0;0.25 0.25 0.25];
        b.FaceColor = 'flat';
        for i=1:n;       
                b.CData(i,:) =color_set(i,:);
        end;
        errorbar(X_mean,X_sem,'.k','CapSize',15,'LineWidth',2);
        set(gca,'LineWidth',2,'box','off');
    end
    
    if plot_option==2;  
        bar_x=[0.5,1,1.5,2.3,2.8,3.3];
        b=bar(bar_x,X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        %color_set=[0.75 0.75 1;1 0.75 0.75;0.5 0.5 0.5;0 0 1;1 0 0;0.25 0.25 0.25];
        color_set=[0.85 0.85 0.85;0.85 0.85 0.85;0.85 0.85 0.85;0.25 0.25 0.25;0.25 0.25 0.25;0.25 0.25 0.25];
            b.FaceColor = 'flat';
        for i=1:n;       
                b.CData(i,:) =color_set(i,:);
        end;
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',15,'LineWidth',2);
        set(gca,'box','off','FontSize',20,'LineWidth',1.5);
    end
    
    if plot_option==3;
        color_set=[0.3 0.3 0.3;.5 0.5 0.5;0 .8 0];
        bar_width=1;
        bar_x=[];
        l_bar=2;
        for i=1:n;
            if mod (i,n_group)==1;
                bar_x(i)=i*l_bar+0.5;
            else if mod (i,n_group)==2;
                    bar_x(i)=i*l_bar;
                else
                    bar_x(i)=i*l_bar-0.5;
                end
            end
         end
        b=bar(bar_x,X_mean,bar_width,'w','LineWidth',1.5);hold on;
        b.FaceColor = 'flat';
        for i=1:n;
            if mod (i,n_group)==1;
                    b.CData(i,:) =[.1 .1 .1];
            else if mod (i,n_group)==2;
                    b.CData(i,:) =[0.7 0.7 0.7];%[.65 .2 .65];
                else mod (i,n_group)==0;
                    b.CData(i,:) =[0 0.7 0];
                end
                                   
            end
            %b.CData(i,:) =color_set(i,:);
        end
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',5,'LineWidth',1.5);
        %ylabel('Decoding accuracy(%)');%yticks([0 25 50 75 100])%;ylim([0 100]);
        xticks([]);
        xL = get(gca,'XLim');set(gca,'box','off'); set(gca,'FontSize',20,'LineWidth',1.5);
        %line(xL,[50 50],'Color','k','LineStyle','--');
        hold off; 
    end
    
    if plot_option==4;
        color_set=[0.3 0.3 0.3;.5 0.5 0.5;0 .8 0];
        bar_width=1;
        bar_x=[];
        l_bar=2;
        for i=1:n;
            if mod (i,n_group)==1;
                bar_x(i)=i*l_bar+0.5;
            else if mod (i,n_group)==2;
                    bar_x(i)=i*l_bar;
                else
                    bar_x(i)=i*l_bar-0.5;
                end
            end
         end
        b=bar(bar_x,X_mean,bar_width,'w','LineWidth',2);hold on;
        b.FaceColor = 'flat';
        for i=1:n;
            if mod (i,n_group)==1;
                    b.CData(i,:) =[.1 .1 .1];
            else if mod (i,n_group)==2;
                    b.CData(i,:) =[0.7 0.7 0.7];%[.65 .2 .65];
                else mod (i,n_group)==0;
                    b.CData(i,:) =[0 0.7 0];
                end
                                   
            end
            %b.CData(i,:) =color_set(i,:);
         end
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',10,'LineWidth',2);
        %ylabel('Decoding accuracy(%)');%yticks([0 25 50 75 100])%;ylim([0 100]);
        xticks([]);
        xL = get(gca,'XLim');set(gca,'box','off'); set(gca,'FontSize',20,'LineWidth',2);
        %line(xL,[50 50],'Color','k','LineStyle','--');
        hold off; 
    end
    
     if plot_option==5;
        b=bar(X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        color_set=[0 0 1;1 0 0;0.5 0.5 0.5;1 0.5 0;0 0.2 0.4];
        b.FaceColor = 'flat';
        for i=1:n;       b.CData(i,:) =color_set(i,:);end;
        errorbar(X_mean,X_sem,'.k','CapSize',15,'LineWidth',2);
        ylabel('Norm. dF/F');set(gca,'box','off','LineWidth',1.5);
    end
    
    if plot_option==6; % Two-way ANOVA plotting
    color_set= [0.8 0.8 0.8;...
                0.6 0.4 0.6;...
                    0.5 0.5 0.5;...
                    0.5 0.1 0.5];
        for i=1:n
           if mod(i,2)==1;bar_x(i)=2*(i-1)+0.2;
           else;bar_x(i)=2*(i-1)-0.2;
           end
        end
        bar_x=bar_x/2;
        b=bar(bar_x,X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        b.FaceColor = 'flat';
        for i=1:n;      
           b.CData(i,:) =color_set(i,:);
        end;
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',15,'LineWidth',2.5);
            %ylabel('Norm. dF/F');set(gca,'box','off');
    end   
    
    if plot_option==7;
        color_set=[0.75 0.75 1;0 0 0.85;1 0.75 0.75;0.85 0 0;0.5 0.5 0.5;0.25 0.25 0.25];
        for i=1:n
           if mod(i,2)==1;bar_x(i)=2*(i-1)+0.2;
           else;bar_x(i)=2*(i-1)-0.2;
           end
        end
        bar_x=bar_x/2;
        b=bar(bar_x,X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2.5);hold on;
        b.FaceColor = 'flat';
        for i=1:n;      
            b.CData(i,:) = color_set(i,:);
        end;
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',15,'LineWidth',2);
        ylabel('Distance');set(gca,'box','off','LineWidth',2.5);
    end   
    
     if plot_option==8;
        color_set=[0.75 0.75 0.75;1 0.85 0.85;0.25 0.25 0.25;1 0.25 0.25];
        for i=1:n
           if mod(i,2)==1;bar_x(i)=2*(i-1)+0.2;
           else;bar_x(i)=2*(i-1)-0.2;
           end
        end
        bar_x=bar_x/2;
        b=bar(bar_x,X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2.5);hold on;
        b.FaceColor = 'flat';
        for i=1:n;      
            b.CData(i,:) = color_set(i,:);
        end;
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',15,'LineWidth',2);
        xl=get(gca,'Xlim');
        line(xl,[50 50],'LineStyle','--','Color','k')
        ylabel('Decoder Accuracy');set(gca,'box','off','LineWidth',2.5);
     end   
    
    
    if plot_option==9;
        color_set=[0.75 0.75 0.75;.95 0.7 0.7;0.45 0.45 0.45;0.75 0 0];
        bar_width=1;
        bar_x=[];
        l_bar=2;
        for i=1:n;
            if mod (i,n_group)==1;
                bar_x(i)=i*l_bar+0.5;
            else if mod (i,n_group)==2;
                    bar_x(i)=i*l_bar;
                else
                    bar_x(i)=i*l_bar-0.5;
                end
            end
         end
        b=bar(bar_x,X_mean,bar_width,'w','LineWidth',1.5);hold on;
        b.FaceColor = 'flat';
        for i=1:n;
            if mod (i,n_group)==1;
                    b.CData(i,:) =[.9 .9 .9];
            else if mod (i,n_group)==2;
                    b.CData(i,:) =[0.8 0 0];%[.65 .2 .65];
                else mod (i,n_group)==0;
                    b.CData(i,:) =[0 0 .6];
                end
                                   
            end
            %b.CData(i,:) =color_set(i,:);
         end
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',5,'LineWidth',1.5);
        %ylabel('Decoding accuracy(%)');%yticks([0 25 50 75 100])%;ylim([0 100]);
        xticks([]);
        xL = get(gca,'XLim');set(gca,'box','off'); set(gca,'FontSize',20,'LineWidth',1.5);
        %line(xL,[50 50],'Color','k','LineStyle','--');
        hold off; 
    end
     
     
    xticks([]);
    xL = get(gca,'XLim');set(gca,'FontSize',18);
    hold off;
end