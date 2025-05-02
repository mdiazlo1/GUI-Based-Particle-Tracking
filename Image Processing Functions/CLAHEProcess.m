function NewImg = CLAHEProcess(img,fig)


if nargin < 2
    fig = uifigure;
end

  d = uiprogressdlg(fig,'Title','Please Wait','Message','Contrast adjustment'...
        ,'Indeterminate','on');
  drawnow
classtype = class(img(:,:,1));
NewImg = zeros(size(img),classtype);
parfor i = 1:size(img,3)
    NewImg(:,:,i) = adapthisteq(img(:,:,i));
end
close(d)
end