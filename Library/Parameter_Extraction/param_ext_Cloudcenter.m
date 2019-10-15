function [indivDataset] = param_ext_Cloudcenter(analyVar,indivDataset)

%% Loop through each batch file listed in basenamevectorAtom
for basenameNum = 1:analyVar.numBasenamesAtom
    % Preallocate nested loop variables
    [cntrX, cntrY]...
        = deal(NaN(1,indivDataset{basenameNum}.CounterAtom));
    
    for k = 1:indivDataset{basenameNum}.CounterAtom;
        %% Extract cloud position
        cntrX(:,k) = (analyVar.roiWinRadAtom(basenameNum) - (analyVar.funcFitWin(basenameNum) - 1)/2)...
            + indivDataset{basenameNum}.All_fitParams{k}{1}.xCntr;
        cntrY(:,k) = (analyVar.roiWinRadAtom(basenameNum) - (analyVar.funcFitWin(basenameNum) - 1)/2)...
            + indivDataset{basenameNum}.All_fitParams{k}{1}.yCntr;
    end
    
    % Save cloud radius for each window into the indivDataset structure
    indivDataset{basenameNum}.cntrX = cntrX;
    indivDataset{basenameNum}.cntrY = cntrY;
end