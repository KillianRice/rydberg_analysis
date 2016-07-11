function indivDataset = EstimateDensity3( analyVar, indivDataset, ParentStruct )
NumDataSets = ParentStruct.NumDataSets;
PosDataSets = ParentStruct.PosDataSets;
for mbIndexCounter = 1:NumDataSets
    mbIndex = PosDataSets(mbIndexCounter);
    numDensityGroups    = indivDataset{mbIndex}.numDensityGroups{1};
    densityvector= 1:numDensityGroups;
    indivDataset{mbIndex}.densityvector = densityvector;
end
end



