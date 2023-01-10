% function ImageProcessingAndTrackingCalling(Settings)
image_range = 0;
addpath(genpath('.'))
load('.\Testing\Settings.mat')
inputnames = "Z:\ONR-Deposition\Channel Experiments\Raw Data\2022_06_02\T2\R3\C1\*.tif";

filelist = dir(inputnames);
% ImageDir = zeros(1,numel(inputnames),'str');
ImageDir = cell(1,numel(filelist));
for i = 1:numel(filelist)
    ImageDir{i} = fullfile(filelist(i).folder,filelist(i).name);
end

