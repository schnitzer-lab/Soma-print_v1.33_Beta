function PlotCurve(x,x_plot,color,plot_option)

    if exist('plot_option')==0;plot_option=0;end

    plot_ms=20;
    x=squeeze(x);
    [m,n]=size(x);
    if nargin<2    
        x_plot=1:n;
    end
    
     if nargin<3    
        color='k';
    end
    
    %plot(x_plot,mean(x,1)-std(x)/sqrt(m),'--','Color',color,'LineWidth',1.5)
    %plot(x_plot,mean(x,1)+std(x)/sqrt(m),'--','Color',color,'LineWidth',1.5)
    x2=[x_plot,fliplr(x_plot)];
    inbetween=[mean(x,1)-std(x)/sqrt(m),fliplr(mean(x,1)+std(x)/sqrt(m))];
    fill(x2,inbetween,color,'FaceAlpha',0.3,'LineStyle','none');hold on

    plot(x_plot,mean(x,1),'k','LineWidth',2,'Color',color);
    if plot_option==1;
        for i=1:n;
            plot(x_plot(i)+(rand([m,1])-0.5)/5,x(:,i),'.k','MarkerSize',plot_ms)
        end
    end

    yl=get(gca,'ylim');
    %line([0 0],yl*1.5,'Color','Black','LineStyle','--','LineWidth',2);
    hold off;
    
     if plot_option==1;
         set(gca,'FontSize',15,'LineWidth',2,'box','off');
     end
end