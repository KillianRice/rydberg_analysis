function Cloud_Pos(analyVar,indivDataset,avgDataset)
% Part of fitting the 2D distribution is guessing the peak position so follow normal routine but instead of
% fitting plot the positions

%% Loop through each batch file listed in basenamevectorAtom
for basenameNum = 1:analyVar.numBasenamesAtom
    % Preallocate nested loop variables
    InitGuess = cell(1,indivDataset{basenameNum}.CounterAtom);
    
    % Process all the data files in this batch
    for k = 1:indivDataset{basenameNum}.CounterAtom;
%% Retrieve OD image from indivDataset
%%%%%%%-----------------------------------%%%%%%%%%%
        OD_Image_Single = indivDataset{basenameNum}.All_OD_Image{k};
        
        % Save logical mask to local variable for convenience
        roiWin_Index = indivDataset{basenameNum}.roiWin_Index;
        
%% Retrieve windowed image to be fitted
%%%%%%%-----------------------------------%%%%%%%%%%
        OD_Fit_ImageCell = cellfun(@(x) reshape(OD_Image_Single(x),[1 1]*analyVar.funcFitWin(basenameNum)),...
            cellfun(analyVar.fitWinLogicInd,roiWin_Index,'UniformOutput',0),'UniformOutput',0);
        
%% Initial guesses
%%%%%%%-----------------------------------%%%%%%%%%%
        % Part of the inital guesses is finding the peak position
        InitGuess{k} = get_fit_params(analyVar,OD_Image_Single,OD_Fit_ImageCell,indivDataset,basenameNum,k);
    end
    
%% Retrieve centers from Initial Guesses
%%%%%%%-----------------------------------%%%%%%%%%%
    % Get index of the center variables in InitCondList
    [~,indCnt] = intersect(analyVar.InitCondList,analyVar.findFromPeak(2:3));
    
    % Save position of central window into vector for plotting
    pos = nan(length(InitGuess),2);
    for i = 1:length(InitGuess); pos(i,1:2) = InitGuess{i}{1}(indCnt); end
    % Center position
    posCnt = analyVar.roiWinRadAtom(basenameNum) - pos;
    
%% Determine independent variable
% For stability you may look at position at a fixed point (time or detuning) so plot versus number of scans
% If varying time or detuning then plot against the changed variable
%%%%%%%-----------------------------------%%%%%%%%%%
    if mean(indivDataset{1}.imagevcoAtom) == indivDataset{1}.imagevcoAtom(1)
        indVar = 1:indivDataset{basenameNum}.CounterAtom;
    else
        indVar = indivDataset{1}.imagevcoAtom;
    end

%% Plotting
%%%%%%%-----------------------------------%%%%%%%%%%
    figure;
    
    % Horizontal
    subplot(2,1,1); plot(indVar,posCnt(:,1));
    h1 = get(gca,'Children'); grid on; xlim([indVar(1) indVar(end)]);
    set(h1,'Marker','o','MarkerSize',12,'LineStyle','none','MarkerFaceColor','b')
    title('Horizontal position','FontSize',14)
    
    % Vertical
    subplot(2,1,2); plot(indVar,posCnt(:,2));
    h2 = get(gca,'Children'); grid on; xlim([indVar(1) indVar(end)]);
    set(h2,'MarkerFaceColor','g','Marker','o','MarkerEdgeColor','g','LineStyle','none','MarkerSize',12)
    title('Vertical position','FontSize',14)
end

