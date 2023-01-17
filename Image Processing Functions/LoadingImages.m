function [img, BitDepth] = LoadingImages(ImageFolder,suffix,frame_list,ImageFlip,fig)
if nargin == 4
    fig = uifigure;
end
  d = uiprogressdlg(fig,'Title','Please Wait','Message','Loading Images'...
        ,'Indeterminate','on');
  drawnow
%% Getting Image directories and cropping for only frame_list specified
filelist = dir([ImageFolder filesep '*' suffix]);
ImageNames = {filelist.name}; clearvars filelist
[~,~,ext] = fileparts(ImageNames{1});
ImgNum = regexp(ImageNames,'\d*','Match');

if frame_list == 0
    frame_list = 0:numel(ImageNames)-1;
end

ImgNum = cell2mat(cellfun(@str2double,ImgNum,'UniformOutput',false));
[~,idx] = intersect(ImgNum,frame_list);
if isempty(idx)
    errordlg('frame_list is outside of image range')
end

%% Loading images for everything but a cine file

if ext ~= ".cine"
    FirstImage = imread(fullfile(ImageFolder,ImageNames{1}));
    imgInfo = imfinfo(fullfile(ImageFolder,ImageNames{1}));
    BitDepth = imgInfo.BitDepth;

    img = zeros([size(FirstImage) numel(idx)],class(FirstImage));

    parfor i = 1:numel(idx)
        img(:,:,i) = imread(fullfile(ImageFolder,ImageNames{idx(i)}));
        if ImageFlip
            img(:,:,i) = (2^BitDepth-1) - img(:,:,i);
        end
    end
end
close(d)

%Loading Images if it is a cine file



end