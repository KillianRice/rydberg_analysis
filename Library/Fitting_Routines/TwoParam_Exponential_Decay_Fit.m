function [DecayRate, Noise_to_Sig] = TwoParam_Exponential_Decay_Fit(data_x,data_y)

%fit data to two parameters exponential fit;decay rate and signal to noise
%ratio times exp

x0 = min(data_x);

ExponentialDecayFitModel = @(coeffs,x) (...
    exp(-coeffs(1)*(x-x0))+coeffs(2)*exp(coeffs(1)*x0)...
    )/...
    (...
    1+coeffs(2)*exp(coeffs(1)*x0)...
    );

data_x  =   reshape(data_x,size(data_x));%
data_y  =   reshape(data_y,size(data_y));%reshape such that is doesn't matter weather the inputs are column or row vectors

DecayRate_Guess  = 1/(30e-6);%guess 30us
Noise_to_Sig = 0; %guess signal to noise is 0

Fitting_Output = NonLinearModel.fit(data_x, data_y, ExponentialDecayFitModel,...
[DecayRate_Guess, Noise_to_Sig],...
'CoefficientNames',{'DecayRate','Noise_to_Sig'});

DecayRate       = double(Fitting_Output.Coefficients('DecayRate',{'Estimate','SE'}));
Noise_to_Sig    = double(Fitting_Output.Coefficients('Noise_to_Sig',{'Estimate','SE'}));
    
end