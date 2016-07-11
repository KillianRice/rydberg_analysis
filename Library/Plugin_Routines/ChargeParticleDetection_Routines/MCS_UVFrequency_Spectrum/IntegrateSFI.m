function [indivDataset] = IntegrateSFI(analyVar,indivDataset)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
NumStates = analyVar.numBasenamesAtom;

[SFI_Integral, SFI_Integral_error] = deal(cell(1,NumStates));
catArray = [];

for mbIndex = 1:NumStates
    
    NumFreq = indivDataset{mbIndex}.CounterAtom;
    [SFI_Integral{mbIndex}, SFI_Integral_error{mbIndex}] = deal(nan(NumFreq,1));
    
    for bIndex = 1:NumFreq
        SFI_Integral{mbIndex}(bIndex) = nansum(indivDataset{mbIndex}.delay_spectra{bIndex},1);
    end
    
    indivDataset{mbIndex} = rmfield(indivDataset{mbIndex},'delay_spectra');%remove data once the average over all samples has been calculated
    
    catArray = cat(2, catArray, SFI_Integral{mbIndex});
    
end

    Array       = nanmean(catArray,2);
    Array_error = nanstd(catArray,0,2);
    
%     [Normalized_Array, Normalized_Array_error, ~ , ~] = NormalizeArray(Array, Array_error, 1);
%     indivDataset{1}.SFI_Integral          = Normalized_Array;
%     indivDataset{1}.SFI_Integral_error    = Normalized_Array_error;

    indivDataset{1}.SFI_Integral        = Array;
    indivDataset{1}.SFI_Integral_error  = Array_error;
    
end

