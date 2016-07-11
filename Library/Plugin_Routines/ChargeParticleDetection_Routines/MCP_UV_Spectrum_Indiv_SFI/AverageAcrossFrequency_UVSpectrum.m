function [xData, AveUVSpectrum, AveUVSpectrum_error] = AverageAcrossFrequency_UVSpectrum(frequencygrouping, xData, AveUVSpectrum, AveUVSpectrum_error)

    xData = tsmovavg(xData, 's', frequencygrouping, 1);
    xData = xData(~isnan(xData));
    for DensityGroupIndex = 1:length(AveUVSpectrum)
        AveUVSpectrum{DensityGroupIndex}        = tsmovavg(AveUVSpectrum{DensityGroupIndex}, 's', frequencygrouping, 1);
        AveUVSpectrum_error{DensityGroupIndex}  = tsmovavg(AveUVSpectrum_error{DensityGroupIndex}, 's', frequencygrouping, 1);
        AveUVSpectrum{DensityGroupIndex}        = AveUVSpectrum{DensityGroupIndex}(~isnan(AveUVSpectrum{DensityGroupIndex}));        
        AveUVSpectrum_error{DensityGroupIndex}  = AveUVSpectrum_error{DensityGroupIndex}(~isnan(AveUVSpectrum{DensityGroupIndex}));   
    end
end