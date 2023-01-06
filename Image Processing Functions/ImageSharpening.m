function SharpenedImg = ImageSharpening(img,Radius,Amount,Threshold)

SharpenedImg = zeros(size(img));
for i = 1:size(img,3)
    SharpenedImg(:,:,i) = imsharpen(img(:,:,i),"Radius",Radius,"Amount",Amount,"Threshold",Threshold);
end

end