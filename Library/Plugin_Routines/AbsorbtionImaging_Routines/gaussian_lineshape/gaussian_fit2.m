function [amplitude, center, sigma, offset] = gaussian_fit2(data_x, data_y, offsetflag, amplitudesign)

data_x=reshape(data_x,size(data_x));
data_y=reshape(data_y,size(data_y));%reshape such that is doesn't matter weather the inputs are column or row vectors

if offsetflag
    GaussianFitModel = @(coeffs,x) coeffs(1) .* exp(-(x - coeffs(2)).^2 /(2 * coeffs(3)^2)) + coeffs(4);
else
    GaussianFitModel = @(coeffs,x) coeffs(1) .* exp(-(x - coeffs(2)).^2 /(2 * coeffs(3)^2));
end

%figure out initial guess of the amplitude sign
initAmpSign = amplitudesign;

%initAmpSign = sign(sum(data_y)); %alternate way to try to figure out the
%sign

initAmp = initAmpSign*(max(data_y)-min(data_y));%not guessing on the sign at the moment
% initOffset = mean([min(data_y);max(data_y)])-initAmpSign*0.5*initAmp;%not guessing on the sign at the moment
initOffset = (data_y(1)+data_y(end))/2; %average of the first and last datapoints should give a decent idea of the offset
initCenter = sum(data_x.*(data_y))/sum(data_y);%expectation value of data_x, with PDF data_y 
initSigma = sqrt(sum((data_x-initCenter).^2 .*(data_y)) / sum(data_y));% stnd = <x^2>-<x>^2 with PDF y(x)

%initCenter = 2092;
%initAmp = 7091;

if offsetflag
    Fitting_Output = NonLinearModel.fit(data_x, data_y, GaussianFitModel,...
    [initAmp,initCenter,initSigma,initOffset],...
    'CoefficientNames',{'Amplitude','Center','Sigma','Offset'});
else
    Fitting_Output = NonLinearModel.fit(data_x, data_y, GaussianFitModel,...
    [initAmp,initCenter,initSigma],...
    'CoefficientNames',{'Amplitude','Center','Sigma'});
end


amplitude   = table2array(Fitting_Output.Coefficients('Amplitude',{'Estimate','SE'}));
center      = table2array(Fitting_Output.Coefficients('Center',{'Estimate','SE'}));
sigma       = table2array(Fitting_Output.Coefficients('Sigma',{'Estimate','SE'}));

if offsetflag
    offset = table2array(Fitting_Output.Coefficients('Offset',{'Estimate','SE'}));
else
    offset = 0;
end
    
end