function imgBgSub = SubtractBackground(img,frameskip,rollingwindow,fig)
classtype = class(img(:,:,1));
% rollingwindow = 0;
% frameskip = 1;
if nargin == 3
    fig = uifigure;
end

if rollingwindow
    imgBgSub = zeros(size(img),class(img));
    d = uiprogressdlg(fig,'Title','Please Wait','Message','Subtracting Background');
    for i = 1:rollingwindow/2+1:size(img,3)
        d.Value = i/size(img,3);
        if i<rollingwindow/2+1
            %Forward averaging
            img_bg = mean(double(img(:,:,i:frameskip:i+rollingwindow)),3);

            imgBgSub(:,:,i:i+rollingwindow/2) = cast(double(img(:,:,i:i+rollingwindow/2))-img_bg,classtype);
        elseif i>size(img,3)-rollingwindow/2
            %Backward averaging
            img_bg = mean(double(img(:,:,i-rollingwindow/2:frameskip:size(img,3))),3);

            imgBgSub(:,:,i:size(img,3)) = cast(double(img(:,:,i:size(img,3)))-img_bg,classtype);
        else
            %Central averaging
            img_bg = mean(double(img(:,:,i-rollingwindow/2:frameskip:i+rollingwindow/2)),3);
            % BgTypical = cast(img_bg,classtype);

            imgBgSub(:,:,i:i+rollingwindow/2) = cast(double(img(:,:,i:i+rollingwindow/2))-img_bg,classtype);
        end
    end
else
    d = uiprogressdlg(fig,'Title','Please Wait','Message','Subtracting Background'...
        ,'Indeterminate','on');
    drawnow
%     csum = sum(double(img(:,:,1:frameskip:size(img,3))),3);
%     img_bg = csum./numel(img);
    img_bg = mean(double(img(:,:,1:frameskip:size(img,3))),3);
    imgBgSub = double(img)-img_bg;
    clearvars -except imgBgSub classtype d
    imgBgSub = cast(imgBgSub,classtype);
    % BgTypical = cast(img_bg,classtype);
end
clearvars img_bg

close(d)

end