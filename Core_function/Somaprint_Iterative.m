function [data_scorewd,data_id_cell1,data_id_cell2,data_score,tform,iiii]=Somaprint_Iterative (map1,map2_tform,option,data_scorewd,i_iter,run_tform);

%% ============== Step 2: option 1, Pre-registration with manual anchor points ========================================
Somaprint_LogMessage('------------------------------------------------------------------------------------------');
Somaprint_LogMessage('------------------------   Step 3: Somaprint iterative algorithm ------------------------ ');
Somaprint_LogMessage('------------------------------------------------------------------------------------------');
% ======== Step 3: Soma-print, iterative algorithm ===============

tic; % Start the timer
if exist('option')==0;
    option=GetDefautOption;
end

if exist('run_tform')==0;
    run_tform=0;
end



tform=[];

    data_nitermax=option.nitermax;
    data_nitermin=option.nitermin;
    data_n_vec1=option.n_vec1; % 1st iteration
    data_n_vec2=option.n_vec2;
    data_n_vec3=option.n_vec3;
    data_p_sum1=option.p_sum1;
    data_p_sum2=option.p_sum2;
    data_method=option.method;
    data_lr1st=option.lr1st;
    data_lr2nd=option.lr2nd;
    data_lambda=option.lambda;  
    data_gmmfilter=option.gmmfilter;

    data_sigma=option.sigma / option.pixellength;
    data_sigma2=option.sigma2 / option.pixellength;
    data_anchorsigma=option.anchorsigma / option.pixellength;
    data_foldexvivo=option.foldexvivo;

    [h1,w1,n1]=size(map1);[temp,temp,n2]=size(map2_tform);

if exist('i_iter')==0;
    i_iter=0;
else
    if isempty(i_iter)==1;
        i_iter=0;
    end
end

if i_iter==0; % Starting from the 1st run

    %%
    for iiii=1:data_nitermax;
        %%
            Somaprint_LogMessage(['- Starting rounds: ', num2str(iiii), '........']);
    
        if iiii==1;
            [data_scorewd{iiii},data_score{iiii}]=Somaprint_ComputeSomaprint(map1,map2_tform,data_n_vec1,data_p_sum1,data_sigma,round(data_foldexvivo*data_n_vec1));
        else
            id_cell1=data_id_cell1{iiii-1};id_cell2=data_id_cell2{iiii-1};
            if iiii==2;
                if length(id_cell1)>data_n_vec2;
                    [data_scorewd{iiii},data_score{iiii}]=Somaprint_ComputeSomaprintAnchor(map1,map2_tform,data_n_vec2,data_p_sum2,data_sigma2,id_cell1,id_cell2,data_anchorsigma);  
                else
                    Somaprint_LogMessage('- Warning!!!No enough anchor cells!');
                    return
                    data_id_cell1{iiii}=[];data_id_cell2{iiii}=[];
                end 
            end
    
             if iiii>2;
                if length(id_cell1)>data_n_vec3;
                    [data_scorewd{iiii},data_score{iiii}]=Somaprint_ComputeSomaprintAnchor(map1,map2_tform,data_n_vec3,data_p_sum2,data_sigma2,id_cell1,id_cell2,data_anchorsigma);  
                else
                    Somaprint_LogMessage('- Warning!!!No enough anchor cells!');
                    return
                    data_id_cell1{iiii}=[];data_id_cell2{iiii}=[];
                end 
            end
        end
    
        if iiii==1;   lr_cut=data_lr1st ;else; lr_cut=data_lr2nd;end
        [data_id_cell1{iiii},data_id_cell2{iiii}]=Somaprint_ComputeMatchStatistics(data_scorewd{iiii},map1,map2_tform,data_method,lr_cut,data_lambda,data_gmmfilter,0);
        emitIterationSummary(iiii, data_scorewd{iiii}, map1, map2_tform, data_method, lr_cut, data_lambda, data_gmmfilter);

        % if iiii==3 & run_tform==1;
        %      Somaprint_LogMessage('- Adjusting affine transformation based on matched cells!');
        %      [map2_tform,tform]=AdjustMap(map2_tform,map1, [data_id_cell1{iiii}',data_id_cell2{iiii}']);
        % end

        Somaprint_LogMessage('------------------------------------------------------------------------------------------');
        if iiii>2 & iiii>=data_nitermin; 
                if length(data_id_cell1{iiii})<length(data_id_cell1{iiii-1})*1.05;
                    fprintf('-Somaprint Complelted! \n ')
                    return;
                end
        end

    end

else; % if contitune from previosu run 
     iiii=i_iter;
     Somaprint_LogMessage(['- Continuing previous run, computing matched cells for round: ',num2str(iiii),' .... ...']);
     if iiii==1;   lr_cut=data_lr1st ;else; lr_cut=data_lr2nd;end
     [data_id_cell1{iiii},data_id_cell2{iiii}]=Somaprint_ComputeMatchStatistics(data_scorewd{iiii},map1,map2_tform,data_method,lr_cut,0,data_lambda);
     emitIterationSummary(iiii, data_scorewd{iiii}, map1, map2_tform, data_method, lr_cut, data_lambda, data_gmmfilter);

     Somaprint_LogMessage('-------------------------------------------------');
     
     for iiii=i_iter+1:data_nitermax;
            Somaprint_LogMessage(['- Starting rounds: ', num2str(iiii), '........']);
            id_cell1=data_id_cell1{iiii-1};id_cell2=data_id_cell2{iiii-1};
            if iiii==2;
                if length(id_cell1)>data_n_vec2;
                    [data_scorewd{iiii},data_score{iiii}]=Somaprint_ComputeSomaprintAnchor(map1,map2_tform,data_n_vec2,data_p_sum2,data_sigma2,id_cell1,id_cell2,data_anchorsigma);  
                else
                    Somaprint_LogMessage('- Warning!!!No enough anchor cells!');
                    return
                    data_id_cell1{iiii}=[];data_id_cell2{iiii}=[];
                end 
            end
    
             if iiii>2;
                if length(id_cell1)>data_n_vec3;
                    [data_scorewd{iiii},data_score{iiii}]=Somaprint_ComputeSomaprintAnchor(map1,map2_tform,data_n_vec3,data_p_sum2,data_sigma2,id_cell1,id_cell2,data_anchorsigma);  
                else
                    Somaprint_LogMessage('- Warning!!!No enough anchor cells!');
                    return
                    data_id_cell1{iiii}=[];data_id_cell2{iiii}=[];
                end 
             end
                 
            if iiii==1;   lr_cut=data_lr1st ;else; lr_cut=data_lr2nd;end
            [data_id_cell1{iiii},data_id_cell2{iiii}]=Somaprint_ComputeMatchStatistics(data_scorewd{iiii},map1,map2_tform,data_method,lr_cut,data_lambda, data_gmmfilter,0);
            emitIterationSummary(iiii, data_scorewd{iiii}, map1, map2_tform, data_method, lr_cut, data_lambda, data_gmmfilter);
            Somaprint_LogMessage('------------------------------------------------------------------------------------------');
             
             if iiii>2 & iiii>=data_nitermin; 
                if length(data_id_cell1{iiii})<length(data_id_cell1{iiii-1})*1.05;
                    fprintf('-Somaprint Complelted! \n')
                    return;
                end
             end
     end

elapsedTime = toc; % Stop the timer and store the value
Somaprint_LogMessage(sprintf('Runtime: %.4f seconds', elapsedTime));

end


