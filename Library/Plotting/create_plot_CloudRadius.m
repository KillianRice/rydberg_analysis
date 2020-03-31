function create_plot_CloudRadius(analyVar,indivDataset)
% Function to plot the cloud radius
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   Creates plots showing the cloud radius

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    indVar    = analyVar.funcDataScale(indivDataset{basenameNum}.imagevcoAtom);
    CloudRadX = indivDataset{basenameNum}.cloudRadX(1,:);
    CloudRadY = indivDataset{basenameNum}.cloudRadY(1,:);
    
%% Plot of radius in X & Y
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum = analyVar.figNum.atomSize; 
    radLabel = {'Cloud Radius [um]', 'Cloud Radius [um]'}; 
    radTitle = {'', 'X - axis', 'Y - axis'};
    default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
        figNum,radLabel,radTitle,analyVar.timevectorAtom,...
        repmat(indVar,1,2)',[CloudRadX; CloudRadY]);
end
end