% =================== Soma-print 2D, v1.33, June 2026 =======================

% A computational algorithm for large-scale cell registration between in vivo and ex vivo images

% Input: 
% 1) in vivo images
% 2) in vivo cell maps (ImageJ ROIs)
% 3) ex vivo images
% 4) ex vivo cell maps (ImageJ ROIs)

% Output: 
% 1) Matched cell IDs
% 2) Statistics (posterior probability, p-value, likelihood ratio) for all potential matches 


% [***** MATLAB tookbox that you may need] (depending on your MATLAB version, so try install this if some functions are missing)]
% - Computer Vision Toolbox                             
% - Image Processing Toolbox                              
% - Signal Processing Toolbox                            
% - Statistics and Machine Learning Toolbox  

% =======================================================================

% Schnitzer Lab, Stanford University
% Contact info for technical questions:Xiaochen Sun, xcsun@stanford.edu or TRUFACT.info@gmail.com; 

%% ========  Step 1: Read in images and cell maps ======== 

% [***User action***] 
% - 0) ALways add the entire Soma-print package to your MATLAB search path first
% - 1) Go to your folder with in vivo & ex vivo ROIs and images
% - 2) Specify the files below or automatically load if your files are named with "invivo" and 'exvivo'; 
% - 3) then click "Run Section"

invivo_image='Example_data\1_S1350_2P\invivo_S1avg350um_flip_pixellength_1d31.tif';
exvivo_image='Example_data\1_S1350_2P\exvivo_confocal_max_rotate_crop_scale.tif';
invivo_ROI = 'Example_data\1_S1350_2P\invivo_all_RoiSet.zip';
exvivo_ROI='Example_data\1_S1350_2P\exvivo_confocal_all_RoiSet.zip';

%[invivo_image,exvivo_image,invivo_ROI,exvivo_ROI]=AutoLoadFiles;  % Load automatically 

% Generate scaled map2 (ex vivo) and scaled map1 (in vivo)
[map1,map2,image1,image2]=Somaprint_GenerateMap(invivo_image,exvivo_image,invivo_ROI,exvivo_ROI);

%% ======== Step 2: Select anchor cells for pre-alignment ======== 

% [***User action***] 
% - click "Run Section, then select >=3 anchor points in the GUI, and then just close the window 

[tform,map2_tform,image2_tform,mp,fp]=Somaprint_MannualTransformation(image1,image2,map1,map2);


%% Step 3: ========  Soma-print, iterative agorith ======== 

% [***User action***] 
% - 1) Specificy the pixel size below: option.pixellength
% - 2) click "Run Section"

option=GetDefaultOption;
option.pixellength=672/1024;   % *Critical parameter: um / pixel, adjust this according to your in vivo imaging data

[score_weighted,id_map1,id_map2,score_raw]=Somaprint_Iterative (map1,map2_tform,option);

%% ======== Step 4: Plot final results: Statistics, output matched cell IDs ======== 

% [***User action***] 
% - click "Run Section"

figure(1);clf;
plot_option=1; % Quick plots with 4 panne;s
%plot_option=2; % Final plots with 6 pannels
[id_output1,id_output2,output_sumamry]=Somaprint_ComputeMatchStatistics(score_weighted{1,length(score_weighted)},map1,map2_tform,[],[],[],[],plot_option);

% --- Output files: 
% 1) id_output1: ID for in vivo cells matched
% 2) id_output2: ID for ex vivo cells matched
% 3) output_summary: cells ID with Somaprint scores, with 3 statistics: 1) post. probs, 2) Liklihood ratio, 3) p-value