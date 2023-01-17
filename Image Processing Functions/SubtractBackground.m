function img = SubtractBackground(img,frameskip,rollingwindow,fig)
classtype = class(img(:,:,1));
% rollingwindow = 0;
% frameskip = 1;
if nargin == 3
    fig = uifigure;
end

if rollingwindow
    d = uiprogressdlg(fig,'Title','Please Wait','Message','Subtracting Background');
    for i = 1:rollingwindow/2+1:size(img,3)
        d.Value = i/size(img,3);
        if i<=rollingwindow/2+2
            %Forward averaging
            img_bg = mean(double(img(:,:,i:frameskip:i+rollingwindow/2)),3);

            img(:,:,i:i+rollingwindow/2) = cast(double(img(:,:,i:i+rollingwindow/2))-img_bg,classtype);
        elseif i>size(img,3)-rollingwindow
            %Backward averaging
            img_bg = mean(double(img(:,:,i-rollingwindow/2:frameskip:size(img,3))),3);

            img(:,:,i:size(img,3)) = cast(double(img(:,:,i:size(img,3)))-img_bg,classtype);
        else
            %Central averaging
            img_bg = mean(img(:,:,i-rollingwindow/2:frameskip:i+rollingwindow/2),3);

            img(:,:,i-rollingwindow/2:i+rollingwindow/2) = cast(double(img(:,:,i-rollingwindow/2:i+rollingwindow/2))-img_bg,classtype);
        end
    end
else
    d = uiprogressdlg(fig,'Title','Please Wait','Message','Subtracting Background'...
        ,'Indeterminate','on');
    drawnow
    csum = sum(double(img(:,:,1:frameskip:size(img,3))),3);
    img_bg = csum./numel(img);
%     img_bg = mean(double(img(:,:,1:frameskip:size(img,3))),3);
    img = double(img)-img_bg;
    img = cast(img,classtype);
end
clearvars img_bg

close(d)

end