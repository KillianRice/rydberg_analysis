function  [avg2hkPeakNum, avg0hkPeakNum] = avgBraggNum(analyVar,indivDataset,avgDataset,uniqScanIter)
% This function will normalize and average the atom number when applying
% averaging to Bragg spectroscopy
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%   avgDataset   - Cell of structures containing grouped data for averaging

%% Preallocate loop variables
[avg2hkPeakNum, avg0hkPeakNum]...
    = deal(NaN(length(avgDataset{uniqScanIter}.simScanIndVar),...
    length(analyVar.posOccurUniqVar{uniqScanIter})));

%% Loop through all scans that share the current value of the averaging variable
for simScanIter = 1:length(analyVar.posOccurUniqVar{uniqScanIter})
    % Assign the current scan to be opened
    basenameNum = analyVar.posOccurUniqVar{uniqScanIter}(simScanIter);
    
    % Use local variables for window atom numbers for convenience
    winTotNum  = indivDataset{basenameNum}.winTotNum;
    
    % Find the intersection of the scanned variable with the list of all possible values
    [~,idxSharedWithSim,idxSharedInBatch] = intersect(avgDataset{uniqScanIter}.simScanIndVar,...
        indivDataset{basenameNum}.imagevcoAtom);
    
    % Find number in the peaks of interest
    avg2hkPeakNum(idxSharedWithSim,simScanIter) = winTotNum(2,idxSharedInBatch)./sum(winTotNum(:,idxSharedInBatch));
    avg0hkPeakNum(idxSharedWithSim,simScanIter) = winTotNum(1,idxSharedInBatch)./sum(winTotNum(:,idxSharedInBatch));
end

% Average together all non nan values in matrix
avg2hkPeakNum = nanmean(avg2hkPeakNum,2)';
avg0hkPeakNum = nanmean(avg0hkPeakNum,2)';
end

