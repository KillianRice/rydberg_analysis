function [ output_args ] = Average_Sorted_Data(Manual_Vector, Data_To_Sort, uniqScanList, posOccurUniqVar, Sorted_Data )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
for uniqScanIter = 1:length(analyVar.uniqScanList);
    %% Preallocate nested loop variables
    [avgTotNum, avgBECNum, avgThrmNum,avgCondFrac]...
        = deal(NaN(length(avgDataset{uniqScanIter}.simScanIndVar),...
                length(analyVar.posOccurUniqVar{uniqScanIter})));
  
    %% Loop through all scans that share the current value of the averaging variable
    for simScanIter = 1:length(analyVar.posOccurUniqVar{uniqScanIter})
        % Assign the current scan to be opened
        basenameNum = analyVar.posOccurUniqVar{uniqScanIter}(simScanIter);
        
        % Reference variables in structure by shorter names for convenience
        % (will not create copy in memory as long as the vectors are not modified)
        winTotNum  = indivDataset{basenameNum}.winTotNum;
        winBECNum  = indivDataset{basenameNum}.winBECNum;
        winThrmNum = indivDataset{basenameNum}.winThrmNum;
        
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
        avgTotNum(idxSharedWithSim,simScanIter)   = sum(winTotNum(:,idxSharedInBatch),1);
        avgBECNum(idxSharedWithSim,simScanIter)   = sum(winBECNum(:,idxSharedInBatch),1);
        avgThrmNum(idxSharedWithSim,simScanIter)  = sum(winThrmNum(:,idxSharedInBatch),1);
        avgCondFrac(idxSharedWithSim,simScanIter) = sum(winBECNum(:,idxSharedInBatch),1)./sum(winTotNum(:,idxSharedInBatch),1)*100;
    end
    
    %% Average all like points together
    % Function below takes the mean of the matrix of mixed NaN's and values
    avgDataset{uniqScanIter}.avgTotNum   = nanmean(avgTotNum,2);
    avgDataset{uniqScanIter}.avgBECNum   = nanmean(avgBECNum,2);
    avgDataset{uniqScanIter}.avgThrmNum  = nanmean(avgThrmNum,2);
    avgDataset{uniqScanIter}.avgCondFrac = nanmean(avgCondFrac,2);
end

end

