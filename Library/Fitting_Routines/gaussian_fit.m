function [amplitude, center, sigma, offset] = gaussian_fit(data_x,data_y,offsetflag)

data_x=reshape(data_x,size(data_x));
data_y=reshape(data_y,size(data_y));%reshape such that is doesn't matter weather the inputs are column or row vectors

if offsetflag
    GaussianFitModel = @(coeffs,x) coeffs(1) .* exp(-(x - coeffs(2)).^2 /(2 * coeffs(3)^2)) + coeffs(4);
else
    GaussianFitModel = @(coeffs,x) coeffs(1) .* exp(-(x - coeffs(2)).^2 /(2 * coeffs(3)^2));
end

%figure out initial guess of the amplitude sign
initAmpSign = sum(abs(data_y))/sum(data_y);

%initAmpSign = sign(sum(data_y)); %alternate way to try to figure out the
%sign

initAmp = initAmpSign*(max(data_y)-min(data_y));%not guessing on the sign at the moment
initOffset = mean([min(data_y);max(data_y)])-initAmpSign*0.5*initAmp;%not guessing on the sign at the moment
initCenter = sum(data_x.*(data_y-initOffset))/sum(data_y-initOffset);%expectation value of data_x, with PDF data_y
initSigma = sqrt(sum((data_x-initCenter).^2 .*(data_y-initOffset)) / sum(data_y-initOffset));% stnd = <x^2>-<x>^2 with PDF y(x)

if offsetflag
    Fitting_Output = NonLinearModel.fit(data_x, data_y, GaussianFitModel,...
    [initAmp,initCenter,initSigma,initOffset],...
    'CoefficientNames',{'Amplitude','Center','Sigma','Offset'});
else
    Fitting_Output = NonLinearModel.fit(data_x, data_y, GaussianFitModel,...
    [initAmp,initCenter,initSigma],...
    'CoefficientNames',{'Amplitude','Center','Sigma'});
end


amplitude   = double(Fitting_Output.Coefficients('Amplitude',{'Estimate','SE'}));
center      = double(Fitting_Output.Coefficients('Center',{'Estimate','SE'}));
sigma       = double(Fitting_Output.Coefficients('Sigma',{'Estimate','SE'}));

if offsetflag
    offset = double(Fitting_Output.Coefficients('Offset',{'Estimate','SE'}));
else
    offset = 0;
end
    
end