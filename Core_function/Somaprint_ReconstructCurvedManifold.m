function image_reconstruct=Somaprint_ReconstructCurvedManifold(centroid1,id_output3D,data_idz,image1,image2_tform)
%% Fitting manifold, Thie-plate smoothing spline

    center_out=centroid1(id_output3D,:);
    x=center_out(:,2);y=center_out(:,1);z=data_idz';
    
    p = 0.1;        % smoothing parameter
    
    [xq,yq] = meshgrid(1:size(image1,2),1:size(image1,1));
    X = [x'; y'];   % transpose!
    st = tpaps(X, z,p);
    fprintf(['- Fitting completed!Computing manifold... \n'])
    zt = fnval(st, [xq(:)'; yq(:)']);
    zt = reshape(zt, size(xq));
    
    % figure(3);clf;surf(zt), shading interp
    % hold on; colormap('hot');set(gca,'YDir','reverse')
    % scatter3(x,y,z,30,'r','filled');set(gca,'FontSize',40,'LineWidth',2);set(gca,'XTick',[],'YTick',[])
    figure(4);clf; % Plotting 2D manifo
    imagesc(zt);colorbar;colormap('hot');set(gca,'Visible','off')

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

    image_reconstruct=NormMultiImage(image2_manifold);


end