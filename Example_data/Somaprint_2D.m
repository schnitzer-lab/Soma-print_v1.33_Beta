% =================== Soma-print 2D, v1.32, May 2026 =======================

% Inroduction to Soma-print: A computational algorithm for large-scale automatic registration of in vivo cell maps to ex vivo cell
% maps 

% Input documents; 
%1) in vivo images
%2) in vivo cell maps (ImageJ ROIs)
%3) ex vivo images
%4) ex vivo cell maps (ImageJ ROIs)

% Output data:
% Matched cell IDs (data_id_cellout1,data_id_cellout2)


% MATLAB tookbox that you may need (depending on your MATLAB version, so try install this if some functions are missing)
% - Computer Vision Toolbox                             
% - Image Processing Toolbox                              
% - Signal Processing Toolbox                            
% - Statistics and Machine Learning Toolbox  

% =======================================================================
% Schnitzer Lab, Stanford University
% Contact info for technical questions: TRUFACT.info@gmail.com; Xiaochen Sun, xcsun@stanford.edu

%% Step 1: generate maps from ImageJ

% User action 1: Go to your folder with in vivo & ex vivo ROIs and images
% If using EXRTRACRT cell maps, just to Step 2

[invivo_image,exvivo_image,invivo_ROI,exvivo_ROI]=AutoLoadFiles;
    
% invivo_image='S1H1AVG_240um-zoom2-biColor_flip.tif';
% exvivo_image='S1H1_confocal_slice2_match_invivo240.tif';
% invivo_ROI = 'S1H1AVG_240um-zoom2-biColor_flip_RoiSet676.zip';
% exvivo_ROI='S1H1_confocal_slice2_match_invivo240-ROIset_extra3 all DAPI.zip'; 

% Generate scaled map2 (ex vivo) and scaled map1 (in vivo)
[map1,map2,image1,image2]=Somaprint_GenerateMap(invivo_image,exvivo_image,invivo_ROI,exvivo_ROI);

%% Step 2: Mannual anchor cells for pre-alignment

%  User action 3: Select >=3 anchor points, and then close the window 
[tform,map2_tform,image2_tform]=Somaprint_MannualTransformation(image1,image2,map1,map2);


%% Step 3: Soma-print, iterative agorith
option=GetDefaultOption;
option.pixellength=672/1024;   % *Critical paremeter: um / pixel, adjust this according to your in vivo imaging data

[score_weighted,id_map1,id_map2,score_raw]=Somaprint_Iterative (map1,map2_tform,option);

%% Step 4: Plot final results: Statistics, output matched cell IDs
figure(1);clf;plot_data=score_weighted;jjjj=1;iiii=length(plot_data); plot_option=2; %
[id_output1,id_output2,output_sumamry,output_option]=Somaprint_ComputeMatchStatistics(plot_data{jjjj,iiii},map1,map2_tform,[],[],[],[],plot_option);

% id_output1: ID for in vivo cells matched
% id_output2: ID for ex vivo cells matched
% output_summary: cells ID with Somaprint scores, with 3 statistics: 1) post. probs, 2) Liklihood ratio, 3) p-value