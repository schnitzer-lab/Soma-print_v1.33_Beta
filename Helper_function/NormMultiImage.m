function image_output=NormMultiImage(image1);
    for i=1:size(image1,3);
        image_output(:,:,i)=mat2gray(image1(:,:,i));
    end
end