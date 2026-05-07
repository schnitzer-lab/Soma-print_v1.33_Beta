function stats_output=ValidationCurve(output_sumamry,id_red1,id_red2);
    cutoff_list=[0.01 0.05, 0.1,.2 0.5];
    for i=1:length(cutoff_list);
    cutoff=cutoff_list(i);
    id_stats=6;id_output1_pv=output_sumamry(find(output_sumamry(:,id_stats)<cutoff),1);id_output2_pv=output_sumamry(find(output_sumamry(:,id_stats)<cutoff),2);
    id_stats=5;id_output1_lr=output_sumamry(find(output_sumamry(:,id_stats)<cutoff),1);id_output2_lr=output_sumamry(find(output_sumamry(:,id_stats)<cutoff),2);
    id_stats=4;id_output1_pp=output_sumamry(find(output_sumamry(:,id_stats)<cutoff),1);id_output2_pp=output_sumamry(find(output_sumamry(:,id_stats)<cutoff),2);
    
    stats_pv(i,3)=length(id_output1_pv);
    stats_lr(i,3)=length(id_output1_lr);
    stats_pp(i,3)=length(id_output1_pp);
    
    [stats_pv(i,1),stats_pv(i,2)]=Somaprint_Validation(id_output1_pv,id_output2_pv,id_red1,id_red2,0);
    [stats_lr(i,1),stats_lr(i,2)]=Somaprint_Validation(id_output1_lr,id_output2_lr,id_red1,id_red2,0);
    [stats_pp(i,1),stats_pp(i,2)]=Somaprint_Validation(id_output1_pp,id_output2_pp,id_red1,id_red2,0);
    end
    stats_output=[stats_pp,stats_lr,stats_pv];
end