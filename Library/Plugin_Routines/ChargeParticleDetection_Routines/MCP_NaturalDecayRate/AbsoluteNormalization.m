function [ indivDataset ] = AbsoluteNormalization( analyVar,indivDataset )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

NumStates = analyVar.numBasenamesAtom;

[AvgSpectra, AvgSpectra_error, tZeroNormalization_Array, tZeroNormalization_Array_error, AbsNormAvgSpectra, AbsNormAvgSpectra_error] = deal(cell(1,NumStates));

for mbIndex = 1:NumStates
    %% Normalization Parameters
        NormalizationDimension = 1; % set to 1 to normalize over the bin/field dimension
        DelayDim = 2; %dimension of delay field
        NormalizationDelayBin = 1; %normalize at constant delay field
    
    %% Load Data
        AvgSpectra{mbIndex} = indivDataset{mbIndex}.AvgSpectra; % (# arrival bins) x (# delay times) x (# densities)
        AvgSpectra_error{mbIndex} = indivDataset{mbIndex}.AvgSpectra_error;
    
    %% Calculate Normalization Array At Field Delay of 0s
        [~, ~, tZeroNormalization_Array{mbIndex} , tZeroNormalization_Array_error{mbIndex}] =...
            NormalizeArray( AvgSpectra{mbIndex}(:,NormalizationDelayBin,:), AvgSpectra_error{mbIndex}(:,NormalizationDelayBin,:), NormalizationDimension );

    %% Apply Normalization Array
        [AbsNormAvgSpectra{mbIndex}, AbsNormAvgSpectra_error{mbIndex}]=...
            ApplyNormalization(AvgSpectra{mbIndex}, AvgSpectra_error{mbIndex}, tZeroNormalization_Array{mbIndex}, tZeroNormalization_Array_error{mbIndex},1, DelayDim);

    %% Save to Structure
        indivDataset{mbIndex}.AbsNormAvgSpectra         = AbsNormAvgSpectra{mbIndex};
        indivDataset{mbIndex}.AbsNormAvgSpectra_error   = AbsNormAvgSpectra_error{mbIndex};
        
        indivDataset{mbIndex} = rmfield(indivDataset{mbIndex},'AvgSpectra');%remove data once the average over all samples has been calculated
        indivDataset{mbIndex} = rmfield(indivDataset{mbIndex},'AvgSpectra_error');%remove data once the average over all samples has been calculated
end    

end

