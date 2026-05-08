% =================== Soma-print 2D, v1.32, May 2026 =======================

% Registration of in vivo cell maps to z-stack ex vivo dataset

% Schnitzer Lab, Stanford University
% Contact info for technical questions: TRUFACT.info@gmail.com; Xiaochen Sun, xcsun@stanford.edu

%% ============== Step 1: Loading in vivo images ahd ROIs ========================================

% Read in vivo image and ROI
invivo_image='invivo_M1AVG_190um-zoom2-biColor_flip-------in vivo avg-composite.jpg';
invivo_ROI = 'invivo_M1AVG_190um-zoom2-biColor_flip-------in vivo avg-composite-RoiSet592.zip';
image1=imread(invivo_image);
[h1,w1]=size(image1);
map1=readROI(invivo_ROI,h1,w1);
centroid1=Somaprint_ComputePeak(map1);

%% (continuted) Loading ex vivo Z-stack images and ROIs

n_zstack=35;
filepath='C:\Users\Alignment\Documents\Codex\2026-05-04\Somaprint GUI\Somaprint_v1.32\Example_data\4_3D_M1_WangEtAl_Fig2\exvivo_Zstacks\';

for jjjj=1:n_zstack;
    fprintf(['- Loading Z-stack:',num2str(jjjj),',']);  
    filename=sprintf('Slice2_M1_invivo34_z12_RAW-------rotate4.5_z0%02d.tif', jjjj);%%02d
    exvivo_image=[filepath,filename];   
    image2{jjjj}=imread(exvivo_image); 

    filename=sprintf('Slice2_M1_invivo34_z12_RAW-------rotate4.5_z0%02d_c001RoiSet.zip', jjjj);%%02d
    exvivo_ROI=[filepath,filename];   
    [centroid2{jjjj}]=readCentroid(exvivo_ROI);
end

%% Step 2: Affine transformtaion

jjjj=11; % Choose one of the central z-stack 
[mp,fp] = cpselect(normimage(image2{jjjj},1),normimage(image1,1),Wait=true);

%% (continued) apply affine transformationn to all ex vivo images and maps

tform = fitgeotform2d(mp,fp,"affine");
for jjjj=1:length(centroid2);
    image2_tform{jjjj}=imwarp(image2{jjjj},tform,'OutputView',imref2d(size(image1)));
    temp= transformPointsForward(tform, centroid2{jjjj}(:,[2,1]));% Reverse to (x,y) to apply Affine
    centroid2_tform{jjjj} =temp(:,[2,1]); % Reverse back the (y,x) / (row, col)
end

%% Step 3: Soma-print for individual planes

option=GetDefaultOption(3);
option.pixellength=672/512;  % *Critical paremeter: um / pixel, adjust this according to your in vivo imaging data

for jjjj=1:length(centroid2_tform);
  if isempty(centroid2_tform{jjjj})==1;continue;end
  fprintf('-================  Processing z-stack: %d  =================== \n', jjjj);
  [score_weighted_3D{jjjj}]=Somaprint_Iterative(centroid1,centroid2_tform{jjjj},option);
end


%% (continued) Checking individual planes: plotting results
jjjj=15; % Choose the individual plane that you want to see the results
clf;method=2;p_cutoff=0.05;iiii=length(score_weighted_3D{jjjj}); % 
[id_output1,id_output2,output_sumamry,output_option]=Somaprint_ComputeMatchStatistics(score_weighted_3D{jjjj}{iiii},centroid1,centroid2_tform{jjjj},method,p_cutoff,option.lambda,option.gmmfilter,2);

%% Step 4: 3D processing acorss planes
[id_output3D,data_idz,data_globalmapscore]=Somaprint_Process3DSomaprint(centroid1,centroid2_tform,score_weighted_3D,option.lambda,option.gmmfilter)

%% Step 5: Reconstruct ex vivo images
image_reconstruct=Somaprint_ReconstructCurvedManifold(centroid1,id_output3D,data_idz,image1,image2_tform);







