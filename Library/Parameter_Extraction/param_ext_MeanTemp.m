function avgDataset = param_ext_MeanTemp(analyVar,indivDataset,avgDataset)
% Function to calculate the mean cloud temperature from the previously
% calculated temperature
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%   avgDataset   - Cell of structures containing grouped data for averaging
%
% OUTPUTS:
%   avgDataset - Cell of structures containing grouped data for
%                averaging. Fields below will be added to avgDataset when it is output 
%                  avgAtomTempX  - Average cloud temperature along X
%                  avgAtomTempY  - Average cloud temperature along Y
%
% NOTE:
%   1. Be careful of the distinction between the batch list variables and the
%      unique scan variables. The batch list variables are variables which every batch
%      has (here a batch is one set of images). Since we often
%      scan a higher parameter when taking data (ex. laser intensity or
%      relative detunings) one particular batch variable is used to group scans that were
%      taken using the same set of parameters (have all the same batch variables).
%      Thus the unique scan variables defines only those unique scan
%      parameters. 
%
%   2. The code below considers each unique scan in turn. For each unique
%      scan we find all batches sharing the same variables and construct a
%      matrix of the number of atoms for each independent variable. This
%      gives a matrix where the number of columns is the number of batches
%      in the unique scan and the rows are the unique time points within
%      the unique scan. 
%      As an example consider taking 10 datasets of the same parameter 
%      (i.e. detuning) but for 5 datasets there was a 2ms time step over 40
%      images and for the remaining 5 there was a 5ms timestep over 25
%      images. Since time was all that changed we can average over all 10
%      batches but there are not 65 unique time points because every 5th
%      image of the 2ms batches is the same time as the 5ms batches. This
%      gives (40+25)-(2*40)/5 = 49 unique time points. Thus the matrix used to average
%      over all points (within this unique scan) will have 10 columns
%      (number of batches) and 49 rows. Those time points that don't match
%      up between scans are filled with NaN and disregarded when taking the
%      average (using nanmea)

%% Loop through all unique values used for averaging
for uniqScanIter = 1:length(analyVar.uniqScanList);
    %% Preallocate nested loop variables
    [avgAtomTempX avgAtomTempY]...
        = deal(NaN(length(avgDataset{uniqScanIter}.simScanIndVar),...
                length(analyVar.posOccurUniqVar{uniqScanIter})));
  
    %% Loop through all scans that share the current value of the averaging variable
    for simScanIter = 1:length(analyVar.posOccurUniqVar{uniqScanIter})
        % Assign the current scan to be opened
        basenameNum = analyVar.posOccurUniqVar{uniqScanIter}(simScanIter);
        
        % Reference variables in structure by shorter names for convenience
        % (will not create copy in memory as long as the vectors are not modified)
        atomTempX  = indivDataset{basenameNum}.atomTempX;
        atomTempY  = indivDataset{basenameNum}.atomTempY;
        
        % Find the intersection of the scanned variable with the list of all possible values
        % idxShrdInBatch - index of the batch file ind. variables that intersect with
        %                  the set of all ind. variables of similar scans
        % idxShrdWithSim - index of all ind. variables of similar scans that intersect
        %                  with the set of current batch file ind. variables
        % Look at help of intersect if this is unclear
        [~,idxSharedWithSim,idxSharedInBatch] = intersect(avgDataset{uniqScanIter}.simScanIndVar,...
            double(int32(indivDataset{basenameNum}.imagevcoAtom*analyVar.compPrec))*1/analyVar.compPrec);
        
        %% Compute temperature of atoms
        % Matrix containing the various measured pnts for each scan image
        avgAtomTempX(idxSharedWithSim,simScanIter) = atomTempX(1,idxSharedInBatch);
        avgAtomTempY(idxSharedWithSim,simScanIter) = atomTempY(1,idxSharedInBatch);
    end
    
    %% Average all like points together
    % Function below takes the mean of the matrix of mixed NaN's and values
    avgDataset{uniqScanIter}.avgAtomTempX = nanmean(avgAtomTempX,2);
    avgDataset{uniqScanIter}.avgAtomTempY = nanmean(avgAtomTempY,2);
end
end