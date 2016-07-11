function [ axialTrapFreq ] = BEC_Horizontal_Trap_Frequency( analyVar, indivDataset, verticalTrapFreq )
%% BEC_HORIZONTAL_TRAP_FREQUENCY calculates horizontal trap frequencies for
%rotationally symmetric trap given a known vertical trap frequency and a
%BEC time of flight expansion
%   NOTE: THIS CODE ONLY WORKS FOR TIME OF FLIGHT DATA FROM A BEC IN AN
%   AXIALLY SYMMETRIC TRAP.
%   This code uses the Castin-Dum theory of bec expansion from http://journals.aps.org/prl/abstract/10.1103/PhysRevLett.77.5315
%   to calculate the average axial trap frequency of your trap given a
%   known vertical trap frequency.

a0 = analyVar.BohrRadius;
m = analyVar.mass;
hbar = analyVar.hbar;

switch analyVar.isotope
    case 84
        aScatt = 122.7*a0;
    case 86
        aScatt = 823*a0;
    case 88
        aScatt = -1.4*a0;
    otherwise
        error('This code is only valid for bosonic isotopes')
end

timeCell = cell(1,analyVar.numBasenamesAtom); % cell of time values
axialRadiusCell = cell(1,analyVar.numBasenamesAtom); % cell of axial radius values
verticalRadiusCell = cell(1,analyVar.numBasenamesAtom); % cell of vertical radius

for basenameNum = 1:analyVar.numBasenamesAtom
    
    timeCell{basenameNum} = indivDataset{basenameNum}.imagevcoAtom;         %time of flight in milliseconds
    axialRadiusCell{basenameNum} = indivDataset{basenameNum}.cloudRadX;     %axial cloud radius in microns
    verticalRadiusCell{basenameNum} = indivDataset{basenameNum}.cloudRadY;  %vertical cloud radius in microns
    
    meanNum = mean(indivDataset{basenameNum}.winTotNum);                    %average number of atoms used to calculate TF radius
    
    %% Theory
    % Thomas-Fermi radius is defined as 
    % $$R_{TF} = a_{ho} (15 N^{1/5}) \frac{a}{a_{ho}$$
    % where
    % $$ a_{ho} = \sqrt{ \frac{\hbar}{m \omega} } $$
    % for a given direction, and $a$ is the s-wave scatering length.
    %
    % Given that the only free parameter is the axial trap frequency we
    % can define the axial Thomas Fermi radius as
    % $$ R_{TF}^{ax} = \sigma_0 \omega_{ax}^{-2/5} $$
    % where $\sigma_0$ is
    % $$ \sigma_0 = (15 N \hbar^2 a / m^2)^{1/5} $$
    
    sigma_0 = (15 * meanNum * hbar^2 * aScatt / m^2)^(1/5) * 10^6; % um s^(-2/5)
    xdata = timeCell{basenameNum}*10^-3; % convert to seconds
    ydata = [axialRadiusCell{basenameNum}; verticalRadiusCell{basenameNum}]'; % already in um don't * 10^-6; % convert to meters
    %zdata = verticalRadiusCell{basenameNum}*10^-6;
    
    % initial guesses
    init_omega_r = 2*pi*200; % s^-1
    init_omega_z = 2*pi*150; % s^-1
    initialGuess = [init_omega_r init_omega_z];
    
    %define the model function to be fit
    modelFun = @(b, t) CastinDumODEWrapper(b, t, sigma_0);
    
    
    [CastinDumModel, resnorm, residual, exitflag, output, lambda, J] = lsqcurvefit(modelFun,initialGuess,xdata,ydata);

    conf = nlparci(CastinDumModel,residual,'jacobian',J); %obtain 95% confidence intervals
    err = (conf(:,2)-conf(:,1))/4; % compute sigma from 95% interval
    

    
    
    axialTrapFreq = CastinDumModel(1);
    verticalTrapFreq = CastinDumModel(2);
    t = linspace(1e-8,xdata(end),1000)';
    
    fit = modelFun(CastinDumModel, t);
    figure
    hold on
    plot(t,fit(:,1),'r-')
    plot(t,fit(:,2),'b-')
    plot(xdata,ydata(:,1),'ro')
    plot(xdata,ydata(:,2),'bs')
    xlabel('Time (s)')
    ylabel('Cloud Size (m)')
    legend('Axial Fit', 'Vertical Fit', 'Axial Data', 'Vertical Data','Location','northwest')
    title(['Castin-Dum Expansion Fit: \omega_{\perp} = ' '2pi x (',num2str(axialTrapFreq/2/pi),' +/- ',num2str(err(1)/2/pi),' Hz)'])
    hold off
    
    disp(['Axial trap frequency = 2pi x (',num2str(axialTrapFreq/2/pi),' +/- ',num2str(err(1)/2/pi),' Hz)']);
    disp(['Vertical trap frequency = 2pi x (', num2str(verticalTrapFreq/2/pi),' +/- ',num2str(err(2)/2/pi),' Hz)']);


end































