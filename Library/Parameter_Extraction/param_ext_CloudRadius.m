function [indivDataset] = param_ext_CloudRadius(analyVar,indivDataset)
% Function to calculate the thermal and BEC cloud size from each 
% image found from the 2D fit parameters.
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   indivDataset - Output will add the fields below to the structure
%                  indivDatset
%                     cloudRadius - Radius (in microns) of cloud, for
%                                   non-BEC fits this is the gaussian width, for BEC
%                                   fits this is the BEC width

%% Define functions used to find atom number
%%%%%%%-----------------------------------%%%%%%%%%%
% Cloud radius accounting for finite resolution of the imaging system
% Reference - Mi Yan's PhD thesis Appendix A (eq. A.6)
effPixelSize = analyVar.sizefactor*1e6; %um, pixel size
funcCloudRad = @(coeffs,fitWidth) sqrt((abs(coeffs.(fitWidth)).*effPixelSize).^2 - analyVar.CameraRes.^2);

%% Decide cloud width parameters needed
%%%%%%%-----------------------------------%%%%%%%%%%
switch analyVar.sampleType
    case {'Thermal' 'Lattice'}
        paramRadX = 'sigX';     paramRadY = 'sigY';
    case 'BEC'
        if analyVar.pureSample
            paramRadX = 'sigX'; paramRadY = 'sigY';            
        else
            paramRadX = 'sigX_BEC'; paramRadY = 'sigY_BEC';
        end
end

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for basenameNum = 1:analyVar.numBasenamesAtom
    % Preallocate nested loop variables
    [cldRadX cldRadY]...
        = deal(NaN(sum(analyVar.LatticeAxesFit),indivDataset{basenameNum}.CounterAtom));
    
    % Processes all the image files in the current batch
    for k = 1:indivDataset{basenameNum}.CounterAtom;
%% Find Cloud Radius of each window
% Find size in each window (if multiple windows)
%%%%%%%-----------------------------------%%%%%%%%%%
        % Size of cloud
        cldRadX(:,k) = cellfun(@(x) funcCloudRad(x,paramRadX),indivDataset{basenameNum}.All_fitParams{k});
        cldRadY(:,k) = cellfun(@(x) funcCloudRad(x,paramRadY),indivDataset{basenameNum}.All_fitParams{k});
    end
    
    % Save cloud radius for each window into the indivDataset structure
    indivDataset{basenameNum}.cloudRadX = cldRadX;
    indivDataset{basenameNum}.cloudRadY = cldRadY;
end