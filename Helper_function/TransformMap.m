function map2_tform=TransformMap(map2,tform,image_size);
   fprintf(['- Generating transformed map, processing: ']);
    map2_tform=[];
    for i=1:size(map2,3)
         if mod(i,100)==0;fprintf([num2str(i),', ']);end    
         map2_tform(:,:,i)=imwarp(map2(:,:,i),tform,'OutputView',imref2d(image_size)); 
    end
    fprintf(['\n']);

end