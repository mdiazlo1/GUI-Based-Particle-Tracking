function AdjustedImg = ImageAdjust(img,adjustlow,adjusthigh,gamma,fig)
d = uiprogressdlg(fig,'Title','Please Wait','Message','Subtracting Background'...
    ,'Indeterminate','on');
drawnow
classtype = class(img(:,:,1));
AdjustedImg = zeros(size(img),classtype);
parfor i = 1:size(img,3)
    AdjustedImg(:,:,i) = imadjust(img(:,:,i),[adjustlow adjusthigh],[],gamma);
end
close(d)
end