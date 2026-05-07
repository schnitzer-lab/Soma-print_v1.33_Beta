function map_output=PreprocessMap(map);
    
        
    cutoff=mean(std(squeeze(sum(sum(map)))))+1*std(squeeze(sum(sum(map))));
    idx_filter=find(squeeze(sum(sum(map)))>cutoff);
    map(:,:,idx_filter)=zeros([size(map,1),size(map,2),length(idx_filter)]);
    map_output=map;
end