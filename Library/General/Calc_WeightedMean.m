function [ Avg_Data_Array, Avg_Data_Array_error ] = Calc_WeightedMean( Data_Array, Data_error_Array, Averaging_Dimension )
%UNTITLED2 Calculate weighted mean using the standard deviation for weights
%   Detailed explanation goes here


% https://en.wikipedia.org/wiki/Weighted_arithmetic_mean

weight = Data_error_Array.^-2;

Avg_Data_Array = sum(Data_Array.*weight,Averaging_Dimension)./sum(weight,Averaging_Dimension);
Avg_Data_Array_error = (1./sum(weight,Averaging_Dimension)).^0.5;

end

