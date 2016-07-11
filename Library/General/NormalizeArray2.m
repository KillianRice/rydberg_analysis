function [Normalized_Array, Normalized_Array_error, Normalization_Array , Normalization_Array_error] = NormalizeArray2(analyVar, Array, Array_error, NormalizationDimension )
% only works when the normalization dimension is the first dimension;
% dataIndex is used in the first dimension of Array
    
    dim = NormalizationDimension;
    repVec = ones(1,length(size(Array)));
    repVec(dim) = size(Array,dim);
    
    xData = analyVar.ElectricField;
    if length(xData)~= size(Array,dim)
        error('Size of Electric Field data and size of SFI yData does not match.')
    end

    %% Need to have data sorted according to a sorted list of xData
    % not going to add this now since e field data comes in already sorted
    if issorted(xData)~=1
        error('Electric Field Data is not sorted. SFI counts data may therefore also be unsorted.')
    end
    xDataRep = [1,size(Array,2),size(Array,3)];
    xData = repmat(xData ,  xDataRep);
    
%     Normalization_Array          = nansum(Array,dim);    
%     Normalization_Array          = repmat(Normalization_Array , repVec );
    
    [slopeArray, offsetArray, Area] = deal(nan(size(Array)));
    for dataIndex = 1:size(Array,dim)-1
        slopeArray(dataIndex,:,:) = (Array(dataIndex+1,:,:)-Array(dataIndex,:,:))./(xData(dataIndex+1,:,:)-xData(dataIndex,:,:));
        offsetArray(dataIndex,:,:)= Array(dataIndex,:,:)-slopeArray(dataIndex,:,:).*xData(dataIndex,:,:);
        Area(dataIndex,:,:) = 0.5*slopeArray(dataIndex,:,:).*(xData(dataIndex+1,:,:).^2-xData(dataIndex,:,:).^2)+offsetArray(dataIndex,:,:).*(xData(dataIndex+1,:,:)-xData(dataIndex,:,:));
    end
    
    Area = nansum(Area,dim);
    Normalization_Array          = repmat(Area , repVec );

    Normalized_Array  = Array./Normalization_Array;
    
    Normalization_Array_error = nansum(Array_error.^2,dim).^0.5;
    Normalization_Array_error = repmat(Normalization_Array_error , repVec );
    
    Array_RelativeError = Array_error./Array;
    NormalizationArray_RelativeError = Normalization_Array_error./Normalization_Array;
    Normalized_Array_error = Normalized_Array.*(Array_RelativeError.^2 +NormalizationArray_RelativeError.^2).^0.5;
end

