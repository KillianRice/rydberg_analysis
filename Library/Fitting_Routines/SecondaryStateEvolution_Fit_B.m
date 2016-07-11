function [ParentDecay, SecondaryDecay, SecondaryOffset] = SecondaryStateEvolution_Fit_B(data_x, data_y, Bare_DecayRate, InitialValue, TimeOffset_Guess)
%fit data to exponential decay

data_y=reshape(data_y,size(data_x));%reshape such that is doesn't matter weather the inputs are column or row vectors

%% Initial Fit Parameter Guesses
% Amplitude_Guess             = 280;
Parent_DecayRate_Guess      = 40E3;
Seondary_DecayRate_Guess    = 30E3;
TimeOffset_Guess            = -TimeOffset_Guess;
tt                          = TimeOffset_Guess;
SecondaryOffset_Guess       = 0;

%% Fit Model
kk = Bare_DecayRate;

% FitModel = @(coeffs,x)...
%     coeffs(3)+InitialValue.*...
%     exp(-kk.*(x-tt)).*...
%     (-1+exp((x-tt).*(kk-coeffs(2)))).*...
%     (kk-coeffs(1))./(kk-coeffs(2)); %coeff(1) = Gamma_parent*Gamma_density, ceoffs(2) = Gamma_density

FitModel = @(coeffs,x)...
    InitialValue.*exp(-kk*tt).*...
    exp(-kk.*(x-tt)).*...
    (-1+exp((x-tt).*(kk-coeffs(2)))).*...
    (kk-coeffs(1))./(kk-coeffs(2)); %coeff(1) = Gamma_parent*Gamma_density, ceoffs(2) = Gamma_density, amplitude is corrected for t0 = tt and not 0s

%% Fitting
   
Fitting_Output = NonLinearModel.fit(data_x, data_y, FitModel,...
    [ Parent_DecayRate_Guess, Seondary_DecayRate_Guess],...
    'CoefficientNames',...
    {'ParentDecay',          'SecondaryDecay'});

% InitialSignal   = double(Fitting_Output.Coefficients('Amplitude',{'Estimate','SE'}));
ParentDecay     = double(Fitting_Output.Coefficients('ParentDecay',{'Estimate','SE'}));
SecondaryDecay  = double(Fitting_Output.Coefficients('SecondaryDecay',{'Estimate','SE'}));
% TimeOffset      = double(Fitting_Output.Coefficients('TimeOffset',{'Estimate','SE'}));
% SecondaryOffset = double(Fitting_Output.Coefficients('SecondaryOffset',{'Estimate','SE'}));
   
end