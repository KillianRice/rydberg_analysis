function cutImageCell = TrimAndBin(analyVar,roiImageCell)
% Function to perform image processing options on image matricies
%
% INPUT:
%   analyVar     - structure containing variables from AnalysisVariables
%   roiImageCell - cell of the roi images for processing
%
% OUTPUT:
%   cutImageCell - cell containing the processed images

cutImageCell = cell(size(roiImageCell));
for i = 1:length(roiImageCell)
    %% Binning
    if analyVar.softwareBinSize > 1
        binImage = zeros(floor(size(image)/analyVar.softwareBinSize));
        for k = 1:size(image,2)/analyVar.softwareBinSize
            for l = 1:size(image,1)/analyVar.softwareBinSize
                binImage(k,l) = sum(sum(image(k*analyVar.softwareBinSize-(analyVar.softwareBinSize-1):l*analyVar.softwareBinSize,...
                    l*analyVar.softwareBinSize-(analyVar.softwareBinSize-1):l*analyVar.softwareBinSize)));
            end
        end
    else
        binImage = roiImageCell{i};
    end

    %% Trimming
    %%%%Cut edges of data by analyVar.cutBorders, make double to do log
    cutImageCell{i} = double(binImage((analyVar.cutBorders + 1):(size(binImage,1) - analyVar.cutBorders),...
        (analyVar.cutBorders + 1):(size(binImage,2) - analyVar.cutBorders)));
end