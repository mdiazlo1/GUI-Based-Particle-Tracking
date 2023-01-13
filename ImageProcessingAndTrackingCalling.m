function [vtracks,tracks] = ImageProcessingAndTrackingCalling(settings,inputnames,SaveDirec,frame_list)
% frame_list = 0;

addpath(genpath('.'))
% load('.\Testing\Settings.mat')
% inputnames = "E:\PIV Data\Processed Data\2022_06_23\T2\HistMatchImages\R1\*.tiff";
% SaveDirec = 'E:\PIV Data\Processed Data\2022_06_23\T2\PTVGasPhase\R1';

filelist = dir(inputnames);

ImageNames = {filelist.name}; ImageFolder = filelist(1).folder; clearvars filelist
img = LoadingImages(ImageFolder,ImageNames,0,settings.FlipLighting);

%Image Contrast Adjustment
img = ImageAdjust(img,settings.adjustlow,settings.adjusthigh,settings.gamma);

%Image Sharpening
img = ImageSharpening(img,settings.SharpenRadius,settings.SharpenAmount,settings.SharpenThreshold);

%Saving Images
if frame_list == 0
    frame_list = 0:numel(ImageNames)-1;
end
parfor i = 1:numel(frame_list)
    imwrite(img(:,:,i),[SaveDirec filesep 'data_' sprintf('%04d',frame_list(i)) '.tif'])
end

%Tracking
[vtracks,~,~,~,tracks] = PredictiveTracker([SaveDirec '\*.tif'],settings.BinaryThresh,settings.max_disp,[],settings.area_lim);



end



