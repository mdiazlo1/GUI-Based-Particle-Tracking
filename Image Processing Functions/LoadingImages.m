function [img, BitDepth] = LoadingImages(ImageFolder,ImageNames,frame_list,ImageFlip)

%Loading images for everything but a cine file
[~,~,ext] = fileparts(ImageNames{1});
if ext ~= ".cine"
    FirstImage = imread(fullfile(ImageFolder,ImageNames{1}));
    imgInfo = imfinfo(fullfile(ImageFolder,ImageNames{1}));
    BitDepth = imgInfo.BitDepth;

    img = zeros([size(FirstImage) numel(ImageNames)],class(FirstImage));

    if frame_list == 0
        frame_list = 0:numel(ImageNames)-1;
    end

    parfor i = 1:numel(frame_list)
        img(:,:,i) = imread(fullfile(ImageFolder,ImageNames{frame_list(i)+1}));
        if ImageFlip
            img(:,:,i) = (2^BitDepth-1) - img(:,:,i);
        end
    end
end

%Loading Images if it is a cine file



end