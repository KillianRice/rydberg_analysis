function [ Normalized_Array, Normalized_Array_error ] = ApplyNormalization( Array, Array_error, Normalization_Array,Normalization_Array_error, repmatOption, extraDim )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
switch repmatOption
    case 1 % match dimensions of normaliation array and data array

    repVec              = ones(1,length(size(Array)));
    repVec(extraDim)    = size(Array,extraDim);
    
    Normalization_Array         = repmat(Normalization_Array,repVec);
    Normalization_Array_error   = repmat(Normalization_Array_error,repVec);
        
    Normalized_Array          = Array./Normalization_Array;
    
    Array_RelativeError = Array_error./Array;
    NormalizationArray_RelativeError = Normalization_Array_error./Normalization_Array;
    Normalized_Array_error = Normalized_Array.*(Array_RelativeError.^2 +NormalizationArray_RelativeError.^2).^0.5;
    
    case 2 % if normalization array and data array have the same dimentionality
        
    Normalized_Array          = Array./Normalization_Array;
    
    Array_RelativeError = Array_error./Array;
    NormalizationArray_RelativeError = Normalization_Array_error./Normalization_Array;
    Normalized_Array_error = Normalized_Array.*(Array_RelativeError.^2 +NormalizationArray_RelativeError.^2).^0.5;
end

