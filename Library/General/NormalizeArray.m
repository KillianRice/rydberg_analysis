function [Normalized_Array, Normalized_Array_error, Normalization_Array , Normalization_Array_error] = NormalizeArray( Array, Array_error, NormalizationDimension )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    dim = NormalizationDimension;
    Normalization_Array          = nansum(Array,dim);
    
    repVec = ones(1,length(size(Array)));
    repVec(dim) = size(Array,dim);
    
    Normalization_Array          = repmat(Normalization_Array , repVec );
    
    Normalized_Array  = Array./Normalization_Array;
    
    Normalization_Array_error = nansum(Array_error.^2,dim).^0.5;
    Normalization_Array_error = repmat(Normalization_Array_error , repVec );
    
    Array_RelativeError = Array_error./Array;
    NormalizationArray_RelativeError = Normalization_Array_error./Normalization_Array;
    Normalized_Array_error = Normalized_Array.*(Array_RelativeError.^2 +NormalizationArray_RelativeError.^2).^0.5;
end

