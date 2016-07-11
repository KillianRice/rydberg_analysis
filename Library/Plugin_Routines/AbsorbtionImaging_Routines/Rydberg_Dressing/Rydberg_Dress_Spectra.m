function Rydberg_Dress_Spectra(analyVar,fieldIndx,rabiFreq, lineCenter, fullWidth)
% Experiment specific function detailing experimental parameters pertaining
% to the Rydberg dressing experiment begun in 2013.
% This function will calculate and plot parameters specific to the rydberg
% experiment

%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%
% OUTPUTS:
%
%% Experimental conversions 
redWaist  = 300e-6;     uvWaist   = 600e-6;   % meters
redPDconv = 1;          uvPDconv  = 1;       % Watts/Volt

%% Finding Unique powers
if fieldIndx == 2
    % returns the first unique value of each set to match the number of spectra
    uniqPow  = cellfun(@(x) x(1),analyVar.posOccurUniqVar);
else 
    % If scans treated individually return all powers
    uniqPow  = 1:analyVar.numBasenamesAtom;
end

%% Calculations to find intensity;
redInten = analyVar.redPower(uniqPow);
uvInten  = analyVar.uvPower(uniqPow);

%% Red power vs. linewidth
figNum      = 156;
data(:,1)   = redInten;
data(:,2:3) = fullWidth*1e-6;
labels{1}   = '689 Power [V]';
labels{2}   = 'Width [MHz]';
menuBar     = 'Red power vs. linewidth';
default_spectrum_plot(analyVar,figNum,data,labels,menuBar)

%% UV power vs. linewidth
figNum      = 157;
data(:,1)   = uvInten;
data(:,2:3) = fullWidth*1e-6;
labels{1}   = 'UV Power [V]';
labels{2}   = 'Width [MHz]';
menuBar     = 'UV power vs. linewidth';
default_spectrum_plot(analyVar,figNum,data,labels,menuBar)

%% Total power vs. linewidth
figNum      = 158;
data(:,1)   = redInten.*uvInten;
data(:,2:3) = fullWidth*1e-6;
labels{1}   = 'I_1 I_2 [V^{2}]';
labels{2}   = 'Width [MHz]';
menuBar     = 'Total power vs. linewidth';
default_spectrum_plot(analyVar,figNum,data,labels,menuBar)

%% Red power vs. Line Center
figNum      = 256;
data(:,1)   = redInten;
data(:,2:3) = lineCenter*1e-6;
labels{1}   = '689 Power [V]';
labels{2}   = 'Line Center [MHz]';
menuBar     = 'Red power vs. Line Center';
default_spectrum_plot(analyVar,figNum,data,labels,menuBar)

%% UV power vs. Line Center
figNum      = 257;
data(:,1)   = uvInten;
data(:,2:3) = lineCenter*1e-6;
labels{1}   = 'UV Power [V]';
labels{2}   = 'Line Center [MHz]';
menuBar     = 'UV power vs. Line Center';
default_spectrum_plot(analyVar,figNum,data,labels,menuBar)

%% Sqrt(Total Power) vs. 2 photon Rabi Freq
figNum      = 358;
data(:,1)   = sqrt(uvInten.*redInten);
data(:,2:3) = rabiFreq;
labels{1}   = 'sqrt(I_1 I_2) [V]';
labels{2}   = 'Two Photon Rabi Frequency [s^-1]';
menuBar     = 'Sqrt(Total Power) vs. 2 photon Rabi Freq';
default_spectrum_plot(analyVar,figNum,data,labels,menuBar)

%% 2 photon Rabi Freq vs. Linewidth
figNum      = 359;
data(:,1)   = rabiFreq(:,1);
data(:,2:3) = fullWidth*1e-6;
labels{1}   = 'Two Photon Rabi Frequency [s^-1]';
labels{2}   = 'Width [MHz]';
menuBar     = '2 photon Rabi Freq vs. Linewidth';
default_spectrum_plot(analyVar,figNum,data,labels,menuBar)

%% Rydberg Atom Density vs. Linewidth
% 
% v1 = 21.34*10^-6 * (min(xsizetemp).*10^-6).^(3/2);
% rydberglifetime = 1/2*1./(2*pi*2.*sigmaMHz*1e6)';
% rydbergdensity=(amp(:).*rydberglifetime./(v1.*exposuretime.*10^-3))./10^6;
% 
% figure(400)
% plot(rydbergdensity,2.*sigmaMHz,'o','Color',COLORS(1,:),'MarkerSize',9,'LineWidth',2);
% hold on
% grid on
% xlabel('Rydberg Atom Density [cm^{-3}]','FontSize',fontsize,'FontWeight','bold');
% ylabel('Width [MHz]','FontSize',fontsize,'FontWeight','bold');
% set(gca,'FontSize',fontsize-4,'FontWeight','bold');

end

