function [Normalized_Array, Normalized_Array_error] = NormalizeArray3(xData, yData, yData_error)
     %look at NormalizeArray2 for code that deals with multidimenstional data

    if length(xData)~= length(yData)
        error('FC: Size of xData and yData does not match.')
    end

    %% Need to have data sorted according to a sorted list of xData
    % not going to add this now since e field data comes in already sorted
    if issorted(xData)~= 1 && issorted(flipud(xData))~=1
        error('FC: xData is not sorted in either ascending or descending order.')
    end
    
    %% Compute the area between pairs of points
    [DeltaX, AveY, AreaData, AreaData_error] = deal(nan(size(yData)));
    for dataIndex = 1:length(yData)-1
        DeltaX(dataIndex)           = xData(dataIndex+1)-xData(dataIndex);
        AveY(dataIndex)             = (yData(dataIndex+1)+yData(dataIndex))/2;
        AreaData(dataIndex)         = DeltaX(dataIndex)*AveY(dataIndex);
        AreaData_error(dataIndex)   = DeltaX(dataIndex)*0.5*(yData_error(dataIndex+1)^2+yData_error(dataIndex)^2)^0.5;
    end
    
    AreaData = nansum(AreaData);
    if AreaData ~= 0
        AreaData_error = (nansum(AreaData_error.^2))^0.5;
        AreaData_RelativeError = AreaData_error/abs(AreaData);
        AreaData_RelativeError = repmat(AreaData_RelativeError,size(yData));  
        %% Compute normalized yData
        Array_RelativeError     = yData_error./yData;
        Normalized_Array        = yData/abs(AreaData);
        Normalized_Array_error  = Normalized_Array.*nansum([Array_RelativeError.^2 AreaData_RelativeError.^2],2).^0.5;
    else
        Normalized_Array        = zeros(size(yData));
        Normalized_Array_error  = zeros(size(yData_error));   

    end
end

