function map=readROI(ROIset,h1,w1,h_scale,w_scale,scale)

    % This function reads ROIset (.zip) from ImageJ and generate cell maps

    % ----- Input -----
    % ROIsets: '.zip' file
    % h1: hight/1st dimension of the image
    % w1: weight/2nd dimension of the image
    % (optional)h_scale: if needs to rescale h1
    % (optional)w_scale: if needs to rescale w1
    % (optional)scale: if needs to rescale the size of individual cell maps

    % Example code: map=readROI('ROIset.zip',1024, 1024);

    if exist('h_scale')==0;
        h_scale=100;
    end

    if exist('w_scale')==0;
        w_scale=100;
    end

    if exist('scale')==0;
        scale=1;
    end

    [sROI_1]=ReadImageJROI(ROIset);
    %fprintf('- Loading ROI ... ...  \n');
    
    count=0;r_cutoff=0;
    
    Somaprint_LogMessage('- Processing ROIs:',false);
    map=[];
    for i=1:length(sROI_1)
        if mod(i,100)==0;Somaprint_LogMessage([num2str(i),', '],false);end
           center1(i,:)=[mean(sROI_1{i}.vnRectBounds([1,3])),mean(sROI_1{i}.vnRectBounds([2,4]))];       
           roi_raw1(i,:)=sROI_1{i}.vnRectBounds;     
           % Recreate cell map
           filter=zeros(h1,w1);
           xl=(sROI_1{i}.vnRectBounds(3)-sROI_1{i}.vnRectBounds(1))*scale;
           yl=(sROI_1{i}.vnRectBounds(4)-sROI_1{i}.vnRectBounds(2))*scale;
           if xl/scale<r_cutoff && yl/scale<r_cutoff;continue;
           else; 
               count=count+1;
               t=-pi:0.01:pi;x=center1(i,1)+xl*cos(t);y=center1(i,2)+yl*sin(t);x=round(x);y=round(y);
               x(x<1)=1;y(y<1)=1;x(x>h1)=h1;y(y>w1)=w1;
               for j=min(x):max(x);
               temp=find(x==j);       
               filter(j,min(y(temp)):max(y(temp)))=1; end
             
                % Resample Map 2 to Map 1
               map(:,:,count)=resample(resample(filter(1:h1,1:w1),h_scale,100),w_scale,100,'Dimension',2);
               id(i)=count;
           end
    end
    Somaprint_LogMessage('');

    Somaprint_LogMessage(['- Initial ROIs:',num2str(length(sROI_1)),',Output ROIs:',num2str(size(map,3))]);

end
