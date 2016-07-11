function [ Unique_xData, Ave_yData, Ave_yData_error] = AggregateData( xCell, yCell)

CellSize = length(xCell);

%% Find unique value of number of LoopSets and their indeces
[xData] = deal([]);
for mbIndex = 1:CellSize
    xData = cat(1, xData, xCell{mbIndex});
end
Unique_xData = unique(xData,'sorted');
NumUnique_xData = length(Unique_xData);

Unique_xData_Position = cell(1,CellSize);
for mbIndex = 1:CellSize
    Unique_xData_Position{mbIndex} = arrayfun(@(x) find(Unique_xData == x),...
        xCell{mbIndex},'UniformOutput',0);
end

%% Aggregate all the data
[yData, Ave_yData, Ave_yData_error]  = deal(cell(1, NumUnique_xData));

for mbIndex = 1:CellSize
    for bIndex = 1:length(xCell{mbIndex})
        yData0    = yCell{mbIndex}(bIndex);
        yData{Unique_xData_Position{mbIndex}{bIndex}} = cat(1, yData{Unique_xData_Position{mbIndex}{bIndex}}, yData0);
    end
end

for LoopSetNumberIndex = 1:NumUnique_xData
    Ave_yData{LoopSetNumberIndex}         = mean(yData{LoopSetNumberIndex}); 
    Ave_yData_error{LoopSetNumberIndex}   = std(yData{LoopSetNumberIndex}, 0);        
end

Ave_yData         = cell2mat(Ave_yData');
Ave_yData_error   = cell2mat(Ave_yData_error');

end

