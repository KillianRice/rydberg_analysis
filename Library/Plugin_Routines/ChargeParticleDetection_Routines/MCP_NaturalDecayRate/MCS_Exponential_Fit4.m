function [ indivDataset, ResultData] = MCS_Exponential_Fit4(analyVar, indivDataset, ResultData)

[indivDataset] = MCS_Exponential_Fit_ParentState(analyVar, indivDataset);
[indivDataset] = MCS_Exponential_Fit_SecondaryState(analyVar, indivDataset);

for mbIndex     =   1:analyVar.numBasenamesAtom
%     [InitialValue, DecayRate, Offset] = deal(cell(1,length(indivDataset{mbIndex}.CounterMCS)));
    
        [InitialValue, DecayRate, Offset] = deal(nan(indivDataset{mbIndex}.numDensityGroups{1},3));
        
        for densityIndex = 1:indivDataset{mbIndex}.numDensityGroups{1}
            [InitialValue(densityIndex, 1:2), DecayRate(densityIndex, 1:2), Offset(densityIndex, 1:2)] =...
                Exponential_Decay_Fit(indivDataset{mbIndex}.timedelayOrderMatrix{1}', indivDataset{mbIndex}.mcsSumAvg(:,densityIndex), analyVar.MCS_Exponential_Fit_Offset);

            InitialValue(densityIndex, 3)= InitialValue(densityIndex, 2)/InitialValue(densityIndex, 1);%ratio of uncertainty to value of the parameter
            DecayRate(densityIndex, 3)   = DecayRate(densityIndex, 2)/DecayRate(densityIndex, 1);%ratio of uncertainty to value of the parameter
            Offset(densityIndex, 3)      = Offset(densityIndex, 2)/Offset(densityIndex, 1);%ratio of uncertainty to value of the parameter

        end
        
        if analyVar.Show_MCS_Decay_Fits_confidance_Intervals
            %plot_Exponential_Decay(ResultData.Sorted_RampDelay, ResultData.Sorted_SignalG, InitialValue, DecayRate, Offset, ExponentialDecayFitModel)
            plot_with_confidence_intervals_Exponential_Decay(...
                mbIndex*1e3,...
                indivDataset{mbIndex}.timedelayOrderMatrix{1},...
                indivDataset{mbIndex}.mcsSumAvg,...
                InitialValue,...
                DecayRate,...
                Offset)
        end
            
        if analyVar.ShowMCS_Exponential_Decay_FitParameters
            InitialValue
            DecayRate
            Offset
        end
        
        indivDataset{mbIndex}.InitialValue  =InitialValue;
        indivDataset{mbIndex}.DecayRate     =DecayRate;
        indivDataset{mbIndex}.Offset        =Offset;

end
end
