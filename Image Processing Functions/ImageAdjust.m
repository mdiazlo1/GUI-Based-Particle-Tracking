function AdjustedImg = ImageAdjust(img,adjustlow,adjusthigh,gamma,fig)
if nargin < 5
    fig = uifigure;
end

d = uiprogressdlg(fig,'Title','Please Wait','Message','Adjusting Image Lighting'...
    ,'Indeterminate','on');
drawnow
classtype = class(img(:,:,1));
AdjustedImg = zeros(size(img),classtype);
parfor i = 1:size(img,3)
    AdjustedImg(:,:,i) = imadjust(img(:,:,i),[adjustlow adjusthigh],[],gamma);
end
close(d)
end