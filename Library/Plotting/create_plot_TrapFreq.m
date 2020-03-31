function create_plot_TrapFreq(analyVar,indivDataset)
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   Creates plots showing the trap frequency

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    indVar   = analyVar.funcDataScale(indivDataset{basenameNum}.imagevcoAtom)';
    trapFreq = indivDataset{basenameNum}.condTrapFreq(1,:);
    
%% Plot of trap frequency
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum = analyVar.figNum.trapFreq; 
    freqLabel = {'Trap Frequency [Hz]'}; 
    freqTitle = {};
    default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
        figNum,freqLabel,freqTitle,analyVar.timevectorAtom,...
        indVar,trapFreq);
end
end