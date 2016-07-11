function  [MultiStateCell, DataSetIndex] = CollectStates(structure, DataSetIndex, MultiStateCell)

Frequency = 2; %choose a batch to sample
NumDelays = 7;

yData = cell(4,NumDelays);

if DataSetIndex == 0
 MultiStateCell = cell(1,4);
 DataSetIndex = DataSetIndex+1;
end

for DelayIndex = 1:NumDelays
    for plotType = 1:4

        switch plotType
            case 1
                yData{plotType,DelayIndex} = structure.indivDataset{Frequency}.NormTotalPopAvgSpectra(:,DelayIndex);
            case 2
                yData{plotType,DelayIndex} = structure.indivDataset{Frequency}.NormRydPopAvgSpectra(:,DelayIndex);                
            case 3
                yData{plotType,DelayIndex} = structure.indivDataset{Frequency}.NormTotalPopNonPeak_AvgSpectra(:,DelayIndex);
            case 4
                yData{plotType,DelayIndex} = structure.indivDataset{Frequency}.NormRydPopNonPeak_AvgSpectra(:,DelayIndex);    
        end
        
    end
end

MultiStateCell{DataSetIndex} = yData;
DataSetIndex = DataSetIndex + 1;
end