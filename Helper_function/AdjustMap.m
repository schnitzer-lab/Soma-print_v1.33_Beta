function [map2_tform,tform]=AdjustMap(map2,map1,id_output);

if length(size(map1))==3;
   fprintf('- Adjust cell map w/ aligned cells ...')
   center1=Somaprint_ComputePeakXY(map1);
   center2=Somaprint_ComputePeakXY(map2);

   fp=center1(id_output(:,1),:);
   mp=center2(id_output(:,2),:);

   tform = fitgeotform2d(mp,fp,"affine");

   map2_tform=[];
    for i=1:size(map2,3)
         if mod(i,100)==0;fprintf([num2str(i),', ']);end    
         map2_tform(:,:,i)=imwarp(map2(:,:,i),tform,'OutputView',imref2d(size(map1(:,:,1)))); 
    end
    
    image_temp=imwarp(max(map2(:,:,id_output(:,2)),[],3),tform,'OutputView',imref2d(size(map1(:,:,1))));
    imshowpair(max(map1(:,:,id_output(:,1)),[],3),image_temp);
end

if length(size(map1))==2;
     fprintf('- Adjust centroids w/ aligned cells ...')
   fp=map1(id_output(:,1),:);
   mp=map2(id_output(:,2),:);
   tform = fitgeotform2d(mp,fp,"affine");
   map2_tform=transformPointsForward(tform, map2(:,[2,1]));% Reverse to (x,y) to apply Affine
end