function [indivDataset] = MCS_Counting_Efficiency(analyVar,indivDataset,avgDataset)

% indivDataset = PeakDensity(analyVar,indivDataset); %extract peak density from data.

indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here
    
end

