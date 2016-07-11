function [ output ] = plot_UVSpectrum_indivdensities(xData, yData, whichDensities)
% pick out data within SFI_roi and make cell array to carry all the data.
NumStates = length(yData);
NumDen = size(yData{1},2);
% NumFreq = size(yData{1},1);
yData2 = cell(1,NumDen);
for DenIndex = 1:NumDen
    yData2{DenIndex} = cell(1, NumStates);
    for mbIndex = 1:NumStates
        yData2{DenIndex}{mbIndex} = yData{mbIndex}(:,DenIndex);
    end

end

for DenIndex = whichDensities
    figure
    hold on    
    mycolors = FrancyColors3(NumStates);
    for mbIndex = 1:NumStates
        plot(xData{mbIndex}, yData2{DenIndex}{mbIndex},'Color', mycolors(mbIndex,:))
    end
    hold off
end
output = nan;
end

