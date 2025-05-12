function [img, BitDepth] = LoadImages(ImageFolder,suffix,bitshift,frame_list,ImageFlip,fig)
%[img, BitDepth] = LoadImages(ImageFolder,suffix,bitshift,frame_list,ImageFlip,fig)
if nargin < 6
    fig = uifigure;
end
d = uiprogressdlg(fig,'Title','Please Wait','Message',['Loading Images ' num2str(frame_list(1)) ' to ' num2str(frame_list(end))]...
    ,'Indeterminate','on');
drawnow
%% Getting Image directories and cropping for only frame_list specified
filelist = dir([ImageFolder filesep '*' suffix]);
ImageNames = {filelist.name}; clearvars filelist


%% Loading images for everything but a cine file

if suffix ~= ".cine"
    %Obtaining directories
    ImgNum = regexp(ImageNames,'\d*','Match');

    if frame_list == 0
        frame_list = 0:numel(ImageNames)-1;
    end

    ImgNum = cell2mat(cellfun(@str2double,ImgNum,'UniformOutput',false));
    [~,idx] = intersect(ImgNum,frame_list);
    if isempty(idx)
        errordlg('frame_list is outside of image range')
    end
    %Loading images
    FirstImage = imread(fullfile(ImageFolder,ImageNames{1}));
    imgInfo = imfinfo(fullfile(ImageFolder,ImageNames{1}));
    BitDepth = imgInfo.BitDepth;

    img = zeros([size(FirstImage) numel(idx)],class(FirstImage));

    parfor i = 1:numel(idx)
        img(:,:,i) = imread(fullfile(ImageFolder,ImageNames{idx(i)})).*2^bitshift;
%         if ImageFlip
%             img(:,:,i) = (2^BitDepth-1) - img(:,:,i);
%         end
    end
    %% Loading Images if it is a cine file
else
    LoadPhantomLibraries();
    RegisterPhantom(true)
       ImageNames = flip(sort(ImageNames));
       [~,FirstImage] = ReadCineFileImage([ImageFolder filesep ImageNames{1}],frame_list(1),false);
       BitDepth = 16;
       img = zeros([size(FirstImage) numel(frame_list)],class(FirstImage));
       FirstImgNextCine = zeros(1,numel(ImageNames));
    for i = 1:numel(ImageNames)
        [HRES,cineHandle] = PhNewCineFromFile([ImageFolder filesep ImageNames{i}]);
        if(HRES<0)
            [message] = PhGetErrorMessage(HRES);
            error(['Cine Handle Creation error: ' message])
        end
        pFirstIm = libpointer('int32Ptr',0);
        PhGetCineInfo(cineHandle,PhFileConst.GCI_FIRSTIMAGENO,pFirstIm);
        pImCount = libpointer('uint32Ptr',0);
        PhGetCineInfo(cineHandle,PhFileConst.GCI_IMAGECOUNT,pImCount);
        LastFrame = int32(double(pFirstIm.Value)+double(pImCount.Value)-1);

        [Common,idx] = intersect(pFirstIm.Value:LastFrame,frame_list);
        CineFile = ImageNames{i};
        if isempty(Common)
            continue
        end
        
        for j = FirstImgNextCine(i)+1:numel(Common)
            [~,img(:,:,j)] = ReadCineFileImage([ImageFolder filesep CineFile],Common(j),false);
            img(:,:,j) = img(:,:,j).*2^bitshift;
        end
        FirstImgNextCine(i+1) = LastFrame;

    end

    UnregisterPhantom();
    UnloadPhantomLibraries();
if ImageFlip
    img = imcomplement(img);
end


end





close(d)
end