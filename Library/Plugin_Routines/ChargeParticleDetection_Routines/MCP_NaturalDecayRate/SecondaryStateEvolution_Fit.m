function [indivDataset] = SecondaryStateEvolution_Fit(analyVar, indivDataset)

NumDensities = indivDataset{1}.numDensityGroups{1};
NumBatches = indivDataset{1}.CounterAtom;

[ParentDecay, SecondaryDecay, SecondaryOffset] = deal(cell(1,NumBatches));

x_data = indivDataset{1}.timedelayOrderMatrix{1}'; %s, Electric Field delay times

for bIndex = 1:NumBatches
    
    for densityIndex = 1:NumDensities
        
        y_data = indivDataset{bIndex}.TotalRydNonPeakPop(:,densityIndex);

        Bare_Decay_Rate     = indivDataset{bIndex}.Peak_DecayRate(densityIndex, 1);
        InitialValue        = indivDataset{bIndex}.Peak_InitialValue(densityIndex, 1);
        TimeOffset_Guess    = analyVar.ArrivalTime(analyVar.PeakBin)+analyVar.Exposure_Time(1);
        
        [ParentDecay{bIndex}(densityIndex, 1:2), SecondaryDecay{bIndex}(densityIndex, 1:2)] =...
        SecondaryStateEvolution_Fit_B(x_data, y_data, Bare_Decay_Rate, InitialValue, TimeOffset_Guess);

    end
    
% indivDataset{bIndex}.InitialSignal      = InitialSignal{bIndex};
indivDataset{bIndex}.ParentDecay        = ParentDecay{bIndex};
indivDataset{bIndex}.SecondaryDecay     = SecondaryDecay{bIndex};
indivDataset{bIndex}.SecondaryOffset    = SecondaryOffset{bIndex};

indivDataset{bIndex}.TimeOffset         = -TimeOffset_Guess;    
    
end

% InitialSignal
% ParentDecay
% SecondaryDecay

end

