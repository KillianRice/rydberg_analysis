function [ output ] = plot_UVSpectrum_indivdatasets(xData, yData)
% pick out data within SFI_roi and make cell array to carry all the data.
NumStates = length(yData);
for mbIndex = 1:NumStates
    NumDen = size(yData{mbIndex},2);
    figure
    hold on    
    mycolors = FrancyColors(NumDen);
    for DenIndex = 1:NumDen
        plot(xData{mbIndex},yData{mbIndex}(:,DenIndex),'Color', mycolors(DenIndex,:))
    end
    hold off
end
output = nan;
end

