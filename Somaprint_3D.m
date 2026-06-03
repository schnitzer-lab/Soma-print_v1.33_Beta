% =================== Soma-print 3D, v1.33, Jun 2026 =======================

% Registration of in vivo cell maps to 3D/multi-plane Z-stack ex vivo dataset

% =======================================================================
% Schnitzer Lab, Stanford University
% Contact info for technical questions:Xiaochen Sun, xcsun@stanford.edu or TRUFACT.info@gmail.com; 

%% ============== Step 1: Loading in vivo images and ROIs ========================================

% [***User action***] 
% - 0) ALways add the entire Soma-print package to your MATLAB search path first
% - 1) Go to your folder with in vivo ROIs and images
% - 2) Specify the files below 
% - 3) then click "Run Section"

% Read in vivo image and ROI
invivo_image='Example_data\4_3D_M1_WangEtAl_Fig2\invivo_M1AVG_190um-zoom2-biColor_flip-------in vivo avg-composite.jpg';
invivo_ROI = 'Example_data\4_3D_M1_WangEtAl_Fig2\invivo_M1AVG_190um-zoom2-biColor_flip-------in vivo avg-composite-RoiSet592.zip';

image1=imread(invivo_image);
[h1,w1]=size(image1);map1=readROI(invivo_ROI,h1,w1);
centroid1=Somaprint_ComputePeak(map1); % Compute centroid from in vivo maps

%% ============== Step 2: Loading ex vivo Z-stack images ahd ROIs ========================================

% [***User action***] 
% - 1) Go to your folder with ex vivo ROIs and images
% - 2) Specify the files name, number of stacks (n_zstacks)
% - 3) then click "Run Section"

n_zstack=20;

filepath='Example_data\4_3D_M1_WangEtAl_Fig2\';

for jjjj=1:n_zstack;
    fprintf(['- Loading Z-stack:',num2str(jjjj),',']);  
    exvivo_image=sprintf('Slice2_M1_invivo34_z12_RAW-------rotate4.5_z0%02d.tif', jjjj);%%02d
    image2{jjjj}=imread([filepath,exvivo_image]); 

    exvivo_ROI=sprintf('Slice2_M1_invivo34_z12_RAW-------rotate4.5_z0%02d_c001RoiSet.zip', jjjj);%%02d  
    [centroid2{jjjj}]=readCentroid([filepath,exvivo_ROI]);
end

%% ============== Step 3: Transformation w/ one of the ex vivo planes ==============

% [***User action***] 
% - 1) Specify one of the central z-stacks for pre-alignment (z)
% - 2) click "Run Section"

z=10; % Choose one of the central z-stack 
[mp,fp] = cpselect(normimage(image2{z},1),normimage(image1,1),Wait=true);

tform = fitgeotform2d(mp,fp,"affine");
for jjjj=1:length(centroid2);
    image2_tform{jjjj}=imwarp(image2{jjjj},tform,'OutputView',imref2d(size(image1)));
    temp= transformPointsForward(tform, centroid2{jjjj}(:,[2,1]));% Reverse to (x,y) to apply Affine
    centroid2_tform{jjjj} =temp(:,[2,1]); % Reverse back the (y,x) / (row, col)
end

%% ==============  Step 4: Soma-print for individual planes ============== 
% [***User action***] 
% - 1) Specificy the pixel size below: option.pixellength
% - 2) click "Run Section"

option=GetDefaultOption(3);
option.pixellength=672/512;  % *Critical parameter: um / pixel, adjust this according to your in vivo imaging data

for jjjj=1:length(centroid2_tform);
  if isempty(centroid2_tform{jjjj})==1;continue;end
  fprintf('-================  Processing z-stack: %d  =================== \n', jjjj);
  [score_weighted_3D{jjjj}]=Somaprint_Iterative(centroid1,centroid2_tform{jjjj},option);
end
%% ==============  Step 5: Check results for individual planes ============== 

% [***User action***] 
% - 1) Specificy the pixel size below: option.pixellength
% - 2) click "Run Section"

z=15; % Choose the individual plane that you want to see the results
figure(1);clf;
[id_output1,id_output2,output_sumamry,output_option]=Somaprint_ComputeMatchStatistics(score_weighted_3D{z}{length(score_weighted_3D{z})},centroid1,centroid2_tform{z},[],[],option.lambda,option.gmmfilter,2);

%% ==============  Step 6: Processing across Z-stacks ============== 

% [***User action***] 
% - Just click "Run Section"

[id_output3D,data_idz,data_globalmapscore]=Somaprint_Process3DSomaprint(centroid1,centroid2_tform,score_weighted_3D,option.lambda,option.gmmfilter);
image_reconstruct=Somaprint_ReconstructCurvedManifold(centroid1,id_output3D,data_idz,image1,image2_tform);







