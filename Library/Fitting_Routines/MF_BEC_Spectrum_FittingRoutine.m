function [Fit_Aeff] = MF_BEC_Spectrum_FittingRoutine(data_x,data_y, const1, const2)

data_x=reshape(data_x,size(data_y));
% data_y=reshape(data_y,size(data_y));%reshape such that is doesn't matter weather the inputs are column or row vectors

Model = @(coeffs,x) const1*coeffs(1)^-2*x.*(1-const2*coeffs(1)^-1*x).^0.5;

a0 = 5.2917721067e-11; % m, Bohr radius
initAeff = -8*a0;%not guessing on the sign at the moment

Fitting_Output = NonLinearModel.fit(data_x, data_y, Model,...
[initAeff],...
'CoefficientNames',{'Aeff'});

Fit_Aeff   = double(Fitting_Output.Coefficients('Aeff',{'Estimate','SE'}));

end