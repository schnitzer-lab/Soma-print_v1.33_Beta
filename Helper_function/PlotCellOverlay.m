function PlotCellOverlay(cell_images, c, lw, contour_thresh,id_cell)
    
if nargin < 4 || isempty(contour_thresh)
    contour_thresh = 0.3;
end

if nargin < 3 || isempty(lw)
    lw = 1;
end


if nargin < 2 || isempty(c)
    auto_color = 1;
else
    auto_color = 0;
end

if auto_color
    c = max(rand(1, 3), 0.2);
    c = c / max(c);
end

fontsize=0.1;

is_ndSparse = isa(cell_images, 'ndSparse');
% Smooth images
[h, w, k] = size(cell_images);

if nargin < 5 || isempty(lw)
    id_cell=1:k;
end



%cell_images_2d = reshape(cell_images, h * w, k);
%if is_ndSparse
%    cell_images_2d = full(cell_images_2d);
%end
%cell_images_2d = smooth_images(cell_images_2d, [h, w], 4, 0);
%if is_ndSparse
%    cell_images_2d = ndSparse(cell_images_2d);
%end
%cell_images = reshape(cell_images_2d, h, w, k);

for idx = 1:size(cell_images, 3)
    im = full(full(cell_images(:, :, idx)));
    max_val = max(max(im));
    b = bwboundaries(im > contour_thresh * max_val,'noholes');
    lens = cellfun(@length, b);
    if ~isempty(lens)
        b = b{find(lens == max(lens), 1)};
        hold on;
        plot((b(:,2)), (b(:,1)),'Color', c, 'LineWidth', lw) 
        hold off
    end
    if mod(idx,1000) == 999
        drawnow;
    end

    %idx=find((sp_input(:,:,id_cell2(i)))==max(max(sp_input(:,:,id_cell2(i)))));idx=idx(1);
    idx2=find(im==max(max(im)));idx2=idx2(1);
    y_postion=mod(idx2,h)+2*rand;
    x_postion=ceil(idx2/h)+2*rand;
    text(x_postion,y_postion,num2str(id_cell(idx)),'FontSize',fontsize,'Color',c);
end