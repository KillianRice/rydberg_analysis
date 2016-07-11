function [ indivDataset ] = DecayRate_Histogram( analyVar, indivDataset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[catDecayRateSlope, catDecayRate_yIntercept] = deal([]);

for mbIndex = 1:analyVar.numBasenamesAtom
    catDecayRateSlope           = cat(1,catDecayRateSlope,indivDataset{mbIndex}.DecayRateSlope(:,1));
    catDecayRate_yIntercept     = cat(1,catDecayRate_yIntercept,indivDataset{mbIndex}.DecayRate_yIntercept(:,1));
end

    Mean_DecayRateSlope = mean(catDecayRateSlope(:,1))
    STD_DecayRateSlope  = std(catDecayRateSlope(:,1))
    
    Mean_DecayRate_yIntercept = mean(catDecayRate_yIntercept(:,1))
    STD_DecayRate_yIntercept  = std(catDecayRate_yIntercept(:,1))
    
    figure(111)
    hist(catDecayRateSlope)
    figure(222)
    hist(catDecayRate_yIntercept)

warning('matlab recommends using histogram(), but it does not work atm, using R2013a')
end

