function [AveUVSpectrum, AveUVSpectrum_error, stats_counter] = AverageAcrossDensity_UVSpectrum(DensityGroupsToAverage, AveUVSpectrum, AveUVSpectrum_error, stats_counter)
   
    [Dummy_UVSpec, Dummy_UVSpec_error, AveUVSpectrum2, AveUVSpectrum2_error] = deal(cell(1,length(DensityGroupsToAverage)));
    for DensityGroupIndex = 1:length(DensityGroupsToAverage)
        den = DensityGroupsToAverage{DensityGroupIndex};
        Dummy_UVSpec{DensityGroupIndex} = AveUVSpectrum(den);
        Dummy_UVSpec_error{DensityGroupIndex} = AveUVSpectrum_error(den);
        Dummy_UVSpec{DensityGroupIndex} = cell2mat(Dummy_UVSpec{DensityGroupIndex});   
        Dummy_UVSpec_error{DensityGroupIndex} = cell2mat(Dummy_UVSpec_error{DensityGroupIndex});        
        AveUVSpectrum2{DensityGroupIndex} = nanmean(Dummy_UVSpec{DensityGroupIndex},2);        
%         AveUVSpectrum2_error{DensityGroupIndex} = (sum(Dummy_UVSpec_error{DensityGroupIndex}.^2,2).^0.5)/size(Dummy_UVSpec_error{DensityGroupIndex},2);        
        AveUVSpectrum2_error{DensityGroupIndex} = nanmean(Dummy_UVSpec_error{DensityGroupIndex},2); 
    end
stats_counter = stats_counter*length(DensityGroupsToAverage{1});
AveUVSpectrum = AveUVSpectrum2';
AveUVSpectrum_error = AveUVSpectrum2_error';

end

