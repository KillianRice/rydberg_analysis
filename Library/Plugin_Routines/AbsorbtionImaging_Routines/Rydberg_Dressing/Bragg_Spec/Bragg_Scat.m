function braggOut = Bragg_Scat(lcl_analyVar,lcl_indivDataset,lcl_avgDataset)
%Function to calculate Bragg spectra values
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%   avgDataset   - Cell of structures containing grouped data for averaging
%
% OUTPUTS:
%   braggOut     - structure containing the workspace of Bragg_Scat compiled at the end
%                  of the function (same behavior as AnalysisVariables)
%
% Possibly:
% (1) - Fit peak populations to extract frequency
% (2) - Fit peak populations spectra to extract line center

%% Initialize variables
figSpec = figure;

%% Decide to use averaged data or individual scans
avgAutoFlag = length(cell2mat(lcl_analyVar.posOccurUniqVar)) > length(lcl_analyVar.posOccurUniqVar) & lcl_analyVar.uniqScanList ~= 0;

%% Extract independent variables and number from correct structure
indField   = {'imagevcoAtom' 'simScanIndVar'};  % fields of independent variables in indivDataset and avgDataset
numField   = {'winTotNum' 'avgTotNum'};         % number data in indivDataset and avgDataset
labelField = {'timevectorAtom' 'uniqScanList'}; % label used for each plot

% Selected datatype picks the data to be analyzed
if avgAutoFlag
    curDataset = lcl_avgDataset;   fieldIndx = 2;
else
    curDataset = lcl_indivDataset; fieldIndx = 1;
end

% Save variables from cell of structures
indVar  = cellfun(@(x) x.(indField{fieldIndx}),curDataset,'UniformOutput',0);
partNum = cellfun(@(x) x.(numField{fieldIndx}),curDataset,'UniformOutput',0);
label   = lcl_analyVar.(labelField{fieldIndx});

%% Extract number and normalize
% Initialize loop variables
num2hkCell = cell(1,length(indVar));
expTime    = zeros(1,length(indVar));
% Loop through all scans
for iterVar = 1:length(indVar)
    if avgAutoFlag
        [num2hk] = avgBraggNum(lcl_analyVar,lcl_indivDataset,lcl_avgDataset,iterVar);
        totNum = partNum{iterVar}';
        % Assign the current scan to be opened
        basenameNum = lcl_analyVar.posOccurUniqVar{iterVar}(1);
    else
        num2hk = partNum{iterVar}(2,:)./sum(partNum{iterVar});
        totNum = sum(partNum{iterVar});
        % Assign current scan
        basenameNum = iterVar;
    end
    
    % Save variables for fitting
    num2hkCell{iterVar} = num2hk;
    expTime(iterVar)    = lcl_analyVar.expTime(basenameNum)*1e-3;
    
    %% Plot spectrum
    numLabel = {'Number in 2hk (normalized)', 'Total Number'};
    numTitle = {'Bragg Scattering Populations'};
    
    [plotHan, axHan] = default_plot(lcl_analyVar,[iterVar length(indVar)],...
                        figSpec,numLabel,numTitle,label,...
                        repmat(indVar{iterVar},1,2)',[num2hk; totNum]);
    figSpecChld = get(figSpec,'Children'); set(figSpec,'CurrentAxes',figSpecChld(end)); axis tight
end

%% Fit number spectrum
if expTime ~= 0
    [amp, cntr] = fit_bragg_spectra(indVar,num2hkCell,label,expTime,figSpec)
end

%% Pack workspace into a structure for output
% If you don't want a variable output prefix it with lcl_
braggOut = who();
braggOut = v2struct(cat(1,'fieldNames',braggOut(cellfun('isempty',regexp(braggOut,'\<lcl_')))));
end