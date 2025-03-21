function [x,y,u,v,u_filtCat,v_filtCat] = ImageProcessingAndPIV(settings,Imagefolder,ImageSuffix,frame_list,SplitData,SaveDirec)
%[vtracks,tracks] = ImageProcessingAndTrackingCalling(settings,Imagefolder,ImageSuffix,frame_list,SplitData,SaveDirec)
% For this function to work you have to specify a frame_list. Settings.mat file
%can be generated from the GUI for settings. SplitData value is how many
%times you want to split the frame_list so you don't overload the ram.

% Setting up PIV variables for data splitting
u_filtCat = cell(1,SplitData); v_filtCat = cell(1,SplitData);

% Data Splitting
if SplitData
    SizeEachSplit = round(numel(frame_list)/SplitData,-1);
    if mod(SizeEachSplit,2) == 1
        SizeEachSplit = SizeEachSplit+1;
    end
else
    SizeEachSplit = numel(frame_list);
end
NumSaveDigits = numel(num2str(frame_list(end)));
SplitCounter = 0;
for SplitFrame = 1:SizeEachSplit:numel(frame_list)
    SplitCounter = SplitCounter+1;
    if SplitFrame<=numel(frame_list)-SizeEachSplit
        Splitframe_list = frame_list(SplitFrame:SplitFrame+SizeEachSplit);
    else
        Splitframe_list = frame_list(SplitFrame:end);
    end

    %% Image Processing
    addpath(genpath('.'))
    fig = uifigure;
    [img,BitDepth] = LoadImages(Imagefolder,ImageSuffix,settings.BitShift,Splitframe_list,settings.FlipLighting,fig);
    if settings.Rotate
        img = rot90(img,settings.Rotate);
    end

    %Homomorphic Filter
    if settings.ImHFiltBool == "On"
        img = HomomorphicFilter(img,settings.Sigma,settings.Alpha,settings.Beta,BitDepth,fig);
    end
    %Background Subtraction
    if settings.BgSubBool == "On"
        img = SubtractBackground(img,settings.FrameSkip,settings.RollingWindow,fig);
    end
    %Image Contrast Adjustment
    if settings.ImAdjustBool == "On"
        img = ImageAdjust(img,settings.adjustlow,settings.adjusthigh,settings.gamma,fig);
    end
    %Image Sharpening
    if settings.ImSharpBool == "On"
        img = ImageSharpening(img,settings.SharpenRadius,settings.SharpenAmount,settings.SharpenThreshold,fig);
    end

    if SaveDirec
        d = uiprogressdlg(fig,'Title','Please Wait','Message',['Saving Images ' num2str(Splitframe_list(1)) ' to ' num2str(Splitframe_list(end))]...
            ,'Indeterminate','on');
        drawnow
        for i = 1:numel(Splitframe_list)
            imwrite(img(:,:,i),[SaveDirec filesep 'data_' sprintf(['%0' num2str(NumSaveDigits) 'd'],Splitframe_list(i)) '.tif'])
        end
        close(d)
        close(fig)
    end

    %% Calling PIVLab and setting up variables
    [x,y,u,v,u_filt,v_filt] = PIVlab_commandline(img,settings,SaveDirec);
    u_filtCat{1,SplitCounter} = u_filt; v_filtCat{1,SplitCounter} = v_filt;

    %% Saving processed images
    d = uiprogressdlg(fig,'Title','Please Wait','Message',['Saving Images ' num2str(Splitframe_list(1)) ' to ' num2str(Splitframe_list(end))]...
        ,'Indeterminate','on');
    drawnow
    for i = 1:numel(Splitframe_list)
        imwrite(img(:,:,i),[SaveDirec filesep 'data_' sprintf(['%0' num2str(NumSaveDigits) 'd'],Splitframe_list(i)) '.tif'])
    end
end
clearvars img
end



