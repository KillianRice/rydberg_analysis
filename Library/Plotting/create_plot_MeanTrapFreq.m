function create_plot_MeanTrapFreq(analyVar,avgDataset)
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
%   Creates plots showing the mean trap frequency

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for uniqScanIter = 1:length(analyVar.uniqScanList);
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    indVar       = analyVar.funcDataScale(avgDataset{uniqScanIter}.simScanIndVar);
    avgTrapFreq = avgDataset{uniqScanIter}.avgTrapFreq;
    
%% Plot average trap frequency
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum = analyVar.figNum.meanFreq; 
    freqLabel = {'Avg. Trap Frequency [Hz]'}; 
    freqTitle = [];
    default_plot(analyVar,[uniqScanIter length(analyVar.uniqScanList)],...
        figNum,freqLabel,freqTitle,analyVar.uniqScanList,...
        indVar,avgTrapFreq');
end
end