%function [fitTime,fitGndState,rabiFreq,decohFreq] = fitRabiOsc(time,atomPop,gammaLife,gammaCoh,delta)
function [fitTime,fitGndState,fitExtState,rabiFreq,decohFreq,totNumFit] = fitRabiOsc(time,atomPop,rabiFixParams,rabiFitParams)
%Function to fit rabi oscillations by solving thw two level optical bloch equations with damping
%
% INPUTS:
%   time        - vector of time points where Rabi oscillations measurements were obtained
%   atomPop     - vector of Rabi oscillation ground state population data
%                 normalized to total population (i.e. max population = 1)
%
% OUTPUTS:
%   fitTime     - 
%   fitGndState -
%   rabiFreq    -
%   decohFreq   -

%% Initalize fixed parameters
% Fixed physical constants
gammaLife = rabiFixParams.gammaLife; % [s^-1] natural decay rate
initRho = rabiFixParams.initRho; % [pgg; pee; pge; peg]
rabiPulseOffset = rabiFixParams.pulseOffset; % [s] Offset time of Rabi pulse
state = rabiFixParams.state;

%% Initialize fit parameters
totNumFit = rabiFitParams.totNumFit;    % Total atom num
deltaFit = rabiFitParams.delta;         % [s^-1] detuning
gammaDecFit = rabiFitParams.gammaDec;   % [s^-1] decoherence rate

% Smooth data and guess Rabi frequency
smoothSpan = 5; % Smoohting span
minPeakDist = 3;
smoothNum = smooth(atomPop,smoothSpan);
[~,peakPos] = findpeaks(smoothNum,'minpeakdistance',minPeakDist);
omegaRabi = 2*pi/mean(diff(time(peakPos))); % [s^-1] guess Rabi rate from peak positions

%% Adjust data set for fitting
fitTime = [0;time + rabiPulseOffset];

switch rabiFixParams.state
    case 1 % If the ground state is measured
        fitAtomPop = [initRho(1);atomPop];
    case 2 % If the excited state is measured
        fitAtomPop = [initRho(2);atomPop];
    otherwise
        error('Not a valid state selection.');
end

%% Fitting Routine
% Compile fixed parameters into a structure to pass to fitFunc
fixParams = struct('gammaLife',gammaLife,...
                  'initRho',initRho,...
                  'rabiPulseOffset',rabiPulseOffset,...
                  'state',state);

% Compile guess parameters into vector
guessParams = [omegaRabi,gammaDecFit,totNumFit,deltaFit];

% Make anonymous function for fitting (see NonLinearModel.fit help about
% order of (coeffs,time)
fitCall = @(coeffs,time) fitFunc(time,fixParams,coeffs(1),coeffs(2),coeffs(4),coeffs(3));

% %[oscCoeffsModel,resnorm,res] = lsqcurvefit(fitCall,guessParams,fitTime,fitAtomPop);
[oscCoeffsModel] = lsqcurvefit(fitCall,guessParams,fitTime,fitAtomPop);



rabiFreq = oscCoeffsModel(1);
decohFreq = oscCoeffsModel(2);
totNumFit = oscCoeffsModel(3);
deltaFit = oscCoeffsModel(4);

% oscCoeffsModel = NonLinearModel.fit(fitTime,fitAtomPop,fitCall,guessParams,...
%                                     'CoefficientNames',{'Rabi Freq.','GammaCoh','Num','Delta'});
% % Save coefficients into variables
% rabiFreq  = oscCoeffsModel.Coefficients.Estimate('Rabi Freq.') % [s^-1] Rabi rate
% decohFreq = oscCoeffsModel.Coefficients.Estimate('GammaCoh') % [s^-1] decoherence rate
% totNumFit = oscCoeffsModel.Coefficients.Estimate('Num') % detuning
% deltaFit = oscCoeffsModel.Coefficients.Estimate('Delta') % detuning

rabiFreq/2/pi
decohFreq/2/pi
totNumFit
deltaFit/2/pi

%% Get fit oscillations from OBE
fitTime     = linspace(0,max(fitTime),1e3)';
fixParams.state = 1;
fitGndState = fitFunc(fitTime,fixParams,rabiFreq,decohFreq,deltaFit,totNumFit);

fixParams.state = 2;
fitExtState = fitFunc(fitTime,fixParams,rabiFreq,decohFreq,deltaFit,totNumFit);

end

function output = fitFunc(tRange,fixParams,omegaRabi,gammaCoh,delta,num)
    gammaLife = fixParams.gammaLife;
    initRho = fixParams.initRho;
    
    [~,rho] = ode45(@(t,rho) funcOBE(t,rho,omegaRabi,gammaLife,gammaCoh,delta),tRange,initRho);
    output = num*rho(:,fixParams.state); % Solve for ground state atom population
end