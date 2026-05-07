function [invivo_image,exvivo_image,invivo_ROI,exvivo_ROI]=AutoLoadFiles;
    file=dir;
    invivo_image='';
    exvivo_image='';
    invivo_ROI='';
    exvivo_ROI='';
    
    for i=1:length(file);
        if file(i).isdir;continue;end
        filename=file(i).name;
        filename_lower=lower(filename);

        if contains(filename_lower,'invivo') && contains(filename_lower,'.zip') && isempty(invivo_ROI);
            invivo_ROI=filename;
        end

        if contains(filename_lower,'exvivo') && contains(filename_lower,'.zip') && isempty(exvivo_ROI);
            exvivo_ROI=filename;
        end

        if contains(filename_lower,'invivo') && contains(filename_lower,'.tif') && isempty(invivo_image);
            invivo_image=filename;
        end

        if contains(filename_lower,'exvivo') && contains(filename_lower,'.tif') && isempty(exvivo_image);
            exvivo_image=filename;
        end
    end

    if isempty(invivo_image) || isempty(exvivo_image) || isempty(invivo_ROI) || isempty(exvivo_ROI);
        error(['Auto-load failed. Make sure the current folder contains files with names including ', ...
            '"invivo" or "exvivo", and extensions ".tif" / ".zip".']);
    end

    fprintf('- Auto-load completed in folder: %s\n',pwd);
    fprintf('- In vivo image: %s\n',invivo_image);
    fprintf('- In vivo ROI: %s\n',invivo_ROI);
    fprintf('- Ex vivo image: %s\n',exvivo_image);
    fprintf('- Ex vivo ROI: %s\n',exvivo_ROI);
end