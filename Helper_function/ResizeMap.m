function map_output = ResizeMap(map,n);

    fprintf(['processing cell:',])

    for i=1:size(map,3);
        if mod(i,100)==0;fprintf([',',num2str(i)]);end
        map_output(:,:,i)=imresize(map(:,:,i),n);
    end
fprintf('\n');
end

