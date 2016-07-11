function [indivDataset] = ParentStateEvolution_Fit(analyVar, indivDataset)


    [Peak_InitialValue, Peak_DecayRate, Peak_Offset] = deal(cell(1,analyVar.numBasenamesAtom));    
    
for mbIndex = 1:analyVar.numBasenamesAtom
    xticks = indivDataset{mbIndex}.timedelayOrderMatrix{1}'; %s, Electric Field delay times

    for featureIndex = analyVar.DrivenStateGroup(mbIndex)
        
        NumDensities = indivDataset{mbIndex}.numDensityGroups{1};
        Feature_AvgSpectra = indivDataset{mbIndex}.Feature_AbsNormAvgSpectra;

        [Peak_InitialValue{mbIndex}, Peak_DecayRate{mbIndex}, Peak_Offset{mbIndex}] = deal(nan(NumDensities,2));
            for densityIndex = 1:NumDensities

                [Peak_InitialValue{mbIndex}(densityIndex, 1:2), Peak_DecayRate{mbIndex}(densityIndex, 1:2), Peak_Offset{mbIndex}(densityIndex, 1:2)] =...
                    Exponential_Decay_Fit(xticks, Feature_AvgSpectra{featureIndex}(:,densityIndex), analyVar.MCS_Exponential_Fit_Offset);

            end

        indivDataset{mbIndex}.Peak_InitialValue  = Peak_InitialValue{mbIndex};
        indivDataset{mbIndex}.Peak_DecayRate     = Peak_DecayRate{mbIndex};
        indivDataset{mbIndex}.Peak_Offset        = Peak_Offset{mbIndex};
   
    end
end


end

