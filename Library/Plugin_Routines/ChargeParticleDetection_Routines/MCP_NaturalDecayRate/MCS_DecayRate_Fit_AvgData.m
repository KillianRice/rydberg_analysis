function [analyVar, indivDataset] = MCS_DecayRate_Fit_AvgData( analyVar, indivDataset )
%do linear fit of decay rate vs density

NumBatches      = indivDataset{1}.CounterAtom;

NumSets         = analyVar.numBasenamesAtom;


for Feature_or_Sum = 1:2
for mbIndex = 1:NumSets
    [Avg_Slope, Avg_y_intercept] = deal(nan(1,2));
    NumDensities    = indivDataset{mbIndex}.numDensityGroups{1};
    DataPointToKeep = NumDensities;%how many density points to keep, can set by hand, left to NumDensities s.t. all data is kept
    xData = indivDataset{mbIndex}.densityvector(NumDensities-DataPointToKeep+1:end) ;
    
    switch Feature_or_Sum
        case 1
        yData       = indivDataset{mbIndex}.Peak_DecayRate(NumDensities-DataPointToKeep+1:end,1);
        case 2
        yData       = indivDataset{mbIndex}.Sum_DecayRate(NumDensities-DataPointToKeep+1:end,1);     

    end

        cf = fit(xData, yData,'poly1'); 
        cf_coeff = coeffvalues(cf);
        cf_confint = confint(cf,.682);
        Avg_Slope(1) = cf_coeff(1);
        Avg_Slope(2) = (cf_confint(2,1) - cf_confint(1,1))/2;
        
        Avg_y_intercept(1) = cf_coeff(2);
        Avg_y_intercept(2) = (cf_confint(2,2) - cf_confint(1,2))/2;

        if Feature_or_Sum == 1
            indivDataset{mbIndex}.Avg_Slope_Peak              = Avg_Slope;
            indivDataset{mbIndex}.Avg_y_intercept_Peak        = Avg_y_intercept;
        else
            indivDataset{mbIndex}.Avg_Slope_Sum              = Avg_Slope;
            indivDataset{mbIndex}.Avg_y_intercept_Sum        = Avg_y_intercept;
        end

end
end
end

