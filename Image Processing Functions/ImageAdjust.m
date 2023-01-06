function AdjustedImg = ImageAdjust(img,adjustlow,adjusthigh,gamma)

AdjustedImg = zeros(size(img));
for i = 1:size(img,3)
    AdjustedImg(:,:,i) = imadjust(img(:,:,i),[adjustlow adjusthigh],[],gamma);
end

end