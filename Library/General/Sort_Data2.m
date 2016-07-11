function [ uniqScanList, posOccurUniqVar, Sorted_Data] = Sort_Data2(SortVar, Data_To_Sort)
%Function to sort out data according to the values of sortColumn within
%each batch file
%   Output cell Sorted_Data, whose i'th element corresponds to the i'th
%   unique value of SortVar. The content of the elements of Sorted_Data
%   will be groupings of Data_To_Sort according to SortVar.

uniqScanList = unique(SortVar,'stable'); % Unique values between all scans (maintains order of appearance in SortVar)

posOccurUniqVar = arrayfun(@(x) find(SortVar == x),...
    uniqScanList,'UniformOutput',0);

% Position of each occurence of unique value in SortVar (sorted as uniqListVar). This finds each scan with similar 
% identifying variables and returns the indices of all similar scans into a cell for each unique variable.

Sorted_Data  = cell(1,length(uniqScanList));

for uniqScanIter = 1:length(uniqScanList);

    % Create a cell containing the scanned variable for each batch (set of images)
    indVars = arrayfun(@(x) Data_To_Sort{x},... 
        posOccurUniqVar{uniqScanIter},'UniformOutput',0);
    Sorted_Data{uniqScanIter} = cell2mat(indVars);
   
end

end


