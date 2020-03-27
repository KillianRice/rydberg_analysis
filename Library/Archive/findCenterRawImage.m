function [roiRowStart,roiRowStop,roiColStart,roiColStop] = findCenterRawImage(analyVar,fileBack,fullRawImageAtom)
% Finds approximate center of cloud by filtering raw image to smooth data
% then finds maximum and returns roi and window parameters for background
% fitting.
%
% INPUTS:
%   fullRawImageAtom - Raw Atom data matrix from LabView
%   analyVar         - Structure containing all variables needed to run
%                      fitting routine
%   k                - Index of Atom Image listed in dataset batch file
%
% OUTPUTS:
%   roiRowStart -
%   roiRowStop  -
%   roiColStart -
%   roiColStop  -
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if analyVar.dynamicCenter || analyVar.viewCloudCut
    % Load background to clearly identify cloud center
    t = [analyVar.dataDir char(fileBack) analyVar.dataBack]; tFID = fopen(t,'rb','ieee-be');
    if analyVar.binaryread == 1;
        fullRawImageBack = fread(tFID,analyVar.matrixsize,'*int16');
    elseif analyVar.binaryread == 0;
        fullRawImageBack = transpose(dlmread(t));
    end; fclose(tFID);
    
    % Easiest way to eliminate abberations that dominate atom image
    prelimRawAtoms = log(abs(double(fullRawImageBack))) - log(abs(double(fullRawImageAtom)));
end

if ~analyVar.dynamicCenter
    % Hardcode center from AnalysisVariables
    cloudYCenter = analyVar.cloudYCenter;
    cloudXCenter = analyVar.cloudXCenter;
else
    % Get full matrix size
    [m n] = size(fullRawImageAtom);
    
    % Smooth Atom image and find location of maximum
    filterImageAtom = filter2(ones(round(size(prelimRawAtoms)/analyVar.centFiltWght)),prelimRawAtoms);
    [cloudYCenter,cloudXCenter] = ind2sub(size(filterImageAtom),find(filterImageAtom == min(min(filterImageAtom))));
    %surf(filterImageAtom,'EdgeColor','None') % For troubleshooting
    
    % sqGrayFilterAtom = zeros(ceil(sqrt(max([m n])))^2);
    % sqGrayFilterAtom(1:m,1:n) = mat2gray(filterImageAtom);
end

% Large region including atoms, used to extract subset of atom image from full image
roiRowStart = cloudYCenter - analyVar.roiWindowRadius;
roiRowStop  = cloudYCenter + analyVar.roiWindowRadius;
roiColStart = cloudXCenter - analyVar.roiWindowRadius;
roiColStop  = cloudXCenter + analyVar.roiWindowRadius;


%%% For troubleshooting cloud center positions use code below to
%%% visualize cloud center and background part
if analyVar.viewCloudCut == 1
    roiPrelimImage = ...
        prelimRawAtoms(roiRowStart:roiRowStop, roiColStart:roiColStop)';
    trshtROIImageCloud = double(roiPrelimImage); trshtROIImageBack = double(roiPrelimImage);
    trshtROIImageCloud(analyVar.cloudX > analyVar.cloudWindowRadius | analyVar.cloudY > analyVar.cloudWindowRadius) = 0;
    trshtROIImageBack(not(analyVar.cloudX > analyVar.cloudWindowRadius | analyVar.cloudY > analyVar.cloudWindowRadius)) = 0;
    figure;
    subplot(1,2,1); h1 = pcolor(trshtROIImageCloud); subplot(1,2,2); h2 = pcolor(trshtROIImageBack); set([h1 h2],'EdgeColor','none');
    %error('Change analyVar.viewCloudCut to zero and rerun')
    pause
end