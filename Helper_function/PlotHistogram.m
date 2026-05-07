function PlotHistogram(x,x_plot,color,cut,plot_option)

if exist('cut')==0;
    cut=0;
end

if nargin<5;plot_option=0;end

    x=squeeze(x);
    [m,n]=size(x);
    if nargin<2    
        x_plot=1:n;
    end
    
    if nargin<3    
        color='k';
    end
    
    %x=x/trapz(x_plot,x);

    %plot(x_plot,mean(x,1)-std(x)/sqrt(m),'--','Color',color,'LineWidth',1.5)
    %plot(x_plot,mean(x,1)+std(x)/sqrt(m),'--','Color',color,'LineWidth',1.5)
    if size(x_plot,1)>size(x_plot,2);
        x_plot=x_plot';
    end
    x2=[x_plot,fliplr(x_plot)];
    %inbetween=[mean(x,1)-std(x)/sqrt(m),fliplr(mean(x,1)+std(x)/sqrt(m))];

    x(x<cut)=cut;    

    %inbetween=[zeros([1,length(mean(x,1))]),fliplr(mean(x,1))];
    inbetween=[ones([1,length(mean(x,1))])*cut,fliplr(mean(x,1))];
    inbetween(inbetween <= 0) = eps; 
    fill(x2,inbetween,color,'FaceAlpha',0.2,'LineStyle','none');hold on

    plot(x_plot,mean(x,1),'k','LineWidth',2,'Color',color);

    yl=get(gca,'ylim');
    line([0 0],yl*1.5,'Color','Black','LineStyle','--','LineWidth',1.5);
    hold off;
    
     if plot_option==1;
         set(gca,'FontSize',15,'LineWidth',1.5,'box','off');
     end
end