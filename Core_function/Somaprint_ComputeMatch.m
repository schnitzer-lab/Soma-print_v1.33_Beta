function [id_cell1,id_cell2,score,secondbest]=Somaprint_ComputeMatch(align_matrix, map1, map2,plot_option,lr_cut)

fontsize=20;
lw=2;
n_scale=1;

if exist('plot_option')==0;
    plot_option=0;
end

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
                % Greedy removal of the cell pairs
                align_matrix2(id_cell1(i),:)=0;align_matrix2(:,id_cell2(i))=0;
            end
        end

    % ------ 


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


end