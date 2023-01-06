function AdjustedImg = ImageAdjust(img,adjustlow,adjusthigh,gamma)
classtype = class(img(:,:,1));
AdjustedImg = zeros(size(img),classtype);
for i = 1:size(img,3)
    AdjustedImg(:,:,i) = imadjust(img(:,:,i),[adjustlow adjusthigh],[],gamma);
end

end