function [xData, yData] = arrangeData_UVSpectrum_indivdatasets(analyVar,indivDataset,SFI_roi)
% pick out data within SFI_roi and make cell array to carry all the data.
NumStates = analyVar.numBasenamesAtom;
[xData, yData] = deal(cell(1,NumStates));
for mbIndex = 1:NumStates
    xData{mbIndex} = indivDataset{mbIndex}.imagevcoAtom;
    NumFreq = indivDataset{mbIndex}.CounterAtom;
    yData{mbIndex} = nan(NumFreq,size(indivDataset{1}.delay_spectra{1},3));
    for bIndex = 1:NumFreq
        if size(indivDataset{mbIndex}.delay_spectra{bIndex},2)>1
            error('FC: Expecting UV Spectra at single value of field delay.')
        end
        Signal = indivDataset{mbIndex}.delay_spectra{bIndex};
        if SFI_roi == -1
            Signal = nansum(Signal,1);
        else
            Signal = nansum(Signal(SFI_roi,:,:),1);
        end
        Signal = squeeze(Signal);
        yData{mbIndex}(bIndex,:) = Signal;
    end
end

end

