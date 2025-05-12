function ImageProcessingAndPIV(settings,Imagefolder,ImageSuffix,frame_list,SplitData,SaveDirecImages,SaveDirecAnalyzed)
%[vtracks,tracks] = ImageProcessingAndTrackingCalling(settings,Imagefolder,ImageSuffix,frame_list,SplitData,SaveDirec)
% For this function to work you have to specify a frame_list. Settings.mat file
%can be generated from the GUI for settings. SplitData value is how many
%times you want to split the frame_list so you don't overload the ram.

if ~exist([SaveDirecAnalyzed '\Data_Split'],'dir')
    mkdir([SaveDirecAnalyzed '\Data_Split'])
end

% Data Splitting
if SplitData
    SizeEachSplit = round(numel(frame_list)/SplitData);
    if ~rem(SizeEachSplit-frame_list(1),2) 
        SizeEachSplit = SizeEachSplit-1;
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

    %Background Subtraction
    if settings.BgSubBool == "On"
        img = SubtractBackground(img,settings.FrameSkip,settings.RollingWindow,fig);
    end
    %CLAHE
    if settings.CLAHE == "On"
        img = CLAHEProcess(img,fig);
    end
    %Image Sharpening
    if settings.ImSharpBool == "On"
        img = ImageSharpening(img,settings.SharpenRadius,settings.SharpenAmount,settings.SharpenThreshold,fig);
    end

   if ~isnumeric(SaveDirecImages)
        d = uiprogressdlg(fig,'Title','Please Wait','Message',['Saving Images ' num2str(Splitframe_list(1)) ' to ' num2str(Splitframe_list(end))]...
            ,'Indeterminate','on');
        drawnow
        for i = 1:numel(Splitframe_list)
            imwrite(img(:,:,i),[SaveDirecImages filesep 'data_' sprintf(['%0' num2str(NumSaveDigits) 'd'],Splitframe_list(i)) '.tif'])
        end
        close(d)
    end
    close(fig)
    %% Calling PIVLab and setting up variables
    [x,y,u,v,u_filt,v_filt] = PIVlab_commandline(img,settings);

    save([SaveDirecAnalyzed '\Data_Split\SplitData_' num2str(SplitCounter) '.mat'],'x','y','u','v','u_filt','v_filt')

end
clearvars img
end



