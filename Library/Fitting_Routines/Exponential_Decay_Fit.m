function [InitialValue, DecayRate, Offset] = Exponential_Decay_Fit(data_x,data_y,fitOffset)

%fit data to exponential decay

if fitOffset
ExponentialDecayFitModel = @(coeffs,x) coeffs(1)*exp(-coeffs(2)*x)+coeffs(3);
else
ExponentialDecayFitModel = @(coeffs,x) coeffs(1)*exp(-coeffs(2)*x);
end

% numofpoints           =100;
% test_InitialValue     =20;
% test_DecayRate        =50;
% test_Offset           =5;
% test_noisesize        =test_InitialValue/20;
% test_x                =1:numofpoints;
% test_y                =ExponentialDecayFitModel([test_InitialValue, test_DecayRate, test_Offset], test_x) + test_noisesize.*(rand(1,numofpoints)-0.5);   

data_y=reshape(data_y,size(data_x));%reshape such that is doesn't matter weather the inputs are column or row vectors

%figure out initial guess of the amplitude sign
% InitialValueSign_Guess = sum(abs(data_y))/sum(data_y);
InitialValueSign_Guess = 1;
%initAmpSign = sign(sum(data_y)); %alternate way to try to figure out the
%sign

DecayRate_Guess  = 1/max(data_x);

if InitialValueSign_Guess == 1
    InitialValue_Guess  = InitialValueSign_Guess*max(data_y);
    Offset_Guess    = min(data_y);
elseif InitialValueSign_Guess == -1
    InitialValue_Guess  = InitialValueSign_Guess*min(data_y);
    Offset_Guess    = max(data_y);
elseif isnan(InitialValueSign_Guess)
    error('No signal detected in .mcs files')
end

if fitOffset
    Fitting_Output = NonLinearModel.fit(data_x, data_y, ExponentialDecayFitModel,...
    [InitialValue_Guess, DecayRate_Guess, Offset_Guess],...
    'CoefficientNames',{'InitialValue','DecayRate','Offset'});
else
    Fitting_Output = NonLinearModel.fit(data_x, data_y, ExponentialDecayFitModel,...
    [InitialValue_Guess, DecayRate_Guess],...
    'CoefficientNames',{'InitialValue','DecayRate'});
end

InitialValue    = double(Fitting_Output.Coefficients('InitialValue',{'Estimate','SE'}));
DecayRate       = double(Fitting_Output.Coefficients('DecayRate',{'Estimate','SE'}));
if fitOffset
    Offset    = double(Fitting_Output.Coefficients('Offset',{'Estimate','SE'}));
else
    Offset = 0;
end
    
end