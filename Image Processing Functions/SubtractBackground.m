% function SubtractBackground(img,frameskip,rollingwindow)
classtype = class(img(:,:,1));
rollingwindow = 0;
frameskip = 1;
if rollingwindow
    for i = 1:rollingwindow/2:size(img,3)
        if i<rollingwindow/2+1
            %Forward averaging
            img_bg = mean(double(img(:,:,1:frameskip:i+rollingwindow/2)),3)

            img(:,:,i:i+rollingwindow/2) = double(img(:,:,i:i+rollingwindow/2))-img_bg
        elseif i>size(img,3)-rollingwindow
            %Backward averaging
            img_bg = mean(double(img(:,:,i-rollingwindow/2:frameskip:size(img,3))),3);

            img(:,:,i:size(img,3)) = double(img(:,:,i:size(img,3)))-A_bg;
        else
            %Central averaging
            img_bg = mean(img(:,:,i-rollingwindow/2:i+rollingwindow/2),3);

            img = double(img(:,:,i-rollingwindow/2:i+rollingwindow/2)-A_bg,3)
        end
    end
else
    csum = sum(double(img(:,:,1:frameskip:size(img,3))),3);
    img_bg = csum./numel(img);
%     img_bg = mean(double(img(:,:,1:frameskip:size(img,3))),3);
    img = double(img)-img_bg;
end
clearvars img_bg
img = cast(img,classtype);

% end