function center1=readCentroid(ROIset)

    % This function reads ROIset (.zip) from ImageJ and generate centroid
    % postions (row, col)/(x,y)

    if exist('h_scale')==0;
        h_scale=1;
    end

    if exist('w_scale')==0;
        w_scale=1;
    end

    if exist('scale')==0;
        scale=1;
    end

    [sROI_1]=ReadImageJROI(ROIset);
    %fprintf('- Loading ROI ... ...  \n');
    
    count=0;r_cutoff=0;
    
    fprintf('- Processing ROIs:');
    map=[];
    for i=1:length(sROI_1)
        if mod(i,100)==0;fprintf([num2str(i),', ']);end    
           center1(i,:)=[mean(sROI_1{i}.vnRectBounds([1,3])),mean(sROI_1{i}.vnRectBounds([2,4]))];       
           roi_raw1(i,:)=sROI_1{i}.vnRectBounds;     
           % Recreate cell map
          
           %xl=(sROI_1{i}.vnRectBounds(3)-sROI_1{i}.vnRectBounds(1))*scale;
           %yl=(sROI_1{i}.vnRectBounds(4)-sROI_1{i}.vnRectBounds(2))*scale;

    end
    fprintf('\n');


end