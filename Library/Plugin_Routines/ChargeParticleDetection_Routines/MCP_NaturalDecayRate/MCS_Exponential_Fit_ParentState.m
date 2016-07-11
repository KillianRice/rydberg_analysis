function [ analyVar] = MCS_Exponential_Fit_ParentState(analyVar, indivDataset)

NumDensities = indivDataset{1}.numDensityGroups{1};
NumBatches = indivDataset{1}.CounterAtom;
[InitialValue, DecayRate, Offset] = deal(nan(NumDensities,3,NumBatches)); % Number of Densities x 3 fit results (value error ratio) x Number of Batches

xticks = indivDataset{1}.timedelayOrderMatrix{1}'; %s, Electric Field delay times

[Peak_AvgSpectra, Peak_AvgSpectra_error] = deal(cell(NumBatches,1));
for bIndex = 1:NumBatches
    Peak_AvgSpectra{bIndex} = analyVar.Peak_AvgSpectra{bIndex};
    Peak_AvgSpectra_error{bIndex} = analyVar.Peak_AvgSpectra_error{bIndex};
    
    for densityIndex = 1:NumDensities
        
        [InitialValue(densityIndex, 1:2, bIndex), DecayRate(densityIndex, 1:2, bIndex), Offset(densityIndex, 1:2, bIndex)] =...
            Exponential_Decay_Fit(xticks, Peak_AvgSpectra{bIndex}(:,densityIndex), analyVar.MCS_Exponential_Fit_Offset);

        InitialValue(densityIndex, 3, bIndex)= InitialValue(densityIndex, 2, bIndex)/InitialValue(densityIndex, 1, bIndex);%ratio of uncertainty to value of the parameter
        DecayRate(densityIndex, 3, bIndex)   = DecayRate(densityIndex, 2, bIndex)/DecayRate(densityIndex, 1, bIndex);%ratio of uncertainty to value of the parameter
        Offset(densityIndex, 3, bIndex)      = Offset(densityIndex, 2, bIndex)/Offset(densityIndex, 1, bIndex);%ratio of uncertainty to value of the parameter

    end
end

% if analyVar.Show_MCS_Decay_Fits_confidance_Intervals
%     plot_with_confidence_intervals_Exponential_Decay(...
%         mbIndex*1e3,...
%         indivDataset{mbIndex}.timedelayOrderMatrix{1},...
%         indivDataset{mbIndex}.mcsSumAvg,...
%         InitialValue,...
%         DecayRate,...
%         Offset)
% end

if analyVar.ShowMCS_Exponential_Decay_FitParameters
    InitialValue
    DecayRate
    Offset
end

analyVar.InitialValue  =InitialValue;
indivDataset{mbIndex}.DecayRate     =DecayRate;
indivDataset{mbIndex}.Offset        =Offset;

end

