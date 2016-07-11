function ParentStruct = Average_UV_Spectrum3(ParentStruct)
% Average data within trace

xData = ParentStruct.xData;
NumxData = length(xData);
yData = ParentStruct.yData;
NumDensities = ParentStruct.NumDensities;

[yData_Average, yData_Average_error] = deal(cell(1, NumDensities));
for DensityIndex = 1:NumDensities
    [yData_Average{DensityIndex}, yData_Average_error{DensityIndex}] = deal(cell(1, NumxData));
    for xDataIndex = 1:NumxData
        yData_Average{DensityIndex}{xDataIndex} = mean(yData{DensityIndex}{xDataIndex}); % average over the data from the different data sets at unique frequency and density points
        yData_Average_error{DensityIndex}{xDataIndex} = std(yData{DensityIndex}{xDataIndex}, 0 );
    end
    yData_Average{DensityIndex} = cell2mat(yData_Average{DensityIndex}');
    yData_Average_error{DensityIndex} = cell2mat(yData_Average_error{DensityIndex}');
end

ParentStruct.yData_Average = yData_Average;
ParentStruct.yData_Average_error = yData_Average_error;

end

