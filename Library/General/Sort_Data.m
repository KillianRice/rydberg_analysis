function [ indivDataset, ResultData] = Sort_Data(analyVar, indivDataset, ResultData, meanListVar)
%Function to sort out data according to the values of sortColumn within
%each batch file
%   Detailed explanation goes here


uniqScanList = unique(meanListVar,'stable'); % Unique values between all scans (maintains order of appearance in meanListVar)

ResultData.UniqueODTHold = uniqScanList;

posOccurUniqVar = arrayfun(@(x) find(meanListVar == x),...
    uniqScanList,'UniformOutput',0);

ResultData.UniqueODTHoldIndex = posOccurUniqVar;

% Position of each occurence of unique value in meanListVar (sorted as uniqListVar). This finds each scan with similar 
% identifying variables and returns the indices of all similar scans into a cell for each unique variable.
compPrec = 1e9; % Will round numbers to the 6th decimal place
% Define precision to compare independent variables to (helps eliminate errors from comparing floating point
% number)  

% % %   avgDataset = cell(1,length(uniqScanList));

[x_data, y_data] = deal(cell(1,length(uniqScanList)));

for uniqScanIter = 1:length(uniqScanList);

    % Create a cell containing the scanned variable for each batch (set of images)
    indVars = arrayfun(@(x) indivDataset{x}.RampDelay(1),... 
        posOccurUniqVar{uniqScanIter},'UniformOutput',0);
    x_data{uniqScanIter} = cell2mat(indVars);
    
    signal = arrayfun(@(x) indivDataset{x}.MCS_Signal,... 
        posOccurUniqVar{uniqScanIter},'UniformOutput',0);
    y_data{uniqScanIter} = cell2mat(signal);
    
    ResultData.Sorted_RampDelay{uniqScanIter} = x_data{uniqScanIter};
    ResultData.Sorted_SignalG{uniqScanIter} = y_data{uniqScanIter};
    
    %round values to nearest nth digit, dicated by compPrec... i think.
    %seems to reverse (or just order) the values of indVars
% % %   % Save a vector of all the unique scan pnts for comparison
% % %   avgDataset{uniqScanIter}.simScanIndVar = double(unique(int32(indVars*compPrec)))*1/compPrec;
    
%     x_data{uniqScanIter} = 
end
warning('need to generalize combining the ramp delay data and the signal data in line 23')

end


