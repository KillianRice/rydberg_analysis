function create_plot_AtomTemp(analyVar,indivDataset)
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   Creates plots showing the cloud temperature

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    indVar    = analyVar.funcDataScale(indivDataset{basenameNum}.imagevcoAtom);
    atomTempX = indivDataset{basenameNum}.atomTempX(1,:);
    atomTempY = indivDataset{basenameNum}.atomTempY(1,:);
    
%% Plot of temperature in X & Y
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum = analyVar.figNum.atomTemp; 
    tempLabel = {'Temperature [K]', 'Temperature [K]'}; 
    tempTitle = {'', 'X - axis', 'Y - axis'};
    default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
        figNum,tempLabel,tempTitle,analyVar.timevectorAtom,...
        repmat(indVar,1,2)',[atomTempX; atomTempY]);
end
end