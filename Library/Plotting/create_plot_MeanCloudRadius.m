function create_plot_MeanCloudRadius(analyVar,avgDataset)
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
%   Creates plots showing the mean cloud radius

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for uniqScanIter = 1:length(analyVar.uniqScanList);
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    indVar       = analyVar.funcDataScale(avgDataset{uniqScanIter}.simScanIndVar);
    avgCloudRadX = avgDataset{uniqScanIter}.avgCloudRadX;
    avgCloudRadY = avgDataset{uniqScanIter}.avgCloudRadY;
    
%% Plot of radius in X & Y
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum =analyVar.figNum.meanSize; 
    radLabel = {'Avg. Cloud Radius [um]', 'Avg. Cloud Radius [um]'}; 
    radTitle = {'', 'X - axis','Y - axis'};
    default_plot(analyVar,[uniqScanIter length(analyVar.uniqScanList)],...
        figNum,radLabel,radTitle,analyVar.uniqScanList,...
         repmat(indVar,1,2)',[avgCloudRadX'; avgCloudRadY']);
end
end