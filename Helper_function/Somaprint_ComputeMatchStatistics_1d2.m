
function [id_cellout1,id_cellout2,score_output,id_cell1,id_cell2,secondbest,per_cut,per_cut5,AUC]=Somaprint_ComputeMatchStatistics(align_matrix,map1,map2, method,lr_cut, plot_option,lambda)

% Plotting parameters
fontsize=20;
lw=2;
n_scale=1;


plot_color1st=[1 .65 0.45];
plot_color2nd=[0.45 0.45 1];
plot_color1st_dark=[.6 .35 0];
plot_color2nd_dark=[0 0 .6];


if exist('plot_option')==0;
    plot_option=1;
end

if exist('map1')==0;
    plot_option=0;
end

if exist('method')==0;
    method=2;
end

if exist('lambda')==0;
    lambda=0.01;
end

fprintf(['- Computing statistics, fitting Gaussian and Mixture Gaussian models... \n'])

%plot_option 0: regular 6 pannel, 2nd best 
%plot_option 1: regular 6 pannel, 2nd best 
%plot_option 2: regular 6 pannel, Mixed Gaussian

% ----- Step 1: Find the one-to-one match ----

    %data_scorestd = mean(reshape(align_matrix,[],1))+ data_stdcut*std(reshape(align_matrix,[],1));       
       [m,n]=size(align_matrix);output=zeros(m,n);count=0;id_cell1=[];id_cell2=[];
    
        % -----  Method 2: Pick the smallest -------------
        align_matrix2=align_matrix;count=0;id_cell1=[];id_cell2=[];
        for i=1:m;
            if max(max(align_matrix2))>0;
                maxidx=find(align_matrix2==max(max(align_matrix2))); 
                [id_cell1(i),id_cell2(i)]=ind2sub([m,n],maxidx(1)); 
                %score=align_matrix2(id_cell1_pre(i),id_cell2_pre(i));
                [temp,temp2]=sort(align_matrix2(id_cell1(i),:),'descend'); 
                
                best(i)=temp(1);
                secondbest(i)=temp(2);
                thirdbest(i)=temp(3);
 
                align_matrix2(id_cell1(i),:)=0;align_matrix2(:,id_cell2(i))=0;
            end

        end
    
    plot_data=align_matrix;

     for i=1:size(plot_data,1)
         [temp,temp_order]=sort(plot_data(i,:),'descend');
         secondbest_global(i)=temp(2); % Global true 2nd best, w/o greedy removal
         secondorder_global(i)=temp_order(2);
         thirdbest_global(i)=temp(3);
    end;


    for i=1:length(id_cell1);
        score(i)=plot_data(id_cell1(i),id_cell2(i));
        [temp,~]=sort(plot_data(id_cell1(i),:),'descend');
        if score(i)==max(plot_data(id_cell1(i),:));    
            ratio(i)=temp(1)/temp(2);         
        else
            ratio(i)=score(i)/max(plot_data(id_cell1(i),:));          
        end
    end

    % Break the function if no matched cells at all
    if length(id_cell1) ==0;
        id_cellout1=[];
        id_cellout2=[];
        id_anchor1=[];
        id_anchor2=[];
        score_output=[];
        return
    end

% ----- Step 2: Calculate the likelihood ratio ----
    score0=score;
    if exist('distortion')==1;
        for i=1:length(id_cell1);
            dis(i)=distortion(id_cell1(i),id_cell2(i));    
        end
    end
    
    a=0:0.5:max(score)+5;
    [b1,a]=hist(score,a);
    [b2,a]=hist(secondbest,a);
    [b4,a]=hist(thirdbest,a);
    score_all=reshape(plot_data,[],1);score_all(score_all==inf)=[];
    [b3,a]=hist(score_all,a);
    
    b1=b1/trapz(a,b1);
    b2=b2/trapz(a,b2);
    b3=b3/trapz(a,b3);
    b4=b4/trapz(a,b4);
    
    x_max=ceil(max(score)/10)*10;
    if plot_option==0;
         y_max=ceil(max(b2)*100/10)/10;
        cut_y=0;yl=[cut_y y_max*n_scale];  
    end

    if plot_option>0;
        subplot(2,3,2);
        y_max=ceil(max(b2)*100/10)/10;
        cut_y=0;yl=[cut_y y_max*n_scale];  
        PlotHistogram(b2*n_scale,a,plot_color2nd,cut_y);hold on;
        PlotHistogram(b1*n_scale,a,plot_color1st,cut_y);hold on;
    end

   %PlotHistogram(log10(b3*100+1),a,[0.4 0.4 0.4]);hold on;
  
    a_lr=a;%a_lr=0:0.25:max(score)+5;
    [b1_lr,a_lr]=hist(score,a_lr);
    [b2_lr,a_lr]=hist(secondbest,a_lr);

    b1_lr=b1_lr/trapz(a_lr,b1_lr);
    b2_lr=b2_lr/trapz(a_lr,b2_lr);

    % ----------- Likelihood ration from empirical data --------------
    lr=[];
    for ii=1:length(a_lr);
        lr(ii)=(sum(b2_lr(ii))/sum(b2_lr))/(sum(b1_lr(ii))/sum(b1_lr));
    end

    for ii=1:length(a_lr)
        cum_lr(ii)=sum(lr(ii:end)>0.05);
    end
    idx=find(cum_lr<1);
    cut_lr=a_lr(idx(1));    
  
    % -------- Gaussian fit of purple  -----------
    secondbest_fit=fitdist(secondbest','normal'); 
    
    %secondbest_fit=fitdist(secondbest_global','normal'); 

    y=normpdf(a_lr,secondbest_fit.mu,secondbest_fit.sigma);    
    
    % Model selection
    gm1=fitgmdist(score',1,'CovarianceType','diagonal','SharedCovariance',true,'Replicates',20,'RegularizationValue',0.1);
    gm2=fitgmdist(score',2,'CovarianceType','diagonal','SharedCovariance',true,'Replicates',20,'RegularizationValue',0.1);
    if gm1.BIC<gm2.BIC;
        n_gm=1;
        fprintf('- Fitting single Gaussian model... ...\n')
        % --- Gaussian mixture model ----
        %gmmodel=fitgmdist(score',n_gm,'CovarianceType','full','Replicates',20,'RegularizationValue',1e-6);
        gmmodel=fitgmdist(score',n_gm,'CovarianceType','full','Replicates',20,'RegularizationValue',lambda);
        %gmmodel=fitdist(score','normal'); 
    else
        n_gm=2;
        fprintf('-Fitting mixed Gaussian model... ...\n')
        % %Optional: seeded mixture Gaussian
        % initMu=[mean(secondbest);mean(score)];
        % S = struct();
        % S.mu = initMu;
        % S.Sigma = repmat(var(score), [1 1 2]);   
        % S.ComponentProportion = [0.5 0.5];       
        %gmmodel=fitgmdist(score',n_gm,'CovarianceType','full','Replicates',1,'RegularizationValue',1e-6,'Start',S);
        gmmodel=fitgmdist(score',n_gm,'CovarianceType','full','Replicates',20,'RegularizationValue',lambda);
    end


    % Plot fitted Gaussian and Mixed Gaussian

    if plot_option>0; % Summary plot of the fitting, plot with darker color
        plot(a_lr,y*n_scale,'Color',plot_color2nd_dark,'LineStyle','--','LineWidth',lw);
        plot(a_lr,pdf(gmmodel,a_lr')*n_scale,'Color',plot_color1st_dark,'LineStyle','--','LineWidth',lw)
    end

    
    if exist('lr_cut')==0;
        lr_cut=0.05;
    end

   x_range=0:0.01:50;
   if method==1 | n_gm==1;
        % Use 2nd best as noise to draw the cutoff
        posterior_left = @(x) (pdf(secondbest_fit,x)./pdf(gmmodel,x));
        post_vals = posterior_left(x_range');
        [~, idx_cut] = min(abs(post_vals -lr_cut));
        cutoff_2ndbest = x_range(idx_cut);
        cutoff= cutoff_2ndbest;
   end

    if method==2 & n_gm==2;
        % Use Mixed Gaussian to draw the 5% cutoff
        [~, idx] = sort(gmmodel.mu);
        mu1= gmmodel.mu(idx(1));
        mu2= gmmodel.mu(idx(2));
        sigma = squeeze(gmmodel.Sigma);s1 = sqrt(sigma(idx(1)));
        s2 = sqrt(sigma(idx(2)));
        p1 = gmmodel.ComponentProportion(idx(1));     
        p2 = gmmodel.ComponentProportion(idx(2));   
        posterior_left = @(x) (p1*normpdf(x, mu1, s1)) ./ (p1*normpdf(x, mu1, s1) + p2*normpdf(x, mu2, s2));
        post_vals = posterior_left(x_range);
        [~, idx_cut] = min(abs(post_vals - lr_cut));
        cutoff = x_range(idx_cut);
    end

    if idx_cut==1;
       fprintf(['-Warning. Unable to find LR<0.05...Use empirical data instead\n']);
       cutoff=cut_lr;
    end

    id_select=find(score>cutoff);
    score_output=score(id_select);
    % Computed sensitivity
    sensitivity=length(id_select)/size(plot_data,1)*100;

    % Computed x, empirical 
    AUC_labels = [ones(size(score)), zeros(size(secondbest))];  % 1 = signal, 0 = noise
    AUC_scores = [score,secondbest];
    [AUC_x,AUC_y,~,AUC] = perfcurve(AUC_labels, AUC_scores, 1);
    
    % Computed AUC, fitted curve
    cdf_noise = cumtrapz(a_lr, y);  
    AUC_fit = trapz(a_lr, cdf_noise .*pdf(gmmodel,a_lr')');

    id_cellout1=id_cell1(id_select);
    id_cellout2=id_cell2(id_select);

    fprintf(['- Somaprint completed: Matched cells: ',num2str(length(find(score>cutoff))),'/', num2str(m)...
            ,' , Percent: ',num2str(length(find(score>cutoff))/length(score)*100), ', AUC: ',num2str(AUC),'/',num2str(AUC_fit),'\n']);

    if plot_option > 0;  
        if exist('yl')==0;yl=get(gca,'YLim');end;
        if max(yl)>0.5;yl(2)=0.5;end;
        line([mean(cutoff),mean(cutoff)],yl,'LineStyle','--','Color',[0.3 .3 0.3],'LineWidth',lw)

        per_cut=length(id_select)/size(plot_data,1)*100;
        set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'TickLength',[0.026,1])
        set(gca,'XTick',[0:10:x_max]);
        set(gca,'YTick',[0:0.1:y_max]);
        set(get(gca(),'XAxis'),'MinorTickValues',[0:10:x_max])
        set(get(gca(),'YAxis'),'MinorTickValues',[5:10:y_max*100]/100*n_scale)
        ylim(yl);
        xlim([0 x_max]);
    end
    if plot_option==2;
        if n_gm==2;
            line([mu1,mu1],yl,'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
            line([mu2,mu2],yl,'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
        else
            line([gmmodel.mu,gmmodel.mu],yl,'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
        end
    end

   % ----- Step 4: Final plots ----

    if plot_option>0;  
        if length(size(map1))==3;
        subplot(2,3,1);        
        mymap=[0 0 0;.5 .5 .5;0 1 0;1 0 1; 1 1 1];
        plot_thre=0.3;
        map1=double(map1>plot_thre); map2=double(map2>plot_thre);
        imagesc(max(map1(:,:,id_cellout1),[],3)*2+max(map2(:,:,id_cellout2),[],3)*3)
        colormap(mymap);
        %imshowpair(max(map1(:,:,id_cellout1),[],3),max(map2(:,:,id_cellout2),[],3));
        set(gca,'FontSize',fontsize,'Visible','off');
       
        subplot(2,3,4);
        plot_map=map1;
        plot_map(:,:,id_cellout1)=plot_map(:,:,id_cellout1)*2.1;
        imagesc(max(plot_map,[],3));
       % mymap=[0 0 0;.5 .5 .5;0 .75 0];
        imagesc(max(plot_map,[],3));colormap(mymap);caxis([0 4]);
        set(gca,'FontSize',fontsize,'Visible','off');
       
        else
         subplot(2,3,4);
         plot(map1(:,1),map1(:,2),'o','MarkerSize',4,'Color',[0.7 0.7 0.7]);hold on;
         plot(map1(id_cellout1,1),map1(id_cellout1,2),'o','MarkerSize',4,'Color',[0 0.7 0]);hold on;
         set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
         set(gca,'XTick',[],'YTick',[]);   
         xl=get(gca,'XLim');yl=get(gca,'YLim');

         subplot(2,3,1);
         plot(map1(id_cellout1,1),map1(id_cellout1,2),'o','MarkerSize',4,'Color',[0 0.7 0]);hold on;
         plot(map2(id_cellout2,1),map2(id_cellout2,2),'o','MarkerSize',4,'Color',[.7 0 .7]);hold on;
         set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
         set(gca,'XTick',[],'YTick',[]);   
         xlim(xl);ylim(yl);

        end

        subplot(2,3,3);    
        plot(score,secondbest,'.','Color',[.5 .5 .5]);hold on;
        plot(score(1:length(id_cellout1)),secondbest(1:length(id_cellout1)),'.','Color',(plot_color1st_dark+plot_color1st)/2);yl=get(gca,'YLim');
        yl=yl*1.2;
        line([mean(cutoff),mean(cutoff)],yl,'LineStyle','--','Color',[.3 .3 .3],'LineWidth',lw)
        line(yl,yl,'LineStyle','--','Color',[.6 .6 .6],'LineWidth',lw)
        ylim(yl);
        set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);
        xl=get(gca,'XLim');

        subplot(2,3,6);
        fill([AUC_x; 1], [AUC_y; 0], plot_color1st,'FaceAlpha', 0.2, 'EdgeColor', 'none');hold on;
        plot(AUC_x, AUC_y, 'Color',plot_color1st,'LineWidth', lw);
        set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);

        subplot(2,3,5);
        PlotHistogram(b2*n_scale,a,plot_color2nd,0);hold on;
        PlotHistogram(b1*n_scale,a,plot_color1st,0);hold on;
        plot(a_lr,y*n_scale,'Color',plot_color2nd_dark,'LineStyle','--','LineWidth',lw);  
        plot(a_lr,pdf(gmmodel,a_lr')*n_scale,'Color',plot_color1st_dark,'LineStyle','--','LineWidth',lw)
        
        annotation('textbox', [0.03, 0.01, 0.8, 0.05], 'String', ['Matched cells: ',num2str(length(find(score>cutoff))),'/', num2str(length(score))...
            ,' , Percent: ',num2str(length(find(score>cutoff))/length(score)*100), ', AUC: ',num2str(AUC)], ...
           'FontSize', 12.5, 'HorizontalAlignment', 'center', 'EdgeColor', 'none');
    end

     if plot_option > 0;
        set(gca,'YScale','log');    
        line([mean(cutoff),mean(cutoff)],[eps,100],'LineStyle','--','Color',[0.3 .3 0.3],'LineWidth',lw)
        set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);
        ylim([0.002 1]*n_scale);
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'TickLength',[0.05,1])
        set(gca,'XTick',[0:10: x_max]);
        
        set(get(gca(),'XAxis'),'MinorTickValues',[10:10:x_max]);
        %
        xlim([0 x_max]);
     end

    if plot_option==2;
       if n_gm==2;
            line([mu1,mu1],[eps,100],'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
            line([mu2,mu2],[eps,100],'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
        else
            line([gmmodel.mu,gmmodel.mu],[eps,100],'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
        end
    end

    hold off;
end