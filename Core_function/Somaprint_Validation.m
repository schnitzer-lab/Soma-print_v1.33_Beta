function [precision, recall, hit,fa,miss,cr]=Somaprint_Validation(id_output1,id_output2,id_red1,id_red2,plot_option);
    %%

    if exist('plot_option')==0;
        plot_option=1;
    end
    hit= find(id_red1(id_output1)==1  &  id_red2(id_output2)==1);
    fa= find(id_red1(id_output1)==0  &  id_red2(id_output2)==1);
    miss= find(id_red1(id_output1)==1  &  id_red2(id_output2)==0);
    cr= find(id_red1(id_output1)==0  &  id_red2(id_output2)==0);
    
    
    precision=length(hit)/(length(hit)+length(fa))*100;
    recall=length(hit)/(length(hit)+length(miss))*100;
    
    if plot_option==1;
        fprintf('- Precision %f , Recall %f ',precision, recall); 

        fprintf(' (Hit: %d , FA: %d, Miss: %d, CR: %d ) \n ',length(hit), length(fa), length(miss), length(cr));
    end
    end