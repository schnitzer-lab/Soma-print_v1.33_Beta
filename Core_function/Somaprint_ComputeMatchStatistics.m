
function [id_cellout1,id_cellout2,output_sumamry,option_output,id_cell1,id_cell2,secondbest,AUC]=Somaprint_ComputeMatchStatistics(align_matrix,map1,map2,method,lr_cut,lambda,gmmfilter,plot_option,app,image1,image2)

id_cellout1=[];
id_cellout2=[];
output_sumamry=[];
id_cell1=[];
id_cell2=[];
secondbest=[];
AUC=NaN;

% Plotting parameters
fontsize=20;
lw=2;
n_scale=1;

plot_color1st=[1 .65 0.45];
plot_color2nd=[0.45 0.45 1];
plot_color1st_dark=[.6 .35 0];
plot_color2nd_dark=[0 0 .6];


if exist('plot_option')==0;
    plot_option=0;
end

if exist('map1')==0;
    plot_option=0;
end

if exist('method')==0;
    method=2;
else
    if isempty(method)==1; method=2;;end;
end

if exist('lambda')==0;
    lambda=0.001;
else
    if isempty(lambda)==1;lambda=0.001;end;
end

if exist('lr_cut')==0;
        lr_cut=0.05;
else
    if isempty(lr_cut)==1;lr_cut=0.05;;end;
end

if exist('gmmfilter')==0;
      gmmfilter=0;
else
    if isempty(gmmfilter)==1;gmmfilter=0;;end;
end



option_output.method=method;
option_output.lambda=lambda;
option_output.lrcut=lr_cut;
option_output.gmmfilter=gmmfilter;
fprintf(['- Computing statistics, fitting Gaussian and Mixture Gaussian models... \n'])


% ----- Step 1: Find the one-to-one match ----

    %data_scorestd = mean(reshape(align_matrix,[],1))+ data_stdcut*std(reshape(align_matrix,[],1));       
       [m,n]=size(align_matrix);output=zeros(m,n);count=0;id_cell1=[];id_cell2=[];
    
        % -----  Method 2: Pick the smallest -------------
        align_matrix2=align_matrix;count=0;id_cell1=[];id_cell2=[];
        for i=1:m;
            if max(max(align_matrix2))>0;
                maxidx=find(align_matrix2==max(max(align_matrix2))); 
                [id_cell1(i),id_cell2(i)]=ind2sub([m,n],maxidx(1));
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
        AUC=NaN;
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

    a_lr=a;%a_lr=0:0.25:max(score)+5;
    [b1_lr,a_lr]=hist(score,a_lr);
    [b2_lr,a_lr]=hist(secondbest,a_lr);

    b1_lr=b1_lr/trapz(a_lr,b1_lr);
    b2_lr=b2_lr/trapz(a_lr,b2_lr);

    % % ----------- Likelihood ration from empirical data --------------
    % lr=[];
    % for ii=1:length(a_lr);
    %     lr(ii)=(sum(b2_lr(ii))/sum(b2_lr))/(sum(b1_lr(ii))/sum(b1_lr));
    % end
    % for ii=1:length(a_lr)
    %     cum_lr(ii)=sum(lr(ii:end)>0.05);
    % end
    % idx=find(cum_lr<1);
    % cut_lr=a_lr(idx(1));    
  
    % -------- Gaussian fit of 2nd best distribution  -----------
    secondbest_fit=fitdist(secondbest','normal'); 
    
    %secondbest_fit=fitdist(secondbest_global','normal'); 

    y=normpdf(a_lr,secondbest_fit.mu,secondbest_fit.sigma);    
    
   
    fprintf('- Fitting mixed Gaussian model... ...\n')
    %Optional: seeded mixture Gaussian
    S = struct();
    id_score=find(score>(secondbest_fit.mu+3*secondbest_fit.sigma));
    if length(id_score)>=2;
        S.mu = [mean(secondbest);mean(score(id_score))];
        S.Sigma(1,1,:) = [var(secondbest);var(score(id_score))];%repmat(var(score), [1 1 2]);                   
        proportion_3td=sum(score>(secondbest_fit.mu+3*secondbest_fit.sigma))/length(score);
    else
        S.mu = [mean(secondbest);max(score)];
        S.Sigma(1,1,:) = [var(secondbest);var(secondbest)/2];%repmat(var(score), [1 1 2]);     
        proportion_3td=1/length(score);
    end
    S.ComponentProportion = [1-proportion_3td,proportion_3td]; 
              
   
    % lambda_all=[0.001,0.001,0.01,0.1,0.5,1,5,10];
    % for i=1:length(lambda_all);
    % 
    %     gmmodel_all{i}=fitgmdist(score',2,'CovarianceType','full','Replicates',1,'RegularizationValue',lambda_all(i),'Start',S);
    %     bic_scores(i) = gmmodel_all{i}.BIC;
    % end    
  try
    %%
    clear gmmodel;
    % score_augmented=WeightingGMM(score',quantile(score, 0.80));
    % gmmodel=fitgmdist(score_augmented,2,'CovarianceType','full','Replicates',1,'RegularizationValue',lambda,...
    %     'Start',S);
    if gmmfilter>=0;
        score_threshold=mean(mean(align_matrix))+gmmfilter*std(reshape(align_matrix,[],1));
        score_weighted=score(score> score_threshold);
        gmmodel=fitgmdist(score_weighted',2,'CovarianceType','full','Replicates',1,'RegularizationValue',lambda,...
        'Start',S);
    else;
        gmmodel=fitgmdist(score',2,'CovarianceType','full','Replicates',1,'RegularizationValue',lambda,...
        'Start',S);
    end
    

  catch
    fprintf('- Terminating! Cannot fit mixture Gaussian.... ...Please try again with new parameters. ')
    return;
  end
    %gmmodel=fitgmdist(score',2,'CovarianceType','full','Replicates',20,'RegularizationValue',lambda);

    % Plot fitted Gaussian and Mixed Gaussian


    % Readout the Mixture Gaussian
     x_range=0:0.001:50;
     [~, idx] = sort(gmmodel.mu);
     mu1= gmmodel.mu(idx(1));
     mu2= gmmodel.mu(idx(2));
     sigma = squeeze(gmmodel.Sigma);
     s1 = sqrt(sigma(idx(1)));
     s2 = sqrt(sigma(idx(2)));
     p1 = gmmodel.ComponentProportion(idx(1));     
     p2 = gmmodel.ComponentProportion(idx(2));   
     H1_pdf = @(x) normpdf(x, mu2, s2);
     gmmodel_pdf=  @(x) (pdf(gmmodel,x));


    % if method==2; % Model selection
    % 
    %     gm1=fitgmdist(score',1,'CovarianceType','diagonal','SharedCovariance',true,'Replicates',20,'RegularizationValue',0.1);
    %     gm2=fitgmdist(score',2,'CovarianceType','diagonal','SharedCovariance',true,'Replicates',20,'RegularizationValue',0.1);
    %     if gm1.BIC<gm2.BIC;
    %         n_gm=1;
    %         fprintf('- Fitting single Gaussian model... ...\n')
    %         % --- Gaussian mixture model ----
    %         %gmmodel=fitgmdist(score',n_gm,'CovarianceType','full','Replicates',20,'RegularizationValue',1e-6);
    %         gmmodel=fitgmdist(score',n_gm,'CovarianceType','full','Replicates',20,'RegularizationValue',lambda);
    %         %gmmodel=fitdist(score','normal'); 
    % else
    %         n_gm=2;
    %     end
    % end

   if method==1 ;%| n_gm==1;
       H0_pdf = @(x) pdf(secondbest_fit, x);
       H0_cdf = @(x) cdf(secondbest_fit, x);
       mu_H0=secondbest_fit.mu;
   end

    if method==2 ;%& n_gm==2;
       H0_pdf= @(x) normpdf(x, mu1, s1);
       H0_cdf= @(x) normcdf(x, mu1, s1);
       mu_H0=mu1;
         
    end

    
    % --- p-value---
    pvalue_func = @(x) 1 - H0_cdf(x);

    % --- Likelihood ratio --- 
    x_range=x_range(x_range>mu_H0); % Search in the right tail
    LikelihoodRatio_func=@(x) H0_pdf(x)./ H1_pdf(x) ;
    LikelihoodRatio = LikelihoodRatio_func(x_range');
    valid_indices = find( LikelihoodRatio < lr_cut);
    if ~isempty(valid_indices);
        [~, local_idx] = max( LikelihoodRatio(valid_indices));idx_cut = valid_indices(local_idx); %[~, idx_cut] = min(abs(LikelihoodRatio -lr_cut));
        cutoff = x_range(idx_cut);
    else;
        fprintf('- Warning! No matched cells are found ... Try adjusting parameters. \n')
        return
    end

    if method==2 %:& n_gm==2; % === Final output ===
       % --- Posterior probability ---
        PosteriorProbability_func = @(x) (p1 * H0_pdf(x)) ./ gmmodel_pdf(x);
        PosteriorProbability=PosteriorProbability_func(x_range');
        %[~, idx_cut] = min(abs(PosteriorProbability -lr_cut));
        valid_indices = find(PosteriorProbability < lr_cut);
        if ~isempty(valid_indices);
            [~, local_idx] = max(PosteriorProbability(valid_indices));idx_cut = valid_indices(local_idx); %[~, idx_cut] = min(abs(PosteriorProbability -lr_cut));
            cutoff = x_range(idx_cut);
        else;
            fprintf('- Warning! No matched cells are found ... Try adjusting parameters. \n')

            return
        end
        
    
        output_sumamry(:,1)=id_cell1;
        output_sumamry(:,2)=id_cell2;
        output_sumamry(:,3)=score;
        output_sumamry(:,4)=PosteriorProbability_func(score');   
        output_sumamry(:,5)=LikelihoodRatio_func(score);
        output_sumamry(:,6)=pvalue_func(score);
        
        p_cutoff=0.05;
        id_stats=6;id_output1_pv=output_sumamry(find(output_sumamry(:,id_stats)<p_cutoff),1);id_output2_pv=output_sumamry(find(output_sumamry(:,id_stats)<p_cutoff),2);
        id_stats=5;id_output1_lr=output_sumamry(find(output_sumamry(:,id_stats)<p_cutoff),1);id_output2_lr=output_sumamry(find(output_sumamry(:,id_stats)<p_cutoff),2);
        id_stats=4;id_output1_pp=output_sumamry(find(output_sumamry(:,id_stats)<p_cutoff),1);id_output2_pp=output_sumamry(find(output_sumamry(:,id_stats)<p_cutoff),2);

    end

    id_select=find(score>cutoff);
    
    % Computed sensitivity
    sensitivity=length(id_select)/size(plot_data,1)*100;

    % Computed x, empirical 
    if length(id_select)>0;
        AUC_labels = [ones(size(score(id_select))), zeros(size(secondbest))];  % 1 = signal, 0 = noise
        AUC_scores = [score(id_select),secondbest];
        [AUC_x,AUC_y,~,AUC] = perfcurve(AUC_labels, AUC_scores, 1);
        
        % Computed AUC, fitted curve
        %cdf_noise = cumtrapz(a_lr, y);  
        %AUC_fit = trapz(a_lr, cdf_noise .*pdf(gmmodel,a_lr')');
    end
    id_cellout1=id_cell1(id_select);
    id_cellout2=id_cell2(id_select);

    fprintf(['- Somaprint completed: Matched cells: ',num2str(length(find(score>cutoff))),'/', num2str(m)...
            ,' , Percent: ',num2str(length(find(score>cutoff))/length(score)*100), ', ex vivo: ',num2str(size(map2,3)),'\n']);


%     if plot_option==2;
%         if n_gm==2;
%             line([mu1,mu1],yl,'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
%             line([mu2,mu2],yl,'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
%         else
%             line([gmmodel.mu,gmmodel.mu],yl,'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
%         end
%     end

   % ----- Step 4: Final plots ----

    if plot_option==1;  % Simple plotting
        if length(size(map1))==3;
        subplot(2,2,1);        
        mymap=[0 0 0;.5 .5 .5;0 1 0;1 0 1; 1 1 1];
        plot_thre=0.3;
        map1=double(map1>plot_thre); map2=double(map2>plot_thre);
        imagesc(max(map1(:,:,id_cellout1),[],3)*2+max(map2(:,:,id_cellout2),[],3)*3)
        colormap(mymap);
        %imshowpair(max(map1(:,:,id_cellout1),[],3),max(map2(:,:,id_cellout2),[],3));
        set(gca,'FontSize',fontsize,'Visible','off');
       
        subplot(2,2,3);
        plot_map=map1;
        plot_map(:,:,id_cellout1)=plot_map(:,:,id_cellout1)*2.1;
        imagesc(max(plot_map,[],3));
       % mymap=[0 0 0;.5 .5 .5;0 .75 0];
        imagesc(max(plot_map,[],3));colormap(mymap);caxis([0 4]);
        set(gca,'FontSize',fontsize,'Visible','off');
       
       else % ---- If inputs are centrods -----
         l1=max(max(map1(:,1))-min(map1(:,1)), max(map2(:,1))-min(map2(:,1)));           
         l2=max(max(map1(:,2))-min(map1(:,2)),max(map2(:,2))-min(map2(:,2)));
            subplot(2,2,1);radius = 8;
             l1=round(max(max(map1(:,1))-min(map1(:,1)), max(map2(:,1))-min(map2(:,1))));           
             l2=round(max(max(map1(:,2))-min(map1(:,2)),max(map2(:,2))-min(map2(:,2))));        
             mask1 = insertShape(zeros([l2,l1]), 'FilledCircle', [map1(id_cellout1,[2,1]), repmat(radius, length(id_cellout1), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask2 = insertShape(zeros([l2,l1]), 'FilledCircle', [map2(id_cellout2,[2,1]), repmat(radius, length(id_cellout2), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask1=mask1 (:,:,1)>0;mask2=mask2 (:,:,1)>0; 
            imagesc(mask1*2+mask2*3);set(gca,'FontSize',fontsize,'Visible','off');
             mymap=[0 0 0;.5 .5 .5;0 1 0;1 0 1; 1 1 1];colormap(mymap);
             set(gca,'FontSize',fontsize,'Visible','off');
             set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
             set(gca,'XTick',[],'YTick',[]);  xl=get(gca,'XLim');yl=get(gca,'YLim');

             subplot(2,2,3);
             mask1 = insertShape(zeros([l2,l1]), 'FilledCircle', [map1(id_cellout1,[2,1]), repmat(radius, length(id_cellout1), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask2 = insertShape(zeros([l2,l1]), 'FilledCircle', [map1(:,[2,1]), repmat(radius, size(map1,1), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask1=mask1 (:,:,1)>0;mask2=mask2 (:,:,1)>0;
            imagesc(mask1*1+mask2*1);set(gca,'FontSize',fontsize,'Visible','off');
            colormap(mymap);caxis([0 4])
            set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
            set(gca,'XTick',[],'YTick',[]);   xlim(xl);ylim(yl);

             % subplot(2,2,3);
             % plot(map1(:,1),map1(:,2),'o','MarkerSize',4,'Color',[0.7 0.7 0.7]);hold on;
             % plot(map1(id_cellout1,1),map1(id_cellout1,2),'o','MarkerSize',4,'Color',[0 0.7 0]);hold on;
             % set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
             % set(gca,'XTick',[],'YTick',[]);   
             % xlim([0 l1]);ylim([0 l2]);
             % 
             % subplot(2,2,1);
             % plot(map1(id_cellout1,1),map1(id_cellout1,2),'o','MarkerSize',4,'Color',[0 0.7 0]);hold on;
             % plot(map2(id_cellout2,1),map2(id_cellout2,2),'o','MarkerSize',4,'Color',[.7 0 .7]);hold on;
             % set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
             % set(gca,'XTick',[],'YTick',[]);   
             % xlim([0 l1]);ylim([0 l2]);

        end

        subplot(2,2,2); % Mixture Gaussian fit 
        y_max=ceil(max(b2)*100/10)/10;
        cut_y=0;yl=[cut_y y_max*n_scale];  
        PlotHistogram(b2*n_scale,a,plot_color2nd,cut_y);hold on;
        PlotHistogram(b1*n_scale,a,plot_color1st,cut_y);hold on;
        plot(a_lr,y*n_scale,'Color',plot_color2nd_dark,'LineStyle','--','LineWidth',lw);
        plot(a_lr,pdf(gmmodel,a_lr')*n_scale,'Color',plot_color1st_dark,'LineStyle','--','LineWidth',lw)

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
       
        subplot(2,2,4);
        PlotHistogram(b2*n_scale,a,plot_color2nd,0);hold on;
        PlotHistogram(b1*n_scale,a,plot_color1st,0);hold on;
        plot(a_lr,y*n_scale,'Color',plot_color2nd_dark,'LineStyle','--','LineWidth',lw);  
        plot(a_lr,pdf(gmmodel,a_lr')*n_scale,'Color',plot_color1st_dark,'LineStyle','--','LineWidth',lw)
        set(gca,'YScale','log');    
        line([mean(cutoff),mean(cutoff)],[eps,100],'LineStyle','--','Color',[0.3 .3 0.3],'LineWidth',lw)
        set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);
        ylim([0.002 1]*n_scale);
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'TickLength',[0.05,1])
        set(gca,'XTick',[0:10: x_max]);     
        set(get(gca(),'XAxis'),'MinorTickValues',[10:10:x_max]);
        xlim([0 x_max]);

        annotation('textbox', [0.03, 0.01, 0.8, 0.05], 'String', ...
            ['Matched cells: ',num2str(length(find(score>cutoff))),'/', num2str(length(score))...
            ,' , Percent: ',num2str(compose("%.1f%%",length(find(score>cutoff))/length(score)*100)), ', mean score: ',num2str(mean(score(score>cutoff))),...
            'mean 2nd-best: ',num2str(mean(secondbest))], ...
           'FontSize', 7.5, 'HorizontalAlignment', 'center', 'EdgeColor', 'none');
    end


   if plot_option==2; % Figure plotting, cell map adjusted 
%%
        if length(size(map1))==3; % Inputs are cell maps 
            [peak1,lx1,ly1]=Somaprint_ComputePeak(map1(:,:,1:round(quantile(1:size(map1,3),0.1))));
            [peak2,lx2,ly2]=Somaprint_ComputePeak(map2(:,:,1:round(quantile(1:size(map2,3),0.3))));
            fprintf('- Resizing map, ')
            map1=ReplotMap(map1,mean(lx2(lx2>0))/mean(lx1(lx1>0)));
            %map2=ReplotMap(map2,mean(lx1(lx1>0))/mean(lx2(lx2>0)));

            fprintf('- Ploting ...')
            subplot(2,3,1);        
            mymap=[0 0 0;.5 .5 .5;0 1 0;1 0 1; 1 1 1];
            plot_thre=0.3;map1=double(map1>plot_thre); map2=double(map2>plot_thre);
            imagesc(max(map1(:,:,id_cellout1),[],3)*2+max(map2(:,:,id_cellout2),[],3)*3)
            colormap(mymap);
            set(gca,'FontSize',fontsize,'Visible','off');
           
            subplot(2,3,2);
            fprintf(' ... ')
            n=20;plot_map=(map1>0)*(1/n);max_score=max(score);
            for i = 1:length(id_cellout1);
                    intensity = 2/n + ((1-2/n) * ((score(i)-cutoff) / max_score));
                    plot_map(:,:,id_cell1(i)) = map1(:,:,id_cell1(i)) * intensity;
            end
            fprintf(' ... ')
            custom_map = zeros(n, 3);custom_map(1, :) = [0 0 0];
            custom_map(2, :) = [0.5, 0.5, 0.5];
            green_gradient = linspace(0.4, 1, n-2)';
            custom_map(3:end, 2) = green_gradient;
            imagesc(max(plot_map,[],3));caxis([0 1]);
            ax2=subplot(2,3,2);colormap(ax2,custom_map);caxis([0 1]);
            set(gca,'FontSize',fontsize,'Visible','off');
            
            subplot(2,3,3);
            n=20;plot_map=(map2>0)*(1/n);
            for i = 1:length(id_cellout2);
                    intensity = 2/n + ((1-2/n) * ((score(i)-cutoff) / max_score));
                    plot_map(:,:,id_cell2(i)) = map2(:,:,id_cell2(i)) * intensity;
            end
            fprintf(' ... ')
            custom_map = zeros(n, 3);custom_map(1, :) = [0 0 0];
            custom_map(2, :) = [0.5, 0.5, 0.5];
            gradient = linspace(0.4, 1, n-2)';
            custom_map(3:end,1) = gradient;custom_map(3:end,3) = gradient;
            imagesc(max(plot_map,[],3));caxis([0 1]);
            ax2=subplot(2,3,3);colormap(ax2,custom_map);caxis([0 1]);
            set(gca,'FontSize',fontsize,'Visible','off');

        else % ----- Inputs are centroids (X/Y corrected) -----
             subplot(2,3,1);radius = 8;
             l1=round(max(max(map1(:,1))-min(map1(:,1)), max(map2(:,1))-min(map2(:,1))));           
             l2=round(max(max(map1(:,2))-min(map1(:,2)),max(map2(:,2))-min(map2(:,2))));      
             l1=round(max(map1(:,1))-min(map1(:,1)));           
             l2=round(max(map1(:,2))-min(map1(:,2)));  
             mask1 = insertShape(zeros([l2,l1]), 'FilledCircle', [map1(id_cellout1,[2,1]), repmat(radius, length(id_cellout1), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask2 = insertShape(zeros([l2,l1]), 'FilledCircle', [map2(id_cellout2,[2,1]), repmat(radius, length(id_cellout2), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask1=mask1 (:,:,1)>0;mask2=mask2 (:,:,1)>0; 
            imagesc(mask1*2+mask2*3);set(gca,'FontSize',fontsize,'Visible','off');
            mymap=[0 0 0;.5 .5 .5;0 1 0;1 0 1; 1 1 1];colormap(mymap);
             set(gca,'FontSize',fontsize,'Visible','off');
             set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
             set(gca,'XTick',[],'YTick',[]);  xl=get(gca,'XLim');yl=get(gca,'YLim');

             subplot(2,3,2);
             mask1 = insertShape(zeros([l2,l1]), 'FilledCircle', [map1(id_cellout1,[2,1]), repmat(radius, length(id_cellout1), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask2 = insertShape(zeros([l2,l1]), 'FilledCircle', [map1(:,[2,1]), repmat(radius, size(map1,1), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask1=mask1 (:,:,1)>0;mask2=mask2 (:,:,1)>0;
            imagesc(mask1*1+mask2*1);set(gca,'FontSize',fontsize,'Visible','off');
            colormap(mymap);caxis([0 4])
            set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
            set(gca,'XTick',[],'YTick',[]);   xlim(xl);ylim(yl);

            subplot(2,3,3);
             mask1 = insertShape(zeros([l2,l1]), 'FilledCircle', [map2(id_cellout2,[2,1]), repmat(radius, length(id_cellout2), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask2 = insertShape(zeros([l2,l1]), 'FilledCircle', [map2(:,[2,1]), repmat(radius, size(map2,1), 1)], ...
                    'Color', 'white', 'Opacity', 1, 'SmoothEdges', false);
             mask1=mask1 (:,:,1)>0;mask2=mask2 (:,:,1)>0;
             
            mymap=[0 0 0;.5 .5 .5;0 1 0;1 0 1; 1 1 1];
            imagesc(mask1*2+mask2*1);set(gca,'FontSize',fontsize,'Visible','off');
            colormap(mymap);caxis([0 4])

             set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
             set(gca,'XTick',[],'YTick',[]);   
             xlim(xl);ylim(yl);

        end

        subplot(2,3,4); % Mixture Gaussian fit 
        y_max=ceil(max(b2)*100/10)/10;
        cut_y=0;yl=[cut_y y_max*n_scale];  
        PlotHistogram(b2*n_scale,a,plot_color2nd,cut_y);hold on;
        PlotHistogram(b1*n_scale,a,plot_color1st,cut_y);hold on;
        plot(a_lr,y*n_scale,'Color',plot_color2nd_dark,'LineStyle','--','LineWidth',lw);
        plot(a_lr,pdf(gmmodel,a_lr')*n_scale,'Color',plot_color1st_dark,'LineStyle','--','LineWidth',lw)

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
        fprintf(' ... \n')

        subplot(2,3,6);     % Individual cells
        plot(score,secondbest,'.','Color',[.5 .5 .5]);hold on;
        plot(score(1:length(id_cellout1)),secondbest(1:length(id_cellout1)),'.','Color',(plot_color1st_dark+plot_color1st)/2);yl=get(gca,'YLim');
        yl=yl*1.2;
        line([mean(cutoff),mean(cutoff)],yl,'LineStyle','--','Color',[.3 .3 .3],'LineWidth',lw)
        %line(yl,yl,'LineStyle','--','Color',[.6 .6 .6],'LineWidth',lw)
        ylim(yl);
        set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);
        xl=get(gca,'XLim');

        %subplot(2,3,6);
        % fill([AUC_x; 1], [AUC_y; 0], plot_color1st,'FaceAlpha', 0.2, 'EdgeColor', 'none');hold on;
        % plot(AUC_x, AUC_y, 'Color',plot_color1st,'LineWidth', lw);
        % set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);

        subplot(2,3,5); % Log scale 
        PlotHistogram(b2*n_scale,a,plot_color2nd,0);hold on;
        PlotHistogram(b1*n_scale,a,plot_color1st,0);hold on;
        plot(a_lr,y*n_scale,'Color',plot_color2nd_dark,'LineStyle','--','LineWidth',lw);  
        plot(a_lr,pdf(gmmodel,a_lr')*n_scale,'Color',plot_color1st_dark,'LineStyle','--','LineWidth',lw)
        set(gca,'YScale','log');    
        line([mean(cutoff),mean(cutoff)],[eps,100],'LineStyle','--','Color',[0.3 .3 0.3],'LineWidth',lw)
        set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);
        ylim([0.002 1]*n_scale);
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'TickLength',[0.05,1])
        set(gca,'XTick',[0:10: x_max]);     
        set(get(gca(),'XAxis'),'MinorTickValues',[10:10:x_max]);
        xlim([0 x_max]);
    if method==2;
       
        annotation('textbox', [0.03, 0.01, 0.8, 0.05], 'String', ...
            ['Matched: ',num2str(length(find(score>cutoff))),'/', num2str(length(score))...
            ,' , Percent: ',num2str(compose("%.1f%%",length(find(score>cutoff))/length(score)*100)),', ex vivo:', num2str(size(map2,3)),...
            ',p-val:', num2str(length(id_output1_pv)), ',LR:', num2str(length(id_output1_lr))], ...
           'FontSize', 10, 'HorizontalAlignment', 'center', 'EdgeColor', 'none');  
    
    else
        annotation('textbox', [0.03, 0.01, 0.8, 0.05], 'String', ...
            ['Matched: ',num2str(length(find(score>cutoff))),'/', num2str(length(score))...
            ,' , Percent: ',num2str(compose("%.1f%%",length(find(score>cutoff))/length(score)*100)),', ex vivo:', num2str(size(map2,3))], ...
           'FontSize', 10, 'HorizontalAlignment', 'center', 'EdgeColor', 'none');  
    end
   end

% ----- Step 4: Final plots ----

    if plot_option==4;  
        if length(size(map1))==3;
      
        subplot(3,4,9);        
        mymap=[0 0 0;.5 .5 .5;0 1 0;1 0 1; 1 1 1];
        plot_thre=0.3;
        map1=double(map1>plot_thre); map2=double(map2>plot_thre);
        imagesc(max(map1(:,:,id_cellout1),[],3)*2+max(map2(:,:,id_cellout2),[],3)*3)
        colormap(mymap);
        %imshowpair(max(map1(:,:,id_cellout1),[],3),max(map2(:,:,id_cellout2),[],3));
        set(gca,'FontSize',fontsize,'Visible','off');
       
        subplot(3,4,10);
        plot_map=map1;
        plot_map(:,:,id_cellout1)=plot_map(:,:,id_cellout1)*2.1;
        imagesc(max(plot_map,[],3));
       % mymap=[0 0 0;.5 .5 .5;0 .75 0];
        imagesc(max(plot_map,[],3));colormap(mymap);caxis([0 4]);
        set(gca,'FontSize',fontsize,'Visible','off');
       
        else

         subplot(3,4,10);
         plot(map1(:,1),map1(:,2),'o','MarkerSize',4,'Color',[0.7 0.7 0.7]);hold on;
         plot(map1(id_cellout1,1),map1(id_cellout1,2),'o','MarkerSize',4,'Color',[0 0.7 0]);hold on;
         set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
         set(gca,'XTick',[],'YTick',[]);   
         xl=get(gca,'XLim');yl=get(gca,'YLim');

         subplot(3,4,9);
         plot(map1(id_cellout1,1),map1(id_cellout1,2),'o','MarkerSize',4,'Color',[0 0.7 0]);hold on;
         plot(map2(id_cellout2,1),map2(id_cellout2,2),'o','MarkerSize',4,'Color',[.7 0 .7]);hold on;
         set(gca,'XDir','normal','YDir','reverse','LineWidth',2)
         set(gca,'XTick',[],'YTick',[]);   
         xlim(xl);ylim(yl);

        end
        subplot(3,4,11);
        y_max=ceil(max(b2)*100/10)/10;
        cut_y=0;yl=[cut_y y_max*n_scale];  
        PlotHistogram(b2*n_scale,a,plot_color2nd,cut_y);hold on;
        PlotHistogram(b1*n_scale,a,plot_color1st,cut_y);hold on;
        plot(a_lr,y*n_scale,'Color',plot_color2nd_dark,'LineStyle','--','LineWidth',lw);
        plot(a_lr,pdf(gmmodel,a_lr')*n_scale,'Color',plot_color1st_dark,'LineStyle','--','LineWidth',lw)

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
      
        subplot(3,4,12);
        PlotHistogram(b2*n_scale,a,plot_color2nd,0);hold on;
        PlotHistogram(b1*n_scale,a,plot_color1st,0);hold on;
        plot(a_lr,y*n_scale,'Color',plot_color2nd_dark,'LineStyle','--','LineWidth',lw);  
        plot(a_lr,pdf(gmmodel,a_lr')*n_scale,'Color',plot_color1st_dark,'LineStyle','--','LineWidth',lw)
        set(gca,'YScale','log');    
        line([mean(cutoff),mean(cutoff)],[eps,100],'LineStyle','--','Color',[0.3 .3 0.3],'LineWidth',lw)
        set(gca,'FontSize',fontsize,'box','off','LineWidth',lw);
        ylim([0.002 1]*n_scale);
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'TickLength',[0.05,1])
        set(gca,'XTick',[0:10: x_max]);     
        set(get(gca(),'XAxis'),'MinorTickValues',[10:10:x_max]);
        xlim([0 x_max]);

        subplot(3,4,[1,2,5,6]);
        ax1=subplot(3,4,[1,2,5,6]);
        imagesc(normimage(image1));caxis([0 1.1])
        set(gca,'Visible','off');colormap(ax1,bone(256));
        id_plot1=round(linspace(1,length(id_select)-10,30));
        id_plot2=round(linspace(max(1,length(id_select)-10),length(id_select),5));
        id_plot3=round(linspace(length(id_select)+1,min(length(id_select)+10,length(id_cell1)),5));       
        hold on;

        for i=1:length(id_plot1);
             PlotCellMap(map1,[0 .6 0],id_cell1(id_plot1(i)),[],2);
        end
        for i=1:length(id_plot2);         
            PlotCellMap(map1,[0.4 .4 0],id_cell1(id_plot2(i)),[],2);
            PlotCellMap(map1,[0.6 0 0],id_cell1(id_plot3(i)),[],2);
        end

        subplot(3,4,[3,4,7,8]);
        imagesc(normimage(image2));caxis([0 1.1])
        set(gca,'Visible','off');hold on;
        ax2=subplot(3,4,[3,4,7,8]);colormap(ax2,bone(256));
        hold on;
        for i=1:length(id_plot1);
                PlotCellMap(map1,[0 .6 0],id_cell1(id_plot1(i)),[],2);
        end
        for i=1:length(id_plot2);         
            PlotCellMap(map1,[0.4 .4 0],id_cell1(id_plot2(i)),[],2);
            PlotCellMap(map1,[0.6 0 0],id_cell1(id_plot3(i)),[],2);
        end

        annotation('textbox', [0.03, 0.01, 0.8, 0.05], 'String', ['Matched cells: ',num2str(length(find(score>cutoff))),'/', num2str(length(score))...
            ,' , Percent: ',compose("%.1f%%",num2str(length(find(score>cutoff))/length(score)*100)), ', ex vivo: ',num2str(size(map2,3))], ...
           'FontSize', 12.5, 'HorizontalAlignment', 'center', 'EdgeColor', 'none');
    end


%     if plot_option==2;
%        if n_gm==2;
%             line([mu1,mu1],[eps,100],'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
%             line([mu2,mu2],[eps,100],'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
%         else
%             line([gmmodel.mu,gmmodel.mu],[eps,100],'LineStyle','--','Color',plot_color1st,'LineWidth',lw);
%         end
%     end

    %hold off;
end
