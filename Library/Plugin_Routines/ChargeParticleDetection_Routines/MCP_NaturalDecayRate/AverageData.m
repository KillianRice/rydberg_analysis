function [indivDataset] = AverageData(analyVar,indivDataset)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
NumStates = analyVar.numBasenamesAtom;
[AvgSpectra, AvgSpectra_error] = deal(cell(1,NumStates)); %one cell element per master batch entry

for mbIndex = 1:NumStates
    NumRepetitions = indivDataset{mbIndex}.CounterAtom;

    for bIndex = 1:NumRepetitions
        ArrayDim = ndims(indivDataset{mbIndex}.delay_spectra{bIndex});
        AvgSpectra{mbIndex} = cat(ArrayDim+1,AvgSpectra{mbIndex}, indivDataset{mbIndex}.delay_spectra{bIndex});
    end
    
%     AvgSpectra_error{mbIndex}                = nanstd(AvgSpectra{mbIndex},0,ArrayDim+1)/(NumRepetitions)^0.5;
    AvgSpectra_error{mbIndex}                = nanstd(AvgSpectra{mbIndex},0,ArrayDim+1)/5;

    indivDataset{mbIndex}.AvgSpectra_error   = AvgSpectra_error{mbIndex};
    AvgSpectra{mbIndex}                      = nanmean(AvgSpectra{mbIndex},ArrayDim+1);
    indivDataset{mbIndex}.AvgSpectra         = AvgSpectra{mbIndex}; %cell of size = num of batches. Each cell element is an array of (# of MCS bins) x (# of field delay times) x (# of densities) where each element is the number of counts
            
    Sum_AvgSpectra = nansum(AvgSpectra{mbIndex},1);
    Sum_AvgSpectra = permute(Sum_AvgSpectra, [2 3 1] );
    
    indivDataset{mbIndex}.Sum_AvgSpectra = Sum_AvgSpectra;          
    
    indivDataset{mbIndex} = rmfield(indivDataset{mbIndex},'delay_spectra');%remove data once the average over all samples has been calculated

end

end

