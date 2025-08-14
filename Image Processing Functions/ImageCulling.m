function CulledImg = ImageCulling(img)

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