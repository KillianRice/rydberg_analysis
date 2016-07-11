function [ indivDataset ] = RelativeNormalization( analyVar,indivDataset )

NumStates = analyVar.numBasenamesAtom;

[AbsNormAvgSpectra, AbsNormAvgSpectra_error, tAllNormalization_Array, tAllNormalization_Array_error, RelNormAvgSpectra, RelNormAvgSpectra_error] = deal(cell(1,NumStates));

for mbIndex = 1:NumStates
    %% Load Data
        AbsNormAvgSpectra{mbIndex} = indivDataset{mbIndex}.AbsNormAvgSpectra; % (# arrival bins) x (# delay times) x (# densities)
        AbsNormAvgSpectra_error{mbIndex} = indivDataset{mbIndex}.AbsNormAvgSpectra_error;
        
    %% Normalization Parameters
        NormalizationDimension = 1; % set to 1 to normalize over the bin/field dimension
        DelayDim = 2; %dimension of delay field       
        
    %% Calculate Normalization Array At Every Field Delay
        [~, ~, tAllNormalization_Array{mbIndex} , tAllNormalization_Array_error{mbIndex}] =...
            NormalizeArray( AbsNormAvgSpectra{mbIndex}, AbsNormAvgSpectra_error{mbIndex}, NormalizationDimension );            

    %% Apply Normalization Array
        [RelNormAvgSpectra{mbIndex}, RelNormAvgSpectra_error{mbIndex}]=...
            ApplyNormalization(AbsNormAvgSpectra{mbIndex}, AbsNormAvgSpectra_error{mbIndex}, tAllNormalization_Array{mbIndex}, tAllNormalization_Array_error{mbIndex}, 2, DelayDim);        

    %% Save to Structure
        indivDataset{mbIndex}.RelNormAvgSpectra         = RelNormAvgSpectra{mbIndex}; %Population normalized by the total population at each field delay
        indivDataset{mbIndex}.RelNormAvgSpectra_error   = RelNormAvgSpectra_error{mbIndex};        
end