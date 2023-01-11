function SharpenedImg = ImageSharpening(img,Radius,Amount,Threshold)
classtype = class(img(:,:,1));
SharpenedImg = zeros(size(img),classtype);
parfor i = 1:size(img,3)
    SharpenedImg(:,:,i) = imsharpen(img(:,:,i),"Radius",Radius,"Amount",Amount,"Threshold",Threshold);
end

end