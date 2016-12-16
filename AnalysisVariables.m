function analyVar = AnalysisVariables()
% hello world
% Master file to control all similar variables to be passed between
% background analysis, cloud fitting, and graphing routines.
%
% INPUTS:
%   none
%
% OUTPUTS:
%   analyVar - Structure containing all the variables defined in
%              this function.
%
% MISC:
%#ok<*STRNU>
%#ok<*NASGU> - suppress all instances of 'this variables may not be used' 
%              because the who() builds a structure with all variables
%              defined in the workspace.
%
% NOTE:
%    - LatticeAxesFit follows form of [Origin, +Z, -Z, +X, -X, +Y, -Y] where 
%           - Z is the axis in and out of the imaging plane ----------- Arm B
%           - X is the axis nearly perpendicular to the imaging plane - Arm A
%           - Y is the axis vertical to the imaging plane ------------- Arm C
%    - Labels generated by create_plot_AtomNum expect this ordering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Realtime and Acquisition Settings
% Real time fitting? (Used to provide quick analyze during data taking)
quickFit = 1;     % 1 to limit background evaluations, 0 for no limit.


%% Independant Variable
Choose_Var_from_File = 0; %if 1, prompt user to select file containing values of the independant variable to plot against.

%% Load in data from .mat instead of batch files
    LoadData = 0; %set to 1 to use already existing .mat files to load data instead of loading in from the .mcs files
    DataName = ['1819' '.mat'];
%% LINESHAPE FITTING
% Called within imagefit_ParamEval
% Allows secondary analysis of parameters extracted from the number distribution fit
% Functions ahould expect input arguments of analyvar, indivDataset, and avgDataset from imagefit_ParamEval
%
% Functions are selected by the booleans in lcl_logicFitLine (i.e. [1 0 0 0] triggers lcl_validFitLine(1))
%   Spectrum_Fit - Fits spectrum to gaussian (or lorentzian) and estimates rabi freq. based on width
%   KapitzaDirac - Fits number oscillations in 2hk peaks to calibrate lattice depth
%   Cloud_Pos    - Plot spatial center of cloud (option to fit oscillation for trap freq. measurements)
% Future Plans
%   lifetime_n   - (n = 1,2,3) Fits number decay to decaying exponential with n-body decay constant
lcl_validFitLine = {'Spectrum_Fit',...                  %01
                    'KapitzaDirac',...                  %02
                    'Cloud_Pos',...                     %03
                    'Rydberg_Dress',...                 %04
                    'Magnetic_Lifetime',...             %05
                    'Loading_Rate',...                  %06
                    'TOF_Temperature',...               %07
                    'Phase_Space_Density',...           %08
                    'Rabi_Oscillations',...             %09
                    'MCS_Spectrum_Fit',...              %10 %deprecated 2016.12.13 %use for lifetime paper
                    'MCS_High_Resolution',...           %11 %deprecated 2016.12.13
                    'MCS_UVFrequency_Spectrum',...      %12 %deprecated 2016.12.13
                    'MCS_UV_Spectrum_Indiv_SFI',...     %13 %deprecated 2016.12.13
                    'MCP_PulseHeightDistribution',...   %14 %deprecated 2016.12.13
                    'gaussian_lineshape',...            %15
                    'MCS_SFI_Dynamical_Evolution',...   %16 %deprecated 2016.12.13
                    'MCS_Indiv_UV_Spectrum',...         %17 %deprecated 2016.12.13
                    'Cloud_Density'...                  %18
                    'MCP_Signal_vs_Density'...          %19 %deprecated 2016.12.13
                    'BEC_Horizontal_Trap_Frequency',... %20
                    'MCS_Integrated_SFI_Spectrum',...   %21 Plot integrated sfi vs. independent variable
                    'MCS_Cum_SFI',...                   %22 Plot sum of all sfi from one scan vs time
                    'MCS_Cum_SFI_Field',...             %23 Plot sum of all sfi from one scan vs field/voltage
                    };
plugInVec = [21 23];

UseImages = 0;%set to 1 to load image data. Set to 0 when images are not needed (possibly for MCS analysis).
UseMCS = 1; % set to 1 to use mcs data, set to 0 to ignore mcs data
% Common Plotting flags

    lcl_logicFitLine = zeros(1,length(lcl_validFitLine));
if isempty(plugInVec )~= 1
    lcl_logicFitLine(plugInVec) = 1;
end

% EXPERIMENTAL OPTIONS AND SETTINGS
%%-----------------------------------------------------------------------%%
%%%% Atom cloud properties
sampleType     = 'Thermal';  % Options are Thermal, BEC, or Lattice
isotope        = 84; % Isotope mass used to select applicable models for fitting. Options are 84, 86, or 88 (87 not currently supported)
detuning       = 0;  % s^-1, image beam detuning (as of 7/1/15)
pureSample     = 0;  % Flags whether BEC samples have a thermal fraction present or not (ignored for Thermal and Lattice samples)
winToFit       = {'Central'}; % Specify which windows to fit, this generates the vector LatticeAxesFit
binHorizontal  = 1;%binning done by camera when taking images
binVertical    = 1;
matrixSize     = [1002/binVertical 1004/binHorizontal]; % Matrix size of camera output
CameraMag      = 1;  % Currently can do 1x or 4x magnification (input 1 or 4)
CCDbinning     = 1;  % Number of pixels binned when first recording data
TempXY         = 0; % set to 1 if Temp will be the geometric mean of TempX and TempY, otherwise Temp will equal TempX

%%%% Rydberg properties
quantumNumberN = 72; %principal quantum number n
state = '3S1'; %term symbol for rydberg state (2S+1)L(J)
quantumDefect = 0;
switch state
    case '3S1'
        quantumDefect = 3.371;
    case '1S0'
        quantumDefect = 3.26896;
    case '1D2'
        quantumDefect = 2.3807;
    case '3D1'
        quantumDefect = 2.658;
    case '3D2'
        quantumDefect = 2.636;
    case '3D3'
        quantumDefect = 2.63;
end

nStar = quantumNumberN - quantumDefect;
mcs_roi = [8 -1];

positive_ramp_file = './ramps/n60/100v_pos.csv';
negative_ramp_file = './ramps/n60/100v_neg.csv';
        
%% BACKGROUND SUBTRACTION ROUTINE
%%-----------------------------------------------------------------------%%
varianceLim  = .995; % Amount of variance to choose principal component vectors for background subtraction
dimReduceLim = 10; % Maximum number of states where all states are used, over this variance up to varianceLim is used  

%% 2D NUMBER DISTRIBUTION FITTING ROUTINE
%%-----------------------------------------------------------------------%%
% Fitting flags
weightPeak      = 0; % 1 to weight sample peak with normalized error relative to average pixel value (get_fit_image)
fitSmoothOD     = 0; % Boolean to average data with smoothFilt, could make it easier to fit

% Fitting specific values
softwareBinSize = 1; % Number of pixels square to bin (i.e. area of bin, in # of pixels = softwareBinSize*softwareBinSize (TrimAndBin)
cutBorders      = 0; % number of column and rows to trim on either side of the data matrix (TrimAndBin)
NoiseNumVec     = 5; % number of column and rows at the corners to find the uncertainties/noise (get_fit_params)
gaussFiltAmp    = 7; % Amplitude of gaussian filter applied when finding initial guesses for fitting (get_fit_params)
gaussFiltSig    = 2; % Width of gaussian filter applied when finding initial guesses for fitting (get_fit_params)
ampBimodalGuess = 0.13; % When fitting bimodal feature, initial guess of thermal amplitude is this percentage of BEC peak (get_fit_params)
smoothFilt      = @(x,y) medfilt2(x,y); % Smooth noise on image to evaluate fit (create_plot_fitEval)
smoothFiltMat   = 2*[1 1];                % Defines the moving box that the smoothing filter effects
% Bounds on fit parameters 
lsqAmpBnd       = {0 10}; % Amplitude bounds 
lsqSigBnd       = {0 'analyVar.cloudWinRadAtom'}; % Width bounds - upper bound is window radius (entire cloud must be in view)
lsqCntBnd       = {0 '2*analyVar.cloudWinRadAtom + 1'}; % Peak position - upper bound is window radius
lsqLinBnd       = {-Inf Inf}; % Linear background terms bound, all allowed to range from 0 to Inf

%% PARAMETER EVALUATION AND PLOTTING ROUTINE
% Parameters are only extracted when it makes sense to plot them (i.e. BEC
% number is plotted for condensates but ignored for thermal gases)
%%-----------------------------------------------------------------------%%
% Flag to Load Image Data

SavePlotData  = 1; % Boolean to allow aggregation of variables from plotting into output structure
plotFitEval   = 0; % Boolean to display plots showing the fit, cloud evolution, and residuals
plotInstParam = 1; % Boolean to extract and display 1st order parameters such as temperature, size, and number
plotMeanParam = 1; % Boolean to average instantaneous parameters across multiple scans
plotFitLine   = 1; % Boolean to extract higher order parameters by fitting instantaneous parameters

%% PicoScope
plotCounts = 0; % look for scope traces from picoscope
SumCounts = 0;

%% Photon Counter
plotCounts_SR400 = 0;%photon counter


% Plotting presentation
TimeOrDetune  = 'SpecSynth'; % Valid options are 'Time', 'Detuning', 'Repetition', 'Voltage', 'Frequency'

titleFontSize = 18;
axisfontsize  = 14;
markerSize    = 10;

scalesize = 1.5; % set to one for PRL size plots
FCmarkerSize    = 3*scalesize;
FCaxisfontsize  = 8*scalesize;
FClatexfontsize = 10*scalesize;
FCtitleFontSize = 12*scalesize;
FCfigPos        = [100, 100, 350, 250]*scalesize;
FCaxesPos       = [047, 035, 290, 190]*scalesize;

condOffset    = 0.5;    % Add offset to condensate cross-section to separate from X cut
ylimMeanTrimPercent = .25;  % Percentage used in meantrim for determining mean away from outliers for y limits
yPlotLimBounds      = 1.5; % +/- this percentage around mean for y limits
COLORS  = [...
    1 .63 0; .85 0 .3; .37 0 .8; 0 .53 .75;  0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0;    1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    0 0 0; 1 0 .25; 0 .75 0; .5 0 .5; 0 0 1; 0 .75 0; 0 .75 .75; .5 0 .5; .75 0 .75;0 0 1;...
    
    ];
MARKERS = {'-o','-s','-^','-d','-v','-p','-<','-h','->','-x','-*','-+','-o','-s','-^','-d','-v','-p','-<','-h','->','-x','-*',...
    '-+','-o','-s','-^','-d','-v','-p','-<','-h','->','-x','-*','-+','-o','-s','-^','-d','-v','-p','-<','-h','->','-x','-*','-+'};
MARKERS2 = {...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +',...
    ' o',' s',' ^',' d',' v',' p',' <',' h',' >',' x',' *',' +'};
%% WARNING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Do not modify variables below this line without knowing what you are  --%
%-- doing. Modification may result in failure of the analysis routine.    --%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERAL OUTPUT PARAMETER FILENAMES
%%-----------------------------------------------------------------------%%
ODimageFilename       = 'ODimagebatch.txt';
paramFitFileExt       = '.txt';
paramFitFilename      = 'FitParams';
BECNumCombineFilename = 'BEC-Holdtimes-Mean_Number-RMS_error.txt';

%% PHYSICAL QUANTITIES
%%-----------------------------------------------------------------------%%
mass            = isotope*1.672621777e-27;  % kg, strontium mass
kBoltz          = 1.3806488e-23;            % J K^-1, Boltzmann's Constant
hbar            = 1.054571726e-34;          % J s, Reduced Planck's Constant
lambda          = 461e-9;                   % m, Sr 1S0->1P1 wavelength
lambdaLat       = 532e-9;                   % m, Lattice wavelength
BohrRadius      = 5.2917721092e-11;         % m, Bohr Radius in meter
NaturalWidth    = 2*pi*30.5e6;              % s^-1, 1S0->1P1 FWHM
CrossSection    = 3*lambda^2/(2*pi);        % m^2, atom-photon cross-section
AbsCross        = CrossSection*1/(1 + (2*detuning/NaturalWidth)^2); %%% Pascal's PhD thesis (Eq. B.2)
RecoilEnergy    = hbar^2/(2*mass)*(2*pi/lambdaLat)^2; % One photon recoil energy of the lattice wavelength
Gravity         = 9.8;                      %m/s^2, acceleration due to gravity
Epsilon0        = 8.854187817e-12;          %F/m, permittivity of free space
SpeedOfLight    = 2.99792458e8;             %m/s, speed of light
aBohr           = 5.2917721067e-11;         %m, Bohr radius
QDefect         = 3.372;                    %unitless, Quantum Defect for 3S0 states, n>20

switch isotope
    case 84
        a84 = 123*aBohr;                    %m, 84Sr scattering length
end

%%-----------------------------------------------------------------------%%
%Parameters needed to calculate phase space density in the seconadary
%fitting routing in Phase_Space_Density.m

ODTPowerConversion = 0.77; %W/V, IR power going into the chamber per volt
%setpoint for V2 (V2 is the power lock setpoint which controls the voltage 
%going to VCA-2 which controls the overall RF power in the multi frequency 
%AOM setup). Got this number from fitting with VCA-1=0V; had single RF
%frequency going to AOM. VALID UP TO V2=3.7V
wx0A    =   57.4E-6;%m, waist of horizontal axis of first arm of ODT 
wz0A    =   55.1E-6;%m, waist of vertical axis of first arm of ODT     
wy0B    =   62.9E-6;%m, waist of horizontal axis of second arm of ODT 
wz0B    =   52.6E-6;%m, waist of vertical axis of second arm of ODT 
IRwavelength = 1064E-9;%m, wavelength of IR laser
Polarizability0 = 4*pi*Epsilon0*BohrRadius^3; %F*m^2, atomic unit of 
% polarizability
Polarizability  = 236*Polarizability0;%F*m^2, polarizability of 1S0 state 
% at 1064nm, from Science 320, 1734 (2008)

%% ADDITIONAL PLOTTING VARIABLES
% Variables here may not be changed often so moved lower for the higher priority variables near the top
%%-----------------------------------------------------------------------%%
% Target specific plotting flags (all flags are booleans)
plotRawImage  = 0;             % Processed raw images (trimmed and binned) - needs implementation

plotNum       = plotInstParam; % Number in each image
plotMeanNum   = plotMeanParam; % Mean number averaged across similar scans

plotTemp      = plotInstParam; % Temperature of each image
plotMeanTemp  = plotMeanParam; % Mean temperature averaged across similar scans

plotSize      = plotInstParam; % Cloud radius of each image
plotMeanSize  = plotMeanParam; % Mean radius averaged across similar scans

plotTrapFreq     = plotInstParam; % Geometric average of trap frequencies
plotMeanTrapFreq = plotMeanParam; % Mean geometric average of trap frequencies

plotPhaseSpace = plotInstParam; %Phase Space Density of each point given ODT evaporation parameters

% Figure assignment
% Assign base figure number used in the imagefit routine (if assigning figures for lineshape fitting plots please consult
% this list first)
% Actual figure numbers will iterate from the base number
figNum.atomEvol = 1000;
figNum.fig2DFit = 1100;
figNum.figRes   = 1200;
figNum.fig1DFit = 1300;
figNum.fig1DBEC = 1400;
figNum.atomNum  = 2000;  figNum.meanNum  = 12000;
figNum.condNum  = 2100;  figNum.meanBEC  = 12100;
figNum.condFrac = 2200;  figNum.meanFrac = 12200;
figNum.atomSize = 3000;  figNum.meanSize = 13000;
figNum.atomTemp = 4000;  figNum.meanTemp = 14000;
figNum.trapFreq = 5000;  figNum.meanFreq = 15000;
figNum.picoCountsA = 16000; figNum.picoCountsB = 17000;
figNum.MCSCounts = 18000; figNum.MCSTraces = 19000;

%% LABVIEW BATCHFILE VARIABLES
%%-----------------------------------------------------------------------%%
% Variables defined in lines of each dataset in the master batch file.
lcl_masterBatchAtomVar = {
    'basenamevectorAtom'    % 01 name of data set
    'timevectorAtom'        % 02 four digit time stamp
    'ScanIDVarAtom'         % 03 ID used for averaging
    'redPower'              % 04
    'uvPower'               % 05
    'expTime'               % 06
    'droptimeAtom'          % 07 s, drop time before imaging
    'roiWinRadAtom'         % 08 pixels, radius of atoms
    'cloudWinRadAtom'       % 09 pixels, radious of image to crop (with background)
    'cloudColCntrAtom'      % 10 pixel, horizontal center of image to crop
    'cloudRowCntrAtom'      % 11 pixel, veritcal center of image to crop
    'mcs_roiStart'          % 12 first bin of MCS roi
    'mcs_roiEnd'            % 13 last bin of MCS roi
    };

lcl_masterBatchAtomVar = lcl_masterBatchAtomVar';
lcl_masterBatchBackVar = {'basenamevectorBack' 'unusedBack'};

% Variables defined in lines of the individual batch files
indivBatchAtomVar = {
    'fileAtom' %                    01  name of the image file
    'imagevcoAtom' %                02  corresponding value of the independent parameter
    'principleQuantumAtom' %        03  principle quantum number n
    'angularQuantumAtom' %          04  principle quantum number \el
    'ODTHold' %                     05  odt hold time
    'RampDelay' %                   06  rydberg hold time for lifetime measurements
    'VCA_1_Voltage' %               07  3 beam ODT vca 1 static voltage; control relatice power between 3 beams
    'VCA_2_Voltage' %               08  3 beam ODT VCA 2 static voltage; control absolute power of all 3 beams
    'initialTrapDepthAtom' %        09  initial trap depth in volts before evaporation
    'TrapPower' %                   10  final trap depth in volts after evaporation
    'synthFreq' %                   11  synth frequency driving 640nm cat's eye aom
    'numberAtom' %                  12  number of atoms measured by labview
    'tempXAtom' %                   13  TOF x temperature measured by labview
    'tempYAtom' %                   14  TOF y temperature measured by labview
    'fugacityguessAtom' %           15  left constant
    'sigParamAtom' %                16  left constant
    'sigBECParamAtom' %             17  left constant
    'WeightedBECPeakAtom' %         18  left constant
    'BECamplitudeParameterAtom' %   19  left constant
    };
indivBatchBackVar = {
    'fileBack'
    'imagevcoBack'
    'principleQuantumBack' %principle quantum number n
    'angularQuantumBack' %principle quantum number \el
    'ODTHoldTimeBack' %odt hold time
    'RydbergHoldTimeBack' %rydberg hold time for lifetime measurements
    'VCA_1_VoltageBack' %3 beam odt vca 1 static voltage
    'VCA_2_VoltageBack' %3 beam ODT VCA 2 static voltage
    'initialTrapDepthBack' %initial trap depth in volts before evaporation
    'finalTrapDepthBack' %final trap depth in volts after evaporation
    'uvSynthFreqBack' %synth frequency driving 640nm cat's eye aom
    'numberBack' %number of atoms measured by labview
    'tempXBack' %TOF x temperature measured by labview
    'tempYBack' %TOF y temperature measured by labview
    'fugacityguessBack' %left constant
    'sigParamBack' %left constant
    'sigBECParamBack' %left constant
    'WeightedBECPeakBack' %left constant
    'BECamplitudeParameterBack' %left constant
    };
        
%% Choose windows to analyze
% Follows form of [Origin, +Z, -Z, +X, -X, +Y, -Y]
% Default to central window only
LatticeAxesFit = zeros(1,7);    % Max number of different windows
latAxStr       = {'Z' 'X' 'Y'}; % Order of Lattice Axes in LatticeAxesFit
% if length(winToFit) > 1 && ~strcmpi(sampleType,'Lattice') - Disabled for doing Bragg Spectroscopy
%     LatticeAxesFit(1) = 1;
%     % Warn about ignoring extra windows
%     warning('imgFit:SampleType','SampleType is not Lattice, ignoring extra windows around peak')
% else
    for lcl_i = 1:length(winToFit)
        switch winToFit{lcl_i}
            case 'Central' % Origin
                LatticeAxesFit(1) = 1;
            case 'Arm A'    % X - axis (horizontal)
                LatticeAxesFit([4 5]) = 1;
            case 'Arm B'    % Z - axis (horizontal)
                LatticeAxesFit([2 3]) = 1;
            case 'Arm C'    % Y - axis (vertical)
                LatticeAxesFit([6 7]) = 1;
            case 'Bragg +'  % X - axis (horizontal)
                LatticeAxesFit(4) = 1;
            case 'Bragg -'  % X - axis (horizontal)
                LatticeAxesFit(5) = 1;
            otherwise
                error('No windows specified in winToFit.')
        end
    end
% end

%% Image Acquisition Parameters
%%-----------------------------------------------------------------------%%
% Camera properties depend on resolution (Mi Yan's PhD thesis - 12.10.13)
switch CameraMag
    case 1
        CameraRes  = 15; %um
        pixelsize  = binHorizontal*binVertical*14.12*10^(-6); %m/px
        
        % Calibration of diffraction peaks after free expansion, follows form of [Origin, +Z, -Z, +X, -X, +Y, -Y]
        % Found from image 6 of 2158 from 12.06.13 dataset with 11 ms drop with 1x objective
        %LatFreeExpCalib = [0,20,-20,30,-30,31,-31,]./11;
        
        % Bragg Spectroscopy calibration - Added 2014.07.29
        % Calibration of diffraction peaks after free expansion, follows form of [Origin, +Z, -Z, +X, -X, +Y, -Y]
        % Found from image 27 of 1500 from 07.29.14 dataset with 22 ms drop with 1x objective
        LatFreeExpCalib = [0,0,0,38,-38,0,0,]./22;
    case 4
        error('Rydberg Experiment has not been calibrated for new magnification')
        CameraRes  = 0; 
        pixelsize  = 0;
        
    otherwise
        error('Camera magnification chosen is not a valid selection.')
end

sizefactor = pixelsize*softwareBinSize*CCDbinning; % effective pixelsize

%% Directory and master batch file parameters
%%-----------------------------------------------------------------------%%
% Add the library folders to the path
addpath(genpath([pwd filesep 'Library']));
rmpath([pwd filesep 'Library' filesep 'Archive']);

% Define default folder names for directory heirarchy
NeutExpDir      = 'Data';
analyPrefix     = '_Singlet_SFI_n60';
analyOutputName = 'Analysis';

%Two assumptions are made here,
% (1) - The batch directory is at the same folder level as the dataDirectory
% (2) - The batchhead files output by Labview are label as Files_yyyymmdd (Files_yyyymmdd_Bg for background)
% First need to determine file structure of Analysis folder
lcl_analyDir = pwd; % save Analysis Folder location

% Determine directory where all raw data files are saved (expected to mirror folder structure of Analysis folder)
dataDir  = [strrep(strrep(lcl_analyDir,analyPrefix,''),[filesep 'Analysis' filesep],[filesep 'Raw_Data' filesep]) filesep];
dataDirName = regexp(dataDir,filesep,'split');
dataDirName = regexp(dataDirName{end - 1},'_','split');
dataDirName = dataDirName{1};

% When testing use development data instead of real data (development purposes only)
%devSettings(v2struct(cat(1,'fieldNames',who())));

% Check if data directory exists
if not(exist(dataDir,'dir'))
    error('\nData Directory: %s\n not found. Please check analysis directory and/or analyPrefix and try again.',dataDir)
end
% Check if analysis output directory exists, if not create
analyOutDir = [pwd filesep analyOutputName '_' dataDirName filesep]; % Output directory for analysis
if not(exist(analyOutDir,'dir'))
    mkdir([pwd filesep analyOutputName '_' dataDirName])
end
% NOTE: Win 7 has a filename limitation of 260 characters so if you get
% weird errors with dlmwrite look at the path name length

% Master batch file containing all datasets for the day
% If combining datasets to plot across multiple days create a new master batch file
% that shares the name of the folder without periods (i.e. \Data\...\2012.12.14_15_Combine\Files_2012121415_Combine.txt )
basenamelistAtom = [dataDir 'Files_' strrep(dataDirName,'.','') '.txt'];
basenamelistBack = [dataDir 'Files_' strrep(dataDirName,'.','') '_Bg' '.txt'];

% Read in list of variable names and determine the format string for textscan
lcl_varFormatStr = cell(1,length(lcl_masterBatchAtomVar) );     % String is as long as number of variables
lcl_varFormatStr(1) = {'%s'};                                   % Define fixed variables
lcl_varFormatStr(cellfun('isempty',lcl_varFormatStr)) = {'%f'}; % Assume all other variables are floating point numbers
lcl_varFormatStr = horzcat(lcl_varFormatStr{:});                % Concatenate cells into single string for textscan

% Read in variables for each data set defined in the master batch file
lcl_masterBatchAtomData = textscan(fopen(basenamelistAtom),lcl_varFormatStr,'commentstyle','%'); %data set batch files for atoms
lcl_masterBatchBackData = textscan(fopen(basenamelistBack),'%s%f','commentstyle','%');         %data set batch files for backgrounds

%%% Enumerate number of Basenames
numBasenamesAtom = size(lcl_masterBatchAtomData{1},1);

if Choose_Var_from_File
    lcl_Manual_Filename                 = uigetfile;
    [Manual_Vector, Manual_Vector_Name] = xlsread(lcl_Manual_Filename);
    Manual_Vector_Length                = length(Manual_Vector);
    if numBasenamesAtom ~= Manual_Vector_Length
        error('the size of the manual data does not match the number of batch files')
    end
end

%%% What kind of files are expected?
dataAtom = char('atoms.bny');
dataBack = char('back.bny');
dataMCS = char('_mcs_counts.mcs');

%% Set sample specific fit type
%%-----------------------------------------------------------------------%%
% fitModel is a function handle that specifies which model to apply to the data
% NOTE: Lattice is fit using pure gaussian but with multiple windows
switch sampleType
    case {'Thermal' 'Lattice'}
        fitModel = 'PureGaussian'; 
        InitCase = 'Pure';
    case {'BEC'}
        if isotope == 88 && pureSample == 1
            fitModel = 'PureGaussian';
            InitCase = 'Pure';
        elseif isotope == 88 && pureSample == 0
            fitModel = 'BimodalGaussian';
            InitCase = 'Bimodal';
        elseif (isotope == 84 || isotope == 86) && pureSample == 1
            fitModel = 'PureThomasFermi';
            InitCase = 'Pure';
        elseif (isotope == 84 || isotope == 86) && pureSample == 0
            fitModel = 'BimodalThomasFermi';
            InitCase = 'Bimodal';
        end
    otherwise
        error('Invalid sample type specified. Check sampleType and try again')
end

%% Set the window used for fitting (of all sample types) and for plotting
% Also set the logical expression for using the masks (masks created in get_indiv_batch)
% NOTE: Unfortunately window references are not consistent throughout the
% imagefit routine. In general, I've regarded the ROI window as the plot
% window and the fit window as the cloud window.
lcl_fitWin  = lcl_masterBatchAtomData{strcmpi(lcl_masterBatchAtomVar,'cloudWinRadAtom')};
lcl_plotWin = lcl_masterBatchAtomData{strcmpi(lcl_masterBatchAtomVar,'roiWinRadAtom')};
funcFitWin  = @(x) (2*lcl_fitWin(x) + 1);  fitWinLogicInd  = @(winInd) (winInd == 1);
funcPlotWin = @(x) (2*lcl_plotWin(x) + 1); plotWinLogicInd = @(winInd) (winInd >= 0);

%% Define list of initial conditions that each model expects. 
% These names are used in getFitParams to determine how to calculate each value. 
% Be careful when changing or reordering.
% NOTE: Models are reparameterized to expect variables listed as posConstr to
%       be of the form logSigX = log(sigX) where logSigX is what is sent to
%       the model for fitting. This enforces a positivity constraint on the
%       width since a negative width is non-physical.
%       Additionally, variables listed under widthConstr are expected in
%       the form sigX^2 = sigX_BEC^2 + beta^2 where beta is the variable
%       sent to the model for fitting. This enforces that the thermal width
%       be greater than the BEC width.
% WARNING: Don't change the order of the guesses below without looking at
%          the function getFitParams (it expects this order)
switch InitCase
    case 'Pure'
        InitCondList = {'Amp' 'sigX' 'sigY' 'xCntr' 'yCntr' 'Offset' 'SlopeX' 'SlopeY'};
        findFromPeak = {'Amp' 'xCntr' 'yCntr'}; %These variables are found by smoothing and finding peak of data
    case 'Bimodal'
        InitCondList = {'Amp_BEC' 'sigX_BEC' 'sigY_BEC' 'Amp' 'sigX' 'sigY' 'xCntr' 'yCntr' 'Offset' 'SlopeX' 'SlopeY'};
        findFromPeak = {'Amp_BEC' 'xCntr' 'yCntr'}; %These variables are found by smoothing and finding peak of data
end

%% Define label expected on plots
switch TimeOrDetune
    case 'Time'
        funcDataScale = @(data) data;
        xDataLabel    = 'Time [ms]';
        xDataUnit     = 'ms';
    case 'Detuning'
        funcDataScale = @(data) data;
        xDataLabel    = 'Detuning [MHz]';
        xDataUnit     = 'MHz';
	case 'Repetition'
        funcDataScale = @(data) data;
        xDataLabel    = 'Repetition';
        xDataUnit     = ' Rep.';
	case 'Voltage'
        funcDataScale = @(data) data;
        xDataLabel    = 'Voltage [V]';
        xDataUnit     = 'V';
	case 'Frequency'
        funcDataScale = @(data) data;
        xDataLabel    = 'Frequency [MHz]';
        xDataUnit     = 'MHz';
    case 'UVSynth'
        funcDataScale = @(data) data;
        xDataLabel    = 'UV Synth (8x for actual freq.) [MHz]';
        xDataUnit     = 'MHz';
	case 'SpecSynth'
        funcDataScale = @(data) data;
        xDataLabel    = 'Spec. Synth (2x for actual freq.) [MHz]';
        xDataUnit     = 'MHz';
    otherwise
        error('Invalid selection for variable: TimeOrDetune. Please check the assignment.')
end

%% Check for valid lineshape fit arguments
fitLineFunc = lcl_validFitLine(nonzeros(lcl_logicFitLine.*(1:length(lcl_validFitLine))));
if  isempty(intersect(lcl_validFitLine,fitLineFunc)) && ~isempty(fitLineFunc)
    error('Invalid option in Fitlineshape.')
end
      
%% Setup fields for averaging datasets together
%%-----------------------------------------------------------------------%%
% Used in imagefit_Plotting routine
% Allows averaging across multiple datasets with same parameters

meanListVar  = lcl_masterBatchAtomData{strcmpi(lcl_masterBatchAtomVar,'ScanIDVarAtom')}; % Variable used to identify similar scans
uniqScanList = unique(meanListVar,'stable'); % Unique values between all scans (maintains order of appearance in meanListVar)
posOccurUniqVar = arrayfun(@(x) find(meanListVar == x),uniqScanList,'UniformOutput',0);
% Position of each occurence of unique value in meanListVar (sorted as uniqListVar). This finds each scan with similar 
% identifying variables and returns the indices of all similar scans into a cell for each unique variable.
compPrec = 1e6; % Will round numbers to the 6th decimal place
% Define precision to compare independent variables to (helps eliminate errors from comparing floating point
% number) 
      
%% Create structure of variables
%%-----------------------------------------------------------------------%%
% First need to match the batch filename variables to their values
lcl_masterBatchVars = cell2struct(cat(2,lcl_masterBatchAtomData,lcl_masterBatchBackData),cat(2,lcl_masterBatchAtomVar,lcl_masterBatchBackVar),2);
% Concatenate masterBatch structure with another containing all other non-local variables. Lists fields alphabetically.
allVar   = who(); % analyVar is created with variables not starting with lcl_ (these are local variables that are not needed later in the analysis)
analyVar = catstruct(v2struct(cat(1,'fieldNames',allVar(cellfun('isempty',regexp(allVar,'\<lcl_'))))),lcl_masterBatchVars,'sorted');

%% Cleanup Workspace
fclose all; % Cleanup any open files just in case. Run before varCheck to guarantee file id's don't pile up in the global workspace.
end

function devSettings(allVar) %#ok<DEFNU>
%% Dev settings (for development purposes only)
% Workspace of Analysis variables is imported and unpacked via v2struct
% then variables in Analysis are directly manipulated using assignin
v2struct(allVar)

%% this is sample data, use for testing purposes only
switch sampleType
    case 'Thermal'
        devDataDir = '2014.01.16';
    case 'BEC'
        devDataDir = '2012.12.14';
        assignin('caller','TimeOrDetune','Detuning');
    case 'Lattice'
        devDataDir = '2013.12.17';
        assignin('caller','LatticeAxesFit',[1,0,0,1,1,0,0]);
        assignin('caller','winToFit',{'Central' 'Arm A'});
        assignin('caller','TimeOrDetune','Time');
end
assignin('caller','dataDir',regexprep(allVar.dataDir,[allVar.dataDirName '.*' filesep],[devDataDir filesep]));
assignin('caller','dataDirName',devDataDir);

sizefactorTmp = allVar.sizefactor/allVar.pixelsize;
pixelsize = 6e-6;
assignin('caller','pixelsize',pixelsize);
assignin('caller','sizefactor',sizefactorTmp*pixelsize);
assignin('caller','pixelconv',pixelsize*10^6); %converts pixels to microns
end
