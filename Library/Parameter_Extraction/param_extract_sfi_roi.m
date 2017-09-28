function [roi_min, roi_max] = param_extract_sfi_roi( analyVar, indivDataset )
%PARAM_EXTRACT_SFI_ROI returns the roi of the mcs spectra as a vector
%   Joe Whalen - 2016.12.15
    
    roi_min = indivDataset.mcs_roiMin;
    
    if indivDataset.mcs_roiMax == -1
        roi_max = size(indivDataset.mcsSpectra{1},1);
    else
        roi_max = indivDataset.mcs_roiMax;
    end

end

