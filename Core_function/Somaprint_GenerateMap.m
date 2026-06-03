function [map1,map2,image1,image2,image2_multi]=Somaprint_GenerateMap(invivo_image,exvivo_image,invivo_ROI,exvivo_ROI,run_norm);

%% ============== Step 1: Loading in vivo and ex vivo images + ROIs ========================================
if exist('run_norm')==0;
    run_norm=0; % Optional: if normalize in vivo image to the size of ex vivo images 
end

fprintf(['- Welcome to Soma-print : ) \n']);

fprintf('-----------------------  Step 1: Loading ROIs and images --------------------- \n')

%addpath(genpath('E:\Matlab_code'));

image1=imread(invivo_image);

info = imfinfo(exvivo_image);nPages = numel(info);
if nPages>1;
    for k = 1:nPages
        image2_multi(:,:,k) = imread(exvivo_image, k, 'Info', info);
    end
    image2=max(image2_multi,[],3);
else
    image2=imread(exvivo_image);
    image2_multi=image2;
end
% Read ex vivo ROIs
fprintf('- 1.1) Read ex vivo ROIs:  \n');
[h2]=size(image2,1);[w2]=size(image2,2);

h_scale=100;w_scale=100;scale=0.5;
map2=readROI(exvivo_ROI,h2,w2,h_scale,w_scale,scale);

% Read in vivo ROIs
fprintf('- 1.2) Read in vivo ROIs:  \n');
h1=size(image1,1);w1=size(image1,2);

h_scale=100;w_scale=100; % Origianl size of images
if run_norm==1;
    h_scale=round(h2/h1*100);w_scale=round(h2/h1*100);scale=0.75; % Optional: rescale in vivo images and ROIs to ex vivo images and ROIs
    image1=resample(resample(double(image1),h_scale,100),w_scale,100,'Dimension',2);
end
map1=readROI(invivo_ROI,h1,w1,h_scale,w_scale,scale);
image1=imread(invivo_image);

figure(1);clf;
fprintf('- 1.3) Please wait: now generating images with ROIs .... ... \n')
subplot(2,1,1);imagesc(normimage(image1));PlotCellOverlay(map1,[0 0.7 0]);colormap('bone')
subplot(2,1,2);imagesc(normimage(image2));PlotCellOverlay(map2,[.7 0 .7]);colormap('bone')

end