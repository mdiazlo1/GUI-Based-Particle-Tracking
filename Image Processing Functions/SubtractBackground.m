% function SubtractBackground(img,frameskip,rollingwindow)
classtype = class(img(:,:,1));
rollingwindow = 0;
if rollingwindow
    for i = 1:rollingwindow/2:size(img,3)
        if i<rollingwindow/2+1
            %Forward averaging
            img_bg = mean(double(img(:,:,1:i+rollingwindow/2)),3)

            img(:,:,i:i+rollingwindow/2) = double(img(:,:,i:i+rollingwindow/2))-img_bg
        elseif i>size(img,3)-rollingwindow
            %Backward averaging
            img_bg = mean(double(img(:,:,i-rollingwindow/2:size(img,3))),3);

            img(:,:,i:size(img,3)) = double(img(:,:,i:size(img,3)))-A_bg;
        else
            %Central averaging
            img_bg = mean(img(:,:,i-rollingwindow/2:i+rollingwindow/2),3);

            img = double(img(:,:,i-rollingwindow/2:i+rollingwindow/2),3)
        end
    end
else
    csum = sum(double(img),3);
    img_bg = csum./numel(img);
    img = cast(double(img)-img_bg,classtype);
end

% img = cast(double(img)-img_bg,classtype);

% end