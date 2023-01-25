function SharpenedImg = ImageSharpening(img,Radius,Amount,Threshold,fig)
if nargin < 5
    fig = uifigure;
end

  d = uiprogressdlg(fig,'Title','Please Wait','Message','Sharpening Images'...
        ,'Indeterminate','on');
  drawnow
classtype = class(img(:,:,1));
SharpenedImg = zeros(size(img),classtype);
parfor i = 1:size(img,3)
    SharpenedImg(:,:,i) = imsharpen(img(:,:,i),"Radius",Radius,"Amount",Amount,"Threshold",Threshold);
end
close(d)

end