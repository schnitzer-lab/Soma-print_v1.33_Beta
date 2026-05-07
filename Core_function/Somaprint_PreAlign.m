function [tform,id_cell1,id_cell2]=Somaprint_PreAlign(map1,map2,image1,image2)

% Compute pre-align registration cells 

    fprintf(['- Starting PreAlignment with Somaprint ........','\n']);
    %==============  Step 2: optiona 2, Pre-registration with Somaprint archor cells   ============== 
    data_vecpre=15;data_ppre=0.66;data_sigmapre=size(map1,1)/2;
    [data_scorewd_pre,data_score_pre]=Somaprint_ComputeSomaprint(map1,map2,data_vecpre,data_ppre,data_sigmapre);
    % Use 1% cutoff as high-confidence cells, note: use raw scores
    [~,~,id_cell1,id_cell2]=Somaprint_ComputeMatch(data_score_pre);

% visulization of anchor cells
    %subplot(2,1,1);imshowpair(max(map1(:,:,id_cell1),[],3),max(map2(:,:,id_cell2),[],3)); Title('Before transformation');

    % ...(continued) If happy with anchor points, proceed to transformation
    peak1=Somaprint_ComputePeak(map1);
    peak2=Somaprint_ComputePeak(map2);
    mp=peak2(id_cell2,[2,1]); % *** Note that the (h,w) coordiante correspond to (y,x) when choosing points! 
    fp=peak1(id_cell1,[2,1]);
    tform = fitgeotform2d(mp,fp,"affine");
    %subplot(2,1,2);imshowpair(max(map1(:,:,id_cell1),[],3),imwarp(max(map2(:,:,id_cell2),[],3),tform,'OutputView',imref2d(size(image2))));
    %Title('After affine transformation');

end