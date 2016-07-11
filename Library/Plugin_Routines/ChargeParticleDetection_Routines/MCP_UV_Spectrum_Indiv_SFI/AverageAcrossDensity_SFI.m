function [Ave_SFI, Ave_SFI_error, stats_counter] = AverageAcrossDensity_SFI(unique_Freq, DensityGroupsToAverage, Ave_SFI, Ave_SFI_error, stats_counter)

[Dummy_SFI, Dummy_SFI_error, Ave_SFI2, Ave_SFI2_error] = deal(cell(1,length(unique_Freq)));    
for freqIndex = 1:length(unique_Freq)   
    
    [Dummy_SFI{freqIndex}, Dummy_SFI_error{freqIndex}, Ave_SFI2{freqIndex}, Ave_SFI2_error{freqIndex}] = deal(cell(1,length(DensityGroupsToAverage)));
    for DensityGroupIndex = 1:length(DensityGroupsToAverage)
        den = DensityGroupsToAverage{DensityGroupIndex};
        Dummy_SFI{freqIndex}{DensityGroupIndex} = Ave_SFI{freqIndex}(den);
        Dummy_SFI_error{freqIndex}{DensityGroupIndex} = Ave_SFI_error{freqIndex}(den);
        %Select data within each density group
        Dummy_SFI{freqIndex}{DensityGroupIndex} = cell2mat(Dummy_SFI{freqIndex}{DensityGroupIndex}');
        Dummy_SFI_error{freqIndex}{DensityGroupIndex} = cell2mat(Dummy_SFI_error{freqIndex}{DensityGroupIndex}');
        Ave_SFI2{freqIndex}{DensityGroupIndex} = nanmean(Dummy_SFI{freqIndex}{DensityGroupIndex},2);
        Ave_SFI2_error{freqIndex}{DensityGroupIndex} = nanmean(Dummy_SFI_error{freqIndex}{DensityGroupIndex},2);        
%         Ave_SFI2_error{freqIndex}{DensityGroupIndex} = (sum(Dummy_SFI_error{freqIndex}{DensityGroupIndex}.^2,2).^0.5)/size(Dummy_SFI_error{freqIndex}{DensityGroupIndex},2).^0.5;
        %Average SFI within given density group
    end
end

Ave_SFI = Ave_SFI2';
Ave_SFI_error = Ave_SFI2_error';
stats_counter = stats_counter*length(DensityGroupsToAverage{1});

end

