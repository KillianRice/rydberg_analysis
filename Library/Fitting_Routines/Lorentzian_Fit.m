function [Amplitude, Width, Offset] = Lorentzian_Fit(xData,yData,fitOffset)

%fit data to exponential decay

Amplitude_guess = 100e3;
Width_guess = .33/8;
LineCenter_guess = 0; %MHz, synth frequency of atomic line center
Offset_guess = 0;

if fitOffset
    LorentzianFitModel = @(c,x) c(1)*c(2)^2./(x.^2 + c(2)^2)+c(3);
else
    LorentzianFitModel = @(c,x) c(1)*c(2)^2./(x.^2 + c(2)^2);
end

yData = reshape(yData, size(xData));%reshape such that is doesn't matter weather the inputs are column or row vectors

% lorez = @(c,x) c(1)*c(3)^2./((x-c(2)).^2 + c(3)^2)+c(4);
% fitParams0 = nlinfit(xData, yData, lorez,[Amplitude_guess LineCenter_guess Width_guess Offset_guess]);

% fitParams = nlinfit(xData, yData, LorentzianFitModel,[Amplitude_guess Width_guess]);

if fitOffset
    Fitting_Output = NonLinearModel.fit(data_x, data_y, LorentzianFitModel,...
    [Amplitude_guess, Width_guess, Offset_guess],...
    'CoefficientNames',{'Amplitude','Width','Offset'});
else
    Fitting_Output = NonLinearModel.fit(xData, yData, LorentzianFitModel,...
    [Amplitude_guess, Width_guess],...
    'CoefficientNames',{'Amplitude','Width'});
end

Amplitude   = double(Fitting_Output.Coefficients('Amplitude',{'Estimate','SE'}));
Width       = double(Fitting_Output.Coefficients('Width',{'Estimate','SE'}));
% LineCenter  = double(Fitting_Output.Coefficients('LineCenter',{'Estimate','SE'}));
if fitOffset
    Offset    = double(Fitting_Output.Coefficients('Offset',{'Estimate','SE'}));
else
    Offset = 0;
end

% predX = linspace(min(xData),max(xData),1e3);
% 
% figure;
% hold on
% plot(xData, yData, 'r.')
% % plot(predX, lorez(fitParams0,predX),'b-')
% plot(predX, LorentzianFitModel(fitParams,predX), 'r-')
% hold off

end