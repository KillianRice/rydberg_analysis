function create_plot_AtomNum(analyVar,indivDataset)
% Function to plot the spectrum of atomic number.
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%   winTotNum    - Total number of atoms
%   winBECNum    - Total number of atoms in condensate (if present)
%   winThrmNum   - Total number of thermal atoms (if bimodal condensate)
%
% OUTPUTS:
%   Creates plots showing the atomic number. Valid plots are total number, 
%   BEC number, total number, or lattice peak number
%

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    indVar    = indivDataset{basenameNum}.imagevcoAtom;
    winTotNum = indivDataset{basenameNum}.winTotNum;
    winBECNum = indivDataset{basenameNum}.winBECNum;
    
%% Spectrum of Total number 
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum = analyVar.figNum.atomNum; 
    numLabel = {'Total Number'}; 
    numTitle = {};
    default_plot(...
        analyVar,...
        [basenameNum analyVar.numBasenamesAtom],...
        figNum,...
        numLabel,...
        numTitle,...
        analyVar.timevectorAtom,...
        analyVar.funcDataScale(indVar)',...
        sum(winTotNum,1));

%% BEC statistics for bimodal distributions    
    if strcmpi(analyVar.InitCase,'Bimodal')
    %% Spectrum of BEC Number
    %%%%%%%-----------------------------------%%%%%%%%%%
        figNum = analyVar.figNum.condNum; 
        numLabel = {'Condensate Number'}; 
        numTitle = {};
        default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
            figNum,numLabel,numTitle,analyVar.timevectorAtom,...
            analyVar.funcDataScale(indVar)',sum(winBECNum,1));

    %% Plot of condensate fraction
    %%%%%%%-----------------------------------%%%%%%%%%%
        figNum = analyVar.figNum.condFrac; 
        numLabel = {'Condensate Fraction [%]'}; 
        numTitle = {};
        default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
            figNum,numLabel,numTitle,analyVar.timevectorAtom,...
            analyVar.funcDataScale(indVar)',sum(winBECNum,1)./sum(winTotNum,1)*100);
    end
end
end