function PlotMatrix(x,plot_option,plot_color);



% plot_option 1: 1 + 1
% plot_option 2: 3 + 3, 6 contexts
% plot_option 2: 3 + 3, input color
% plot_option 4: 3 colors (3 states)
% plot_option 5: A,B,C,G
% plot_option 6: two-way plotting, grey and purple
% plot_option 7: two-way, 6 contexts
% plot_option 8: two-way, decoder
% plot_option 9: two-way, light and dark grey, taken from PlotBarMeanSem
if nargin<2;
    plot_option=0;
end;
% Just to plot a bar graph, normally used for decoder evaluation
    if  length(size(x))>2;
    x=squeeze(x);end
    [m,n]=size(x);
    X_mean=mean(x,1);
    X_sem=std(x,1)/sqrt(m);if m==1;X_sem=zeros([1,n]);end
    
    if plot_option==0;plot_color=[0.85 0.85 0.85];%plot_color=[0.2 0.7 0.2];
        b=bar(X_mean,'FaceColor',plot_color,'LineWidth',1.5);hold on;  
        errorbar(X_mean,X_sem,'.k','CapSize',5,'LineWidth',2);
    end;
    
    
    if plot_option==1;  
        b=bar(X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        %color_set=[0.85 0.85 0.85;0.25 0.25 0.25];
        %color_set=[1 0.85 0.85;0.7 0 0];
        b.FaceColor = 'flat';
        for i=1:n;       
                b.CData(i,:) =plot_color(i,:);
                plot(i+(rand([size(x,1),1])-0.5)/3,x(:,i),'.','Color',[.4 .4 .4]);
        end;
        
        errorbar(X_mean,X_sem,'.k','CapSize',15,'LineWidth',2);
        set(gca,'LineWidth',2,'box','off');
    end
    
    if plot_option==2;  
        bar_x=[0.5,1,1.5,2.3,2.8,3.3];
        b=bar(bar_x(1:length(X_mean)),X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        color_set=[0.75 0.75 1;1 0.75 0.75;0.5 0.5 0.5;0 0 1;1 0 0;0.25 0.25 0.25];
        %color_set=[0.85 0.85 0.85;0.85 0.85 0.85;0.85 0.85 0.85;0.25 0.25 0.25;0.25 0.25 0.25;0.25 0.25 0.25];
        
        if nargin<3
            plot_color=[.7 .7 .7;.2 .2 .2];
        end
        %color_set=[1 0.85 0.85;1 0.85 0.85;1 0.85 0.85;0.7 0 0;0.7 0 0;0.7 0 0];
            b.FaceColor = 'flat';
        for i=1:n;              
                b.CData(i,:) = plot_color(i,:);
        end;
        errorbar(bar_x(1:length(X_mean)),X_mean,X_sem,'.k','CapSize',20,'LineWidth',1.5);
        set(gca,'box','off','FontSize',15,'LineWidth',1.5);
    end
    
    if plot_option==3;
        bar_x=[0.5,1,1.5,2.3,2.8,3.3];
        b=bar(bar_x,X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        %color_set=plot_color;      
        if nargin<3
            plot_color=[.7 .7 .7;.2 .2 .2];
        end
        %color_set=[1 0.85 0.85;1 0.85 0.85;1 0.85 0.85;0.7 0 0;0.7 0 0;0.7 0 0];
            b.FaceColor = 'flat';
        for i=1:n;              
                b.CData(i,:) = plot_color;
        end;
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',5,'LineWidth',1.5);
        set(gca,'box','off','FontSize',15,'LineWidth',1.5);
    end
    if plot_option==4;  
        color_set=[0.1 0.1 0.1;
                   0.7 0.7 0.7;
                   0 0.6 0];
        b=bar(X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        b=bar(X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2);hold on;
        b.FaceColor = 'flat';
        for i=1:n;       
                b.CData(i,:) =color_set(i,:);
        end;
        errorbar(X_mean,X_sem,'.k','CapSize',15,'LineWidth',2);
        set(gca,'box','off','FontSize',30,'LineWidth',2);
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
    color_set= [0.9 0.9 0.9;...
                0.4 0.4 0.4;...
                    1 0.6 0.6;...
                    0.8 0 0;...
                    0.6 0.6 1; 0 0 0.8 ];
                
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
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',10,'LineWidth',2);
        set(gca,'box','off','LineWidth',2);    %ylabel('Norm. dF/F');
    end   
    
    if plot_option==7;
        color_set=[0.75 0.75 1;0 0 0.85;1 0.75 0.75;0.85 0 0;0.5 0.5 0.5;0.25 0.25 0.25];
        color_set=[0.85 0.85 0.85;0.25 0.25 0.25;1 0.85 0.85;0.85 0 0;1 1 0.85;0.9 0.9 0];
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
        %color_set=[0.75 0.75 0.75;1 0.65 0.65;0.45 0.45 0.45;1 0.45 0.45];
        %color_set=[0.75 0.75 0.75;0.75 0.75 0.75;0.45 0.45 0.45;0.45 0.45 0.45];
        for i=1:n
           if mod(i,2)==1;bar_x(i)=2*(i-1)+0.2;
           else;bar_x(i)=2*(i-1)-0.2;
           end
        end
        bar_x=bar_x/2;
        b=bar(bar_x,X_mean,'FaceColor',[0.5 0.5 0.5],'LineWidth',2.5);hold on;
        b.FaceColor = 'flat';
         for i=1:n;
            if mod (i,2)==1;
                    b.CData(i,:) =[.9 .9 .9];
            else
                    b.CData(i,:) =[.3 .3 .3];
            end
         end
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',15,'LineWidth',2);
        xl=get(gca,'Xlim');
        line(xl,[50 50],'LineStyle','--','Color','k','LineWidth',2)
        %ylabel('Decoder Accuracy');set(gca,'box','off','LineWidth',2.5);
     end   
    
    
    if plot_option==9;
        bar_width=1;
        bar_x=[0.6,1.4,2.6,3.4,4.6,5.4,6.6,7.4,8.6,9.4];
        bar_x=bar_x(1:n);
        b=bar(bar_x,X_mean,bar_width,'w','LineWidth',1);hold on;
        b.FaceColor = 'flat';
        for i=1:n;
            if mod (i,2)==1;
                    b.CData(i,:) =[.9 .9 .9];
            else
                    b.CData(i,:) =[.8 0 0];
            end
         end
        errorbar(bar_x,X_mean,X_sem,'.k','CapSize',5,'LineWidth',1);
        %ylabel('Decoding accuracy(%)');%yticks([0 25 50 75 100])%;ylim([0 100]);
        xticks([]);
        xL = get(gca,'XLim');set(gca,'box','off'); set(gca,'FontSize',15);set(gca,'LineWidth',1);
        %line(xL,[50 50],'Color','k','LineStyle','--');
        hold off; 
    end
     
     
    xticks([]);
    xL = get(gca,'XLim');set(gca,'FontSize',18);
    hold off;
end