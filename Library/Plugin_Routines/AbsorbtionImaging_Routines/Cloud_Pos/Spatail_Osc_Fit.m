function [modOscFit] = Spatail_Osc_Fit(time,pos)
% Function to fit oscillation data
%
% INPUTS:
%   time - time of oscillation (seconds)
%   pos  - spatial position (arb. unit)

%% Fitting function
s2 = @(coeffs,t) (coeffs(2) - exp(coeffs(5).*t).*coeffs(1).*sin(2*pi*coeffs(3).*t + coeffs(4)));

%% Guessing
[peakTime,peakLoc] = findpeaks(smooth(pos),'minpeakdistance',2,'minpeakheight',mean(pos));

offsetGuess  = mean(pos);
AmpGuess     = max(pos) - mean(pos);
TGuess       = mean(diff(time(peakLoc))); 
freqGuess    = 1/(TGuess);
%phaseGuess   = time(peakLoc(1))*2*pi*freqGuess;
phaseGuess   = 2.5;
dampingGuess = 0.1; % Initialize dampingGuess
for dampIter = 2:length(peakTime)
    dampingGuess = dampingGuess + log(peakTime(dampIter-1)/peakTime(dampIter))/(peakLoc(dampIter-1)-peakLoc(dampIter));
end

%% Fitting
%statOpt = statset('RobustWgtFun','bisquare');
[modOscFit] = nlinfit(time,pos,s2,[AmpGuess offsetGuess freqGuess phaseGuess dampingGuess]);

%% Print and Plot results
fprintf('\nFit oscillation frequency is %g Hz\n\n',modOscFit(3))

timeInterp = linspace(time(1),time(end),500);
dataH = plot(time*1e3,pos,'ro',timeInterp*1e3,s2(modOscFit,timeInterp),'b--');
grid on; axis tight
xlabel('Time [ms]','FontSize',24,'FontWeight','Bold')
ylabel('Center Position','FontSize',24,'FontWeight','Bold')
set(dataH(1),'MarkerSize',6,'MarkerFaceColor','r')
set(dataH(2),'LineWidth',2)
end