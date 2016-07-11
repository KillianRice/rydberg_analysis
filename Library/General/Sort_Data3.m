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

[x_data, y_data] = deal(cell(1,length(uniqScanList)));

for uniqScanIter = 1:length(uniqScanList);

    % Create a cell containing the scanned variable for each batch (set of images)
    indVars = cell( length(indivDataset{uniqScanIter}.RampDelay),1);
    
    for ii = 1:length(indivDataset{uniqScanIter}.RampDelay)
        indVars{ii}=arrayfun(@(x) indivDataset{x}.RampDelay(ii),... 
        posOccurUniqVar{uniqScanIter},'UniformOutput',0);
        x_data{uniqScanIter}{ii} = cell2mat(indVars{ii});
    end
    
%     signal = arrayfun(@(x) indivDataset{x}.MCS_Signal,... 
%         posOccurUniqVar{uniqScanIter},'UniformOutput',0);
%     y_data{uniqScanIter} = cell2mat(signal);
    
    ResultData.Sorted_RampDelay{uniqScanIter} = x_data{uniqScanIter};
    ResultData.Sorted_SignalG{uniqScanIter} = y_data{uniqScanIter};
    
end

end


