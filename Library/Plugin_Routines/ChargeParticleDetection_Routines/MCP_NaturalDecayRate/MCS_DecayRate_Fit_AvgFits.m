function [analyVar, indivDataset] = MCS_DecayRate_Fit_AvgFits( analyVar, indivDataset )
%do linear fit of decay rate vs density

NumBatches      = indivDataset{1}.CounterAtom;

for Peak_or_Sum = 1:2
    [y_data] = deal(cell(NumBatches,1));

    [slope, y_intercept] = deal(nan(NumBatches,3));

    x_data = indivDataset{1}.densityvector ;

    for bIndex = 1:NumBatches

        if Peak_or_Sum == 1
            y_data{bIndex} = analyVar.Peak_DecayRate(:,1,bIndex);
        else
            y_data{bIndex} = analyVar.Sum_DecayRate(:,1,bIndex);
        end

        cf = fit(x_data,y_data{bIndex},'poly1'); 
        cf_coeff = coeffvalues(cf);
        cf_confint = confint(cf);
        slope(bIndex, 1) = cf_coeff(1);
        slope(bIndex, 2) = (cf_confint(2,1) - cf_confint(1,1))/2;
        slope(bIndex, 3) = slope(bIndex, 2)/slope(bIndex, 1);
        y_intercept(bIndex, 1) = cf_coeff(2);
        y_intercept(bIndex, 2) = (cf_confint(2,2) - cf_confint(1,2))/2;
        y_intercept(bIndex, 3) = y_intercept(bIndex, 2)/y_intercept(bIndex, 1);

    end
        [Avg_Slope, Avg_y_intercept] = deal(nan(1,3));
        [Avg_Slope(1), Avg_Slope(2)] = Calc_WeightedMean(slope(:,1), slope(:,2));
        Avg_Slope(3) = Avg_Slope(2)/Avg_Slope(1);
        [Avg_y_intercept(1), Avg_y_intercept(2)] = Calc_WeightedMean(y_intercept(:,1), y_intercept(:,2));
        Avg_y_intercept(3) = Avg_y_intercept(2)/Avg_y_intercept(1);

        if Peak_or_Sum == 1
            analyVar.DecayRateSlope_Peak         = slope;
            analyVar.DecayRate_yIntercept_Peak   = y_intercept;
            analyVar.Avg_Slope_Peak              = Avg_Slope;
            analyVar.Avg_y_intercept_Peak        = Avg_y_intercept;
        else
            analyVar.DecayRateSlope_Sum         = slope;
            analyVar.DecayRate_yIntercept_Sum   = y_intercept;
            analyVar.Avg_Slope_Sum              = Avg_Slope;
            analyVar.Avg_y_intercept_Sum        = Avg_y_intercept;
        end

end
end

