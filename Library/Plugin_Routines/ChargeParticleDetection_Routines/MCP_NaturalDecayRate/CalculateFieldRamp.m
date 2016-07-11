function [ analyVar ] = CalculateFieldRamp( analyVar )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
bin_time_convert     = analyVar.arrivalTimeBinWidth;%us, 0.5us per time bin
analyVar.ArrivalTime = bin_time_convert*(analyVar.roiStart:analyVar.roiEnd)-0.5*repmat(bin_time_convert,1,length(analyVar.roiStart:analyVar.roiEnd));
analyVar.ArrivalTime = analyVar.ArrivalTime(1,:)';

Saturation = analyVar.MaxFieldRampVoltage;
tau = analyVar.FieldRampTimeConstant;
toff = analyVar.FieldRampTimeOffset;

voltage = @(x) Saturation*(1-exp(-(x-toff)/tau)).*heaviside(x-toff); 
analyVar.ElectricField = (analyVar.Potential2Field*analyVar.FieldCalibration*voltage(analyVar.ArrivalTime));%V cm^-1, electric field at atoms. size; 1 x (# of bins)

end

