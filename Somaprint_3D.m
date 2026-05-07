
%% Soma-print 3D, V1.2, Nov 2025

% Schnitzer Lab, Stanford University
% Code: Xiaochen Sun, xcsun@stanford.edu

% Inroduction to Soma-print: A computational algorithm for large-scale automatic registration of in vivo cell maps to ex vivo cell
% maps 

% Input documents; 
%1) in vivo images
%2) in vivo cell maps (ImageJ ROIs)
%3) ex vivo images
%4) ex vivo cell maps (ImageJ ROIs)

% Output data:
% Matched cell IDs (data_id_cellout1,data_id_cellout2)

% Contact info for technical questions: xcsun@stanford.edu
%% ============== Step 1: Loading in vivo images ahd ROIs ========================================

% Read in vivo image and ROI
invivo_image='invivo_M1AVG_190um-zoom2-biColor_flip-------in vivo avg-composite.jpg';
invivo_ROI = 'invivo_M1AVG_190um-zoom2-biColor_flip-------in vivo avg-composite-RoiSet592.zip';
image1=imread(invivo_image);
[h1,w1]=size(image1);
map1=readROI(invivo_ROI,h1,w1);
centroid1=Somaprint_ComputePeak(map1);

%% Step 2: Loading ex vivo Z-stack images and ROIs

n_zstack=35;
filepath='C:\Users\Alignment\Documents\Codex\2026-05-04\Somaprint GUI\Somaprint_v1.32\Example_data\4_3D_M1_WangEtAl_Fig2\exvivo_Zstacks\';

for jjjj=1:n_zstack;
    fprintf(['- Loading Z-stack:',num2str(jjjj),',']);  
    filename=sprintf('Slice2_M1_invivo34_z12_RAW-------rotate4.5_z0%02d_c002.tif', jjjj);%%02d
    exvivo_image=[filepath,filename];   
    image2{jjjj}=imread(exvivo_image); 

    filename=sprintf('Slice2_M1_invivo34_z12_RAW-------rotate4.5_z0%02d_c001RoiSet.zip', jjjj);%%02d
    exvivo_ROI=[filepath,filename];   
    [centroid2{jjjj}]=readCentroid(exvivo_ROI);
end

%% Step 3: Affine transformtaion

jjjj=13; % Choose one of the central z-stackes 
[mp,fp] = cpselect(normimage(image2{jjjj},1),normimage(image1,1),Wait=true);


%% Apply affine transformationn to all ex vivo images and maps

tform = fitgeotform2d(mp,fp,"affine");
for jjjj=1:length(centroid2);
    image2_tform{jjjj}=imwarp(image2{jjjj},tform,'OutputView',imref2d(size(image1)));
    temp= transformPointsForward(tform, centroid2{jjjj}(:,[2,1]));% Reverse to (x,y) to apply Affine
    centroid2_tform{jjjj} =temp(:,[2,1]); % Reverse back the (y,x) / (row, col)
end

%% Soma-print 3D

option=GetDefautOption(3);
option.pixellength=672/1024; %LFOV, Rd1 2000, 1024 pixels

for jjjj=1:length(centroid2_tform);
  if isempty(centroid2_tform{z_idx(jjjj)})==1;continue;end
  fprintf('-================  Processing z-stack: %d  =================== \n', z_idx(jjjj));
  [score_weighted_3D{z_idx(jjjj)}]=Somaprint_Iterative(centroid1,centroid2_tform{z_idx(jjjj)},option);
end


%% Plotting results
clf;jjjj=14;

method=2;p_cutoff=0.05;iiii=length(score_weighted_3D{jjjj}); % 
[id_output1,id_output2,output_sumamry,output_option]=Somaprint_ComputeMatchStatistics(score_weighted_3D{jjjj}{iiii},centroid1,centroid2_tform{jjjj},method,p_cutoff,option.lambda,option.gmmfilter,2);
%fprintf('Matched cells, p-value: %d, lr: %d, post. prob.: %d \n',sum(output_sumamry(:,4)<0.05),sum(output_sumamry(:,5)<0.05),sum(output_sumamry(:,6)<0.05));


%% ------- 3D Z-stack processing -----
data_globalmapscore=zeros([length(centroid1),length(centroid2_tform)]);
for jjjj=1:length(centroid2_tform);
    if length(score_weighted_3D{jjjj})>=3;
        [id_output1,id_output2,score_temp,output_option]=Somaprint_ComputeMatchStatistics(score_weighted_3D{jjjj}{length(score_weighted_3D{jjjj})},centroid1,centroid2_tform{jjjj},2,.05,output_option.lambda,output_option.gmmfilter);
        if length(id_output2)>0;
            data_globalmapscore(id_output1,jjjj)=score_temp(1:length(id_output1),3);
        end
    else; 
        data_globalmapscore(:,jjjj)=0;
    end
end

% Plot sorted the scorses heatmaps
[temp,order]=max(data_globalmapscore(:,z_idx),[],2);[~,idx]=sort(order);
figure(2);clf;imagesc(data_globalmapscore(idx,:));colormap('hot');
set(gca,'Visible','off');colorbar;set(gca,'FontSize',25,'LineWidth',2)


%% ---- Plot Heat map and global map ----

idcell_zoutput=find(max(data_globalmapscore,[],2)>0);data_idz=[];
for i=1:length(data_idcell_zoutput);
    data_idz(i,:)=find(data_globalmapscore(data_idcell_zoutput(i),:)==max(data_globalmapscore(data_idcell_zoutput(i),:)));
end

% ---- GLobal map ----
plot_color=hot(1+round(length(centroid2_tform)*1.2));
score=max(data_globalmapscore,[],2);
figure(7);clf;
fprintf(['Total number of cell:', num2str(length(idcell_zoutput)),'\n'])
for i=1:length(idcell_zoutput);
    plot(centroid1(idcell_zoutput(i),2),centroid1(idcell_zoutput(i),1),'.','Color',plot_color(data_idz(i),:),'MarkerSize',20);hold on; % Need to reserse the X and Y!
end;
colorbar;colormap('hot')
set(gca,'LineWidth',3,'FontSize',25,'box','on','XTick',[],'YTick',[]);set ( gca, 'ydir', 'reverse');set(gca,'Visible','off')
plot_text=sprintf('Matched cells: %d, Z plane starting from z = %d to z = %d',length(idcell_zoutput), min(data_absz),max(data_absz));
annotation('textbox', [0.03, 0.01, 0.8, 0.05], 'String', plot_text,'FontSize', 12.5, 'HorizontalAlignment', 'center', 'EdgeColor', 'none');

%% Fitting manifold, Thie-plate smoothing spline

center_out=centroid1(idcell_zoutput,:);
x=center_out(:,2);y=center_out(:,1);z=data_idz';

p = 0.1;        % smoothing parameter

[xq,yq] = meshgrid(1:size(image1,2),1:size(image1,1));
X = [x'; y'];   % transpose!
st = tpaps(X, z,p);
fprintf(['- Fitting completed!Computing manifold... \n'])
zt = fnval(st, [xq(:)'; yq(:)']);
zt = reshape(zt, size(xq));

figure(3);clf;surf(zt), shading interp
hold on; colormap('hot');set(gca,'YDir','reverse')
scatter3(x,y,z,30,'r','filled');set(gca,'FontSize',40,'LineWidth',2);set(gca,'XTick',[],'YTick',[])
figure(4);clf; % Plotting 2D manifo
imagesc(zt);colorbar;colormap('hot')set(gca,'Visible','off')

%% Reconstruct image with manifold: single-channel, uniform thickness
z_thick=3;

for i=1:size(image1,1);
    for j=1:size(image1,2);
        image_temp=[];
        idx_min=round(zt(i,j))-floor(z_thick/2);
        idx_max=idx_min+z_thick-1;
        idx=idx_min:idx_max;

        for q=1:z_thick;
            image_temp(:,:,:,q)=image2_tform{idx(q)}(i,j,:);
        end
        image2_manifold(i,j,:)=max(image_temp,[],4);
    end
end








