function create_plot_MeanNum(analyVar,avgDataset)
% Function to plot the spectrum of atomic number.
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%   avgDataset   - Cell of structures similar to indivDataset but
%                  containing only averaged values across similar scans
%                  (scans which share the same experimental parameters)
%
% OUTPUTS:
%   Creates plots showing the mean atomic number. Valid plots are total number, 
%   BEC number, or lattice peak number
%

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for uniqScanIter = 1:length(analyVar.uniqScanList);
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    indVar    = avgDataset{uniqScanIter}.simScanIndVar;
    avgTotNum = avgDataset{uniqScanIter}.avgTotNum;
    avgBECNum = avgDataset{uniqScanIter}.avgBECNum;
    
%% Spectrum of Total number 
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum = analyVar.figNum.meanNum; 
    numLabel = {'Average Total Number'}; 
    numTitle = {};
    default_plot(analyVar,[uniqScanIter length(analyVar.uniqScanList)],...
        figNum,numLabel,numTitle,analyVar.uniqScanList,...
        analyVar.funcDataScale(indVar)',avgTotNum');

%% BEC statistics for bimodal distributions    
    if strcmpi(analyVar.InitCase,'Bimodal')
    %% Spectrum of BEC Number
    %%%%%%%-----------------------------------%%%%%%%%%%
        figNum = analyVar.figNum.meanBEC; 
        numLabel = {'Average Condensate Number'}; 
        numTitle = {};
        default_plot(analyVar,[uniqScanIter length(analyVar.uniqScanList)],...
            figNum,numLabel,numTitle,analyVar.uniqScanList,...
            analyVar.funcDataScale(indVar)',avgBECNum');

    %% Plot of condensate fraction
    %%%%%%%-----------------------------------%%%%%%%%%%
        figNum = analyVar.figNum.meanFrac; 
        numLabel = {'Average Condensate Fraction [%]'}; 
        numTitle = {};
        default_plot(analyVar,[uniqScanIter length(analyVar.uniqScanList)],...
            figNum,numLabel,numTitle,analyVar.uniqScanList,...
            analyVar.funcDataScale(indVar)',avgCondFrac');
    end
end
end




