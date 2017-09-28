function [Harmfit latticedepth] = HarmFitAndLatticedepth(x,y,analyVar)
% Function to fit oscillation data and extract lattice depth from the frequency

%% Fitting function
% Projection of evolution in lattice onto plane wave states
% Jim has a derivation
s2 = @(coeffs,t) (coeffs(2) - exp(coeffs(5)*t).*coeffs(1).*cos(coeffs(3)*t + coeffs(4)));

%% Initilize lattice parameters
qReduced      = 0;
numPlaneWaves = 100; % Provides better accuracy
minBnds       = [0 100]; % Bounds on 1D search for lattice depth

%% Guessing
[time,data] = findpeaks(y,'minpeakdistance',2,'minpeakheight',mean(y));

offsetGuess  = mean(y);
AmpGuess     = max(y) - mean(y);
TGuess       = mean(diff(x(data))); %(xpeaks(5)-xpeaks(1))/2
omegaGuess   = 2*pi /(TGuess);
phaseGuess   = -x(data(1))*omegaGuess;
dampingGuess = 0; % Initialize dampingGuess
for dampIter = 2:length(time)
    dampingGuess = dampingGuess + log(time(dampIter-1)/time(dampIter))/(data(dampIter-1)-data(dampIter));
end

%% Fitting
statOpt = statset('RobustWgtFun','bisquare');
[Harmfit] = nlinfit(x',y',s2,[AmpGuess offsetGuess omegaGuess phaseGuess dampingGuess],statOpt);

%% Print and Plot results
fprintf('\n\nFit lattice frequency is %g kHz\n',Harmfit(3)/(2*pi)*1e-3)

xinterp = linspace(x(1),x(end),500);
hold on; dataH = plot(xinterp*1e6,s2(Harmfit,xinterp),'b--'); hold off;
set(get(get(dataH,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')

%% Finding the lattice depth based on the band gap
% Find bandgap in terms of recoils
Bandgap = (Harmfit(3)*analyVar.hbar)/analyVar.RecoilEnergy; %Bandgap in units of recoil energy

% Minimization routine to find the lattice depth that produces the measured bandgap
latticedepth = fminbnd(@(x) abs(getLatGap(qReduced,x,numPlaneWaves) - Bandgap),minBnds(1),minBnds(2))
end

function lowGap = getLatGap(qReduced,latDepth,numPlaneWaves)
% Helper function to find bandgap
% This function returns bandgap at specified depth
    latStruct = findLatHam(qReduced,latDepth,numPlaneWaves);
    lowGap = diff(latStruct.BandEn([2 0]));
end