function [tform,map2_tform,image2_tform,mp, fp]=Somaprint_MannualTransformation(image1,image2,map1,map2,tform);
    % ============== Step 2: option 1, Pre-registration with manual anchor points ========================================
    fprintf(['------------------------------------------------------------------------------------------\n']);
    fprintf('----------------------  Step 2: Image pre-alignment ----------------  \n')
    fprintf(['------------------------------------------------------------------------------------------\n']);
    
    if exist('tform')==0;

        %[data_tform,id_cell1,id_cell2]=Somaprint_PreAlign(map1,map2);
        %[mp,fp] = cpselect(image2,image1,Wait=true);
        [mp,fp] = cpselect(normimage(image2,2),normimage(image1,2),Wait=true);
        tform = fitgeotform2d(mp,fp,"affine");
    end

    image2_tform=imwarp(image2,tform,'OutputView',imref2d(size(image1)));
    fprintf(['- Transformation calculated. Now generating transformed Map 2 for all cells, processing: ']);
    map2_tform=[];
    for i=1:size(map2,3)
         if mod(i,100)==0;fprintf([num2str(i),', ']);end    
         map2_tform(:,:,i)=imwarp(map2(:,:,i),tform,'OutputView',imref2d(size(image1))); 
    end
    fprintf(['\n']);
    
    figure(2);clf;
    fprintf('- Please wait: generating images with transformed ROIs .... ... \n')
    %subplot(2,2,1);imshowpair(max(map1(:,:,id_cell1),[],3),max(map2(:,:,id_cell2),[],3)); title('Before transformation, anchor cells');
    %subplot(2,2,3);imshowpair(max(map1(:,:,id_cell1),[],3),imwarp(max(map2(:,:,id_cell2),[],3),data_tform,'OutputView',imref2d(size(image2))));title('After transformation, anchor cells')
    subplot(2,1,1);imshowpair(max(map1(:,:,:),[],3),max(map2(:,:,:),[],3));title('Before transformation, all cells');
    subplot(2,1,2);imshowpair(max(map1(:,:,:),[],3),max(map2_tform(:,:,:),[],3));title('After transformation, all cells')

end