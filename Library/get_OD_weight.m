function errCell = get_OD_weight(weightPeak,OD_Fit_Image)
% Function to return the images to fit in a cell as well as the weighting
% factor. If analyVar.weightPeak == 0 then ones are returned in errCell.
%
% INPUTS:
%   analyVar         - Structure containing all the global variables needed for analysis
%   OD_Fit_ImageCell - Processed OD image from the experiment
%
% OUTPUTS:
%   errCell - Cell containing matricies used to weight image in fitting
%
% NOTE:
%   This ability was left as a functional call in the event that more
%   complex weighting functions might be needed in the future. (Jim - 12/18/13)

%% Get weighting matrix if needed
if weightPeak == 1
    % normalized error - relative to average pixel value
    funcErr = @(OD_Image) (1 - mean(mean(OD_Image))./OD_Image);
else
    funcErr = @(OD_Image) (ones(size(OD_Image)));
end

errCell = funcErr(OD_Fit_Image);
end