function rabiOscOut = Rabi_Oscillations(lcl_analyVar,lcl_indivDataset,lcl_avgDataset)
% Plugin to loop through datasets and fit Rabi oscillations by numerically integrating the optical bloch
% equations
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit routines
%   indivDataset - Cell of structures containing all scan/batch specific data
%   avgDataset   - Cell of structures containing grouped data for averaging
%
% OUTPUTS:
%   rabiOscOut	 - Structure containing all variables in the workspace of Spectrum_Fit
%                  This is the same behavior as AnalysisVariables and can be used to
%                  facilitate calling as a generalized routine.

%% Decide to use averaged data or individual scans
avgAutoFlag = length(cell2mat(lcl_analyVar.posOccurUniqVar)) > length(lcl_analyVar.posOccurUniqVar) & lcl_analyVar.uniqScanList ~= 0;

%% Extract independent variables and number from correct structure
indField   = {'imagevcoAtom' 'simScanIndVar'};  % fields of independent variables in indivDataset and avgDataset
numField   = {'winTotNum' 'avgTotNum'};         % number data in indivDataset and avgDataset
labelField = {'timevectorAtom' 'uniqScanList'}; % label used for each plot

% Selected datatype picks the data to be analyzed
% If avgAutoFlag is true (1), analyze averaged data set
if avgAutoFlag
    curDataset = lcl_avgDataset;
    fieldIndx = 2;

% Else, analyze individual data set
else
    curDataset = lcl_indivDataset;
    fieldIndx = 1;
end

% Save variables from cell of structures
indVarCell  = cellfun(@(x) x.(indField{fieldIndx}),curDataset,'UniformOutput',0);
partNumCell = cellfun(@(x) x.(numField{fieldIndx}),curDataset,'UniformOutput',0);
labelVec    = lcl_analyVar.(labelField{fieldIndx});  %Data time label

%% Constants
scaleTime = 1E-3;   % Converion factor to get raw data in [s] when measured in [ms]

%% Rabi oscillation fixed and fit parameters
% Structure containing relevant fitting parameters
fixParams = struct('state',         2,...           % Specify which state is being measured (1=ground, 2=excited)
                   'pulseOffset',   0,...           % [s] Specify any extra time for the Rabi pulse to compensate
                   'gammaLife',     2*pi*7.5e3,...  % [s^-1] natural decay rate
                   'totNumMeas',    1.2e6,...      % Total measured atom number
                   'initRho',       [1;0;0;0]);     % Fixed (normalized) initial populations

fitParams = struct('totNumFit', fixParams.totNumMeas,...
                   'delta',    2*pi*(0e3),...       % [s^-1] detuning
                   'gammaDec', 2*pi*10e3);        % [s^-1] guess decoherence

%% Fitting loop

%Pre-allocate space
atomPopCell = cell(size(indVarCell));
dataTimeCell = cell(size(indVarCell));
atomPopCell = cell(size(indVarCell));
fitIndVarCell = cell(size(indVarCell));
fitGndStateCell = cell(size(indVarCell));
fitExtStateCell = cell(size(indVarCell));
fitRabiFreqCell = cell(size(indVarCell));
fitDecohFreqCell = cell(size(indVarCell));
fitTotCell = cell(size(indVarCell));

for iterVar = 1:length(indVarCell)
    
    rawTime = indVarCell{iterVar}; % [ms] Raw recorded Rabi pulse time
    rawAtomNum = partNumCell{iterVar}; % Raw measured atom number from data
    
    %Makes both rawTime and rawAtomNum column vectors (the code currently
    %may hvae rawAtomNum as a column or row vector depending on whether
    %the data's been averaged or not)
    if size(rawTime,2) > size(rawTime,1)
        rawTime = rawTime';
    end
    if size(rawAtomNum,2) > size(rawAtomNum,1)
        rawAtomNum = rawAtomNum';
    end
    
    % Converts time in raw data from [ms] to [s] and allows for Rabi pulse offset time
    dataTimeCell{iterVar} = rawTime*scaleTime;
    
    %atomPopCell{iterVar} = rawAtomNum/totNum;
    atomPopCell{iterVar} = rawAtomNum;
       
    % Perform fitting
    [fitTime,fitGndState,fitExtState,rabiFreq,decohFreq,fitTotNum] = fitRabiOsc(dataTimeCell{iterVar},atomPopCell{iterVar},fixParams,fitParams);
    
    % Save fit parameters in cells
    fitIndVarCell{iterVar} = fitTime;
    fitGndStateCell{iterVar} = fitGndState;
    fitExtStateCell{iterVar} = fitExtState;
    fitRabiFreqCell{iterVar} = rabiFreq;
    fitDecohFreqCell{iterVar} = decohFreq;
    fitTotCell{iterVar} = fitTotNum;
end

%% Plotting result
% Determine number of subplots
[nrow,ncol] = optiSubPlotNum(length(indVarCell),[1,2]);

figure;
for iterVar = 1:length(indVarCell)
    subPlotHan = subplot(nrow,ncol,iterVar);
    
    hold on;
    
    % Plots "unnormalized" data (multiplies the raw data by totPop)
    rawDataHan = plot(dataTimeCell{iterVar},atomPopCell{iterVar});
    set(rawDataHan,'LineStyle','none','Marker','o','Color','Red');
    
    % Plots the fitted ground state population scaled by totPop
    %fitPopHan = plot([fitIndVarCell{iterVar},fitIndVarCell{iterVar}],...
     %                [totNum*fitGndStateCell{iterVar},totNum*(1-fitGndStateCell{iterVar})]);
%     fitPopHan = plot([fitIndVarCell{iterVar}],...
%                      [fitGndStateCell{iterVar}]);
%    totNum = fitTotCell{iterVar};
	fitPopHan = plot([fitIndVarCell{iterVar},fitIndVarCell{iterVar}],...
                     [fitGndStateCell{iterVar},fitExtStateCell{iterVar}]);
     
    set(fitPopHan,'LineWidth',2);
    
    % Table information
    format shortEng;
    rabiFreq_str = sprintf('Rabi Freq [s^{-1}]: 2\\pi \\times %5.3e Hz',fitRabiFreqCell{iterVar}/2/pi);
    decohGamma_str = sprintf('Decoh. Freq. [s^{-1}]: 2\\pi \\times %5.3e Hz',fitDecohFreqCell{iterVar}/2/pi);
    totPop_str = sprintf('Total Atom Num: %5.3e',fitTotCell{iterVar});
    data = {rabiFreq_str;decohGamma_str;totPop_str};
    
    %Title plot based on scan number/time
    title(labelVec(iterVar));
    
	text(0.5,0.2,data,...
         'Units','normalized',...
         'Parent',subPlotHan,...
         'LineStyle','-',...
         'BackgroundColor',[1,1,0.84],...
         'EdgeColor',[0,0,0]);
     
    set(gca,...
        'Box','on',...
        'LineWidth',2,...
        'FontSize',20,...
        'FontWeight','bold');
    
    xlabel('Pulse Duration [s]',...
        'FontSize',20,...
        'FontWeight','bold');
    
    ylabel('Populations',...
        'FontSize',20,...
        'FontWeight','bold');
    
    axis tight
    grid on

    %If working with averaged data set
    if fieldIndx == 2
        % Add legend and information to fit plot
        legHan = legend('Averaged data set',...
                    '\rho_{gg}','\rho_{ee}',...
                    'Location','NorthEast');
    else
        % Add legend and information to fit plot
        legHan = legend(int2str(labelVec(iterVar)),...
                    '\rho_{gg}','\rho_{ee}',...
                    'Location','NorthEast');
    end
    
    hold off;
end

%% Pack workspace into a structure for output
% If you don't want a variable output, prefix it with lcl_
rabiOscOut = who();
rabiOscOut = v2struct(cat(1,'fieldNames',rabiOscOut(cellfun('isempty',regexp(rabiOscOut,'\<lcl_')))));
end