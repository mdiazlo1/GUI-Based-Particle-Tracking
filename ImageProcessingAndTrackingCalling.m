function [vtracks,tracks] = ImageProcessingAndTrackingCalling(settings,Imagefolder,ImageSuffix,frame_list,SplitData,SaveDirec)
%[vtracks,tracks] = ImageProcessingAndTrackingCalling(settings,Imagefolder,ImageSuffix,frame_list,SplitData,SaveDirec)
% For this function to work you have to specify a frame_list. Settings.mat file
%can be generated from the GUI for settings. SplitData value is how many
%times you want to split the frame_list so you don't overload the ram.
if SplitData
    SizeEachSplit = round(numel(frame_list)/SplitData,-3);
else
    SizeEachSplit = numel(frame_list);
end
NumSaveDigits = numel(num2str(frame_list(end)));

for SplitFrame = 1:SizeEachSplit:numel(frame_list)
    if SplitFrame<=numel(frame_list)-SizeEachSplit
        Splitframe_list = frame_list(SplitFrame:SplitFrame+SizeEachSplit);
    else
        Splitframe_list = frame_list(SplitFrame:end);
    end

    addpath(genpath('.'))

    img = LoadingImages(Imagefolder,ImageSuffix,settings.bitshift,Splitframe_list,settings.FlipLighting);

    %Image Contrast Adjustment
    img = ImageAdjust(img,settings.adjustlow,settings.adjusthigh,settings.gamma);

    %Image Sharpening
    img = ImageSharpening(img,settings.SharpenRadius,settings.SharpenAmount,settings.SharpenThreshold);

    parfor i = 1:numel(Splitframe_list)
        imwrite(img(:,:,i),[SaveDirec filesep 'data_' sprintf(['%0' num2str(NumSaveDigits) 'd'],Splitframe_list(i)) '.tif'])
    end
end

%Tracking
[vtracks,~,~,~,tracks] = PredictiveTracker([SaveDirec '\*.tif'],settings.BinaryThresh,settings.max_disp,[],settings.area_lim);




end



