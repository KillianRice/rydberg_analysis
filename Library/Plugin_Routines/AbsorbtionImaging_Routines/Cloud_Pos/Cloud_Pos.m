function posOut = Cloud_Pos(analyVar,indivDataset,avgDataset)
% Allow plotting of the peak position found through fitting the 2D distribution

%% Decide to average data or use individual scans
avgAutoFlag = length(cell2mat(analyVar.posOccurUniqVar)) > length(analyVar.posOccurUniqVar) & ~any(analyVar.uniqScanList == 0);

%% Flag whether to fit center positions as oscillations
oscFitFlag  = 1;
oscAxis    = 'y'; %flag which axis is oscillating in space
fitStatFlag = 1;

%% Initialize loop variables
[cntrXCell, cntrYCell] = deal(cell(1,analyVar.numBasenamesAtom));
indivFigNum = figure; if avgAutoFlag; avgFigNum = figure; end

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
    
    %% Show statistics if enabled
    if fitStatFlag
        fprintf('\nStatistics for %g\n',analyVar.timevectorAtom(basenameNum))
        fprintf('\nRMS in X: %g',rms(cntrX))
        fprintf('\nMean in X: %g',mean(cntrX))
        fprintf('\nRMS-Mean in X: %g',rms(cntrX)-mean(cntrX))
        fprintf('\nStd. Dev. in X: %g\n',std(cntrX))
        
        fprintf('\nRMS in Y: %g',rms(cntrY))
        fprintf('\nMean in Y: %g',mean(cntrY))
        fprintf('\nRMS-Mean in Y: %g',rms(cntrY)-mean(cntrY))
        fprintf('\nStd. Dev. in Y: %g\n',std(cntrY))
    end
    
    %% Plotting
    %%%%%%%-----------------------------------%%%%%%%%%%
    indVar = indivDataset{basenameNum}.imagevcoAtom;
    
    cntrLabel = {'Center Position', 'Center Position'};
    cntrTitle = {'', 'X - axis', 'Y - axis'};
    default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
        indivFigNum,cntrLabel,cntrTitle,analyVar.timevectorAtom,...
        repmat(indVar,1,2)',[cntrX; cntrY]);
    
    %% Fitting (if flagged)
    if oscFitFlag & ~avgAutoFlag
        figure; 
        if strcmpi('x',oscAxis)
            title('X - Axis'); fitCntr = cntrX;
        else
            title('Y - Axis'); fitCntr = cntrY;
        end  
        Spatail_Osc_Fit(indVar*1e-3,fitCntr');
        set(gca,'FontSize',16)
    end
    
    %% Save for averaging
    if avgAutoFlag
        % If averaging, then save into cell
        cntrXCell{basenameNum} = cntrX;
        cntrYCell{basenameNum} = cntrY;
    end
end

if avgAutoFlag
    for uniqScanIter = 1:length(analyVar.uniqScanList);
        %% Preallocate nested loop variables
        [avgCntrX, avgCntrY]...
            = deal(NaN(length(avgDataset{uniqScanIter}.simScanIndVar),...
            length(analyVar.posOccurUniqVar{uniqScanIter})));
        
        %% Loop through all scans that share the current value of the averaging variable
        for simScanIter = 1:length(analyVar.posOccurUniqVar{uniqScanIter})
            % Assign the current scan to be opened
            basenameNum = analyVar.posOccurUniqVar{uniqScanIter}(simScanIter);
            
            cntrX = cntrXCell{basenameNum};
            cntrY = cntrYCell{basenameNum};
            
            % Find the intersection of the scanned variable with the list of all possible values
            % idxShrdInBatch - index of the batch file ind. variables that intersect with
            %                  the set of all ind. variables of similar scans
            % idxShrdWithSim - index of all ind. variables of similar scans that intersect
            %                  with the set of current batch file ind. variables
            % Look at help of intersect if this is unclear
            [~,idxSharedWithSim,idxSharedInBatch] = intersect(avgDataset{uniqScanIter}.simScanIndVar,...
                double(int32(indivDataset{basenameNum}.imagevcoAtom*analyVar.compPrec))*1/analyVar.compPrec);
            
            %% Compute number of atoms
            % Matrix containing the various measured pnts for each scan image
            avgCntrX(idxSharedWithSim,simScanIter) = cntrX(:,idxSharedInBatch);
            avgCntrY(idxSharedWithSim,simScanIter) = cntrY(:,idxSharedInBatch);
        end
        
        %% Average all like points together
        % Function below takes the mean of the matrix of mixed NaN's and values
        avgCntrX = nanmean(avgCntrX,2);
        avgCntrY = nanmean(avgCntrY,2);
        
        %% Plotting
        %%%%%%%-----------------------------------%%%%%%%%%%
        indVar = avgDataset{uniqScanIter}.simScanIndVar;
        
        cntrLabel = {'Avg. Center Position', 'Avg. Center Position'};
        cntrTitle = {'','X-axis','Y-axis'};
        default_plot(analyVar,[uniqScanIter length(analyVar.uniqScanList)],...
            avgFigNum,cntrLabel,cntrTitle,analyVar.uniqScanList,...
            repmat(indVar,1,2)',[avgCntrX'; avgCntrY']);
        
        %% Fitting (if flagged)
        if oscFitFlag && avgAutoFlag
            figure;
            if strcmpi('x',oscAxis)
                title('X - Axis'); fitCntr = avgCntrX;
            else
                title('Y - Axis'); fitCntr = avgCntrY;
            end
            Spatail_Osc_Fit(indVar*1e-3,fitCntr);
            set(gca,'FontSize',16)
        end
    end
end
%% Pack workspace into a structure for output
% If you don't want a variable output prefix it with lcl_
posOut = who();
posOut = v2struct(cat(1,'fieldNames',posOut(cellfun('isempty',regexp(posOut,'\<lcl_')))));
end