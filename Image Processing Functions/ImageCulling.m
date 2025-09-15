function CulledImg = ImageCulling(img,PIV_LPT)
%%CulledImg = ImageCulling(img,PIV_LPT). PIV_LPT is a option for whether
%%you're doing PIV or LPT and want to use that version of image culling.
%%Put 'PIV' here for PIV and 'LPT' here for LPT. PIV option will eliminate
%%images that are below a threshold that is 0.8 times the median intensity
%%of all images. For LPT option, opposite will happen, images that are too
%%bright (above a threshold) will be thrown away. For LPT culling is
%%decided based on median of each image rather than of entire set like for
%%PIV

IntMed = median(img,'all');

CulledImg = cell(1,size(img,3));
for i = 1:2:size(img,3)
    IntMedImg = median(img(:,:,i),'all');

    if IntMedImg > 0.8*IntMed
        CulledImg{i} = img(:,:,i);
        CulledImg{i+1} = img(:,:,i+1);
    end
end
CulledImg = cat(3,CulledImg{:});

end