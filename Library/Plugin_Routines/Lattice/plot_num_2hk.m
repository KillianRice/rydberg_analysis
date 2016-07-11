function plot_num_2hk(analyVar,indivDataset)
% Function to plot the number spectrum of 2hk peaks (ratio and total) in lattice
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   Plots spectrum along each enabled lattice axis

%% Find axis being analyzed
latAx = analyVar.LatticeAxesFit(2:2:end); % Find axes being analyzed
axStr = analyVar.latAxStr(logical(latAx));

%% Spectrum of all peaks
%%%%%%%-----------------------------------%%%%%%%%%%
for latAxIter = 1:sum(latAx); %% Loop through each axis independently
    for basenameNum = 1:analyVar.numBasenamesAtom %% Loop through each image
        % Use local variables for window atom numbers for convenience
        indVar    = analyVar.funcDataScale(indivDataset{basenameNum}.imagevcoAtom);
        winTotNum = indivDataset{basenameNum}.winTotNum;
        
        figNum = 2550 + latAxIter;
        numLabel = {'Ratio to Total', 'Number in Peak'};
        numTitle = {['+/- 2hk along ' axStr{latAxIter} ' axis']};
        sidePeakNum = sum(winTotNum((2*latAxIter):(2*latAxIter+1),:),1);
        
        default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
            figNum,numLabel,numTitle,analyVar.timevectorAtom,...
            repmat(indVar,1,2)',[sidePeakNum./sum(winTotNum,1); sidePeakNum])
    end
end