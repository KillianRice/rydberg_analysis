function [indivDataset] = SumSignalEvolution_Fit(analyVar, indivDataset)

    [Sum_InitValue, Sum_DecayRate, Sum_Offset] = deal(cell(1,analyVar.numBasenamesAtom));    
    [SumAvgSpectra] = deal(cell(1,analyVar.numBasenamesAtom));
    
for mbIndex = 1:analyVar.numBasenamesAtom
    xticks = indivDataset{mbIndex}.timedelayOrderMatrix{1}'; %s, Electric Field delay times
    NumDensities = indivDataset{mbIndex}.numDensityGroups{1};
    SumAvgSpectra{mbIndex} = indivDataset{mbIndex}.NormTotalPopAvgSpectra; %Population normalized by the total population at t = 0
    
    [Sum_InitValue{mbIndex}, Sum_DecayRate{mbIndex}, Sum_Offset{mbIndex}] = deal(nan(NumDensities,2));
        for densityIndex = 1:NumDensities
        
            [Sum_InitValue{mbIndex}(densityIndex, 1:2), Sum_DecayRate{mbIndex}(densityIndex, 1:2), Sum_Offset{mbIndex}(densityIndex, 1:2)] =...
                Exponential_Decay_Fit(xticks, SumAvgSpectra{mbIndex}(:,densityIndex), analyVar.MCS_Exponential_Fit_Offset);

        end

    indivDataset{mbIndex}.Sum_InitialValue  = Sum_InitValue{mbIndex};
    indivDataset{mbIndex}.Sum_DecayRate     = Sum_DecayRate{mbIndex};
    indivDataset{mbIndex}.Sum_Offset        = Sum_Offset{mbIndex};    
    
end


end

