function A_bsub = LoadingImages(direc,suffix,i1_range,i2_range,frame_list,Imagebit,shiftbit,Run,histmatch,BackgroundImage)

bit = Imagebit;

if bit == 8
    A = zeros(numel(i1_range),numel(i2_range),numel(frame_list),'uint8');
%     sum = zeros(numel(i1_range),numel(i2_range),'double');
elseif bit == 16
    A = zeros(numel(i1_range),numel(i2_range),numel(frame_list),'uint16');
%     sum = zeros(numel(i1_range),numel(i2_range),'double');
else
    disp('Invalid bit depth')
    return
end
if suffix == ".cine"
    bit = 16;
end
LoadPhantomLibraries();
RegisterPhantom(true);

for i = 1:numel(frame_list)
    if suffix == ".tif"
        temp1 = imread([direc sprintf( '%05d', frame_list(i) ),'.tif']);
    elseif suffix == ".cine"
        if isfile([direc '\data2_.cine']) && i == 1
            %Figure out which cine is the correct one for image readout
            [HRES, cineHandle] = PhNewCineFromFile([direc '\data2_.cine']);

            if (HRES<0)
                [message] = PhGetErrorMessage(HRES);
                error(['Cine Handle creation error: ' message])
            end

            pFirstIm2 = libpointer('int32Ptr',0);
            PhGetCineInfo(cineHandle,PhFileConst.GCI_FIRSTIMAGENO,pFirstIm2);

            pImCount2 = libpointer('uint32Ptr',0);
            PhGetCineInfo(cineHandle,PhFileConst.GCI_IMAGECOUNT,pImCount2);
            LastFrame = int32(double(pFirstIm2.Value)+double(pImCount2.Value)-1);
        end
        if  isfile([direc '\data2_.cine'])
            if frame_list(i) >= double(pFirstIm2.Value)
                ImageDirec = [direc '\data2_.cine'];
            elseif frame_list(i)>LastFrame
                error('Image number is out of range of saved images')
            else
                ImageDirec = [direc '\data_.cine'];
            end
        else
            ImageDirec = [direc '\data_.cine'];
        end
    end
           
           
        
    
        %Read image into matlab
        [~,temp1] = ReadCineFileImage(ImageDirec,frame_list(i),false);

    %     temp1 = imread([data_dir '\Test_' num2str(Tnum) '\Test_' num2str(Tnum) '_' sprintf( '%04d', frame_list(i) ),'.tif']);
    A(:,:,i) = uint8((temp1(i1_range,i2_range)*(2^shiftbit)/(2^(bit-8)))); % /16 to make it 8 bit (VEO is 12)

    A(:,:,i) = (2^8-1)-A(:,:,i);

%     if numel(frame_list)>1 && BackgroundImage ~= "Ratio"
%         sum = sum + double(A(:,:,i));
%     end

    if histmatch
        if i == 1
            A(:,:,i) = adapthisteq(A(:,:,i),'distribution','Rayleigh');
        else
            A(:,:,i) = imhistmatch(A(:,:,i),A(:,:,1));
        end
    end

    clearvars A1_sort A2_sort
    fprintf('Analyzing Run = %4d; This bitch is still loading image %4d\n',Run,frame_list(i))
end
disp('Subtracting Background')
% alternative background: no 'freak events'; this doesnt take the single
% darkest image, but the 10th darkest image

% A_bsub = zeros(size(A),'double');
if numel(frame_list)<1
    A_bg = sum./numel(frame_list);
    A_bsub = uint8(A-A_bg);
else
    AveragingWindow = 1000;
%     A_bg = zeros(numel(i1_range),numel(i2_range),numel(1:AveragingWindow:size(A,3)),'double');
    for i = 1:AveragingWindow:size(A,3)
          disp(['Getting Background image from i = ' num2str(i)])
%         csum = zeros(numel(i1_range),numel(i2_range),'double');
        if i < AveragingWindow/2+1
            %Forward Averaging
            csum = cumsum(double(A(:,:,1:i+AveragingWindow)),3);
            csum = csum(:,:,end); 
            A_bg = csum./(numel(1:i+AveragingWindow));
            if BackgroundImage ~= "Ratio"
                A(:,:,i:i+AveragingWindow) = double(A(:,:,i:i+AveragingWindow)) - A_bg;
            else
                A(:,:,i:i+AveragingWindow) = rescale((double(A(:,:,i:i+AveragingWindow)) - A_bg)./A_bg,0,2^8-1);
            end
        elseif i>(numel(frame_list))-AveragingWindow
            %Backward Averaging
            csum = cumsum(double(A(:,:,i-AveragingWindow/2:numel(frame_list))),3);
            csum = csum(:,:,end);
            A_bg = csum./(numel(i-AveragingWindow/2:numel(frame_list)));
            
            if BackgroundImage ~= "Ratio"
                A(:,:,i:numel(frame_list)) = double(A(:,:,i:numel(frame_list))) - A_bg;
            else
                A(:,:,i:numel(frame_list)) = rescale((double(A(:,:,i:numel(frame_list))) - A_bg)./A_bg,0,2^8-1);
            end
        else
            %Forward Averaging
            csum = cumsum(double(A(:,:,i:i+AveragingWindow)),3);
            csum = csum(:,:,end);
            A_bg = csum./(numel(i:i+AveragingWindow));
            
            if BackgroundImage ~= "Ratio"
                A(:,:,i:i+AveragingWindow) = double(A(:,:,i:i+AveragingWindow)) - A_bg;
            else
                A(:,:,i:i+AveragingWindow) = rescale((double(A(:,:,i:i+AveragingWindow)) - A_bg)./A_bg,0,2^8-1);

            end

        end       
        
    end
end
A_bsub = uint8(A);
UnregisterPhantom();
UnloadPhantomLibraries();

% if BackgroundImage == "Ratio"
%     A_bsub = uint8(rescale((double(A)-A_bg)./A_bg,0,0.25*2^8-1));
% %     A_bsub = uint8(A_bsub);
% else
%     A_bsub = A-uint8(A_bg);
% end


% imRatio = double(A)./double(A_bg);
% A_bsub = uint8(double(A).*imRatio-double(A_bg));

% A_bsub = zeros(size(A));
% for i = 1:numel(frame_list)
%     imRatio = double(A(:,:,i))./double(A_bg);
%     
%     A_bsub(:,:,i) = uint8(double(A(:,:,i)).*imRatio-double(A_bg)); %
% end

%% Now try to look at binarizing the images using adapt thresh
%     if binarize
%         for i = 1:size(A_bsub,3)
%             disp(['Binarizing image ' num2str(i) ' of ' num2str(size(A_bsub,3))])
% %             alg = 2*floor(size(A(:,:,i),1)/16)+1;
%             aa = adaptthresh(A_bsub(:,:,i),0.01);
%
%             bintemp = imfill(imbinarize(A_bsub(:,:,i),aa),'holes');
%
%             A_bsub(:,:,i) = uint8(bintemp.*2.^8);
%         end
%     function ImageDirec = GetCineInformation(direc,frame)
%        
%         [HRES, cineHandle] = PhNewCineFromFile([direc '\data2_.cine']);
% 
%         if (HRES<0)
%             [message] = PhGetErrorMessage(HRES);
%             error(['Cine Handle creation error: ' message])
%         end
% 
%         pFirstIm2 = libpointer('int32Ptr',0);
%         PhGetCineInfo(cineHandle,PhFileConst.GCI_FIRSTIMAGENO,pFirstIm2);
% 
%         pImCount2 = libpointer('uint32Ptr',0);
%         PhGetCineInfo(cineHandle,PhFileConst.GCI_IMAGECOUNT,pImCount2);
%         LastFrame = int32(double(pFirstIm2.Value)+double(pImCount2.Value)-1);
% 
%         if frame >= double(pFirstIm2.Value)
%             ImageDirec = [direc '\data2_.cine'];
%         elseif frame>LastFrame
%             error('Image number is out of range of saved images')
%         else
%             ImageDirec = [direc '\data_.cine'];
%         end
%         clearvars pFirstIm2 pImCount2 CineHandle
%        
%     end
% end


