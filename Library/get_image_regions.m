function [image_Index,roiWin_Index] = get_image_regions(analyVar,basenameNum)
% Function to return logical index matrix for separating atom images into
% ROI background and cloud portions. Supports multiple window assignment
% for lattice applications.
%
% INPUTS:
%   analyVar    - Structure containing analysis variables
%   basenameNum - Indexes which basename to find data for
%
% OUTPUTS:
%   image_Index - Matrix the size of matrix received from the camera. This
%                 matrix has values 2 where the atom cloud is located.
%                 Value 1 is the ROI region around the cloud which is used
%                 in background fittting. Value 0 is the region outside the
%                 ROI which is not considered. This is an aggregate matrix
%                 which shows all cloud windows considered at once.
%   cloud_Index - 3-dim matrix which contains the individual cloud windows
%                 instead of the aggregate as in image_Index. Value
%                 assignment is the same as in image_Index.

%% Initialize Variables
image_Index  = zeros(analyVar.matrixSize); % create logical index matrix with size of camera image
roi_Index    = zeros(2*analyVar.roiWinRadAtom(basenameNum) + 1); % index matrix of ROI
[X,Y]        = meshgrid(1:analyVar.matrixSize(2),1:analyVar.matrixSize(1)); % Create absolute grid
[roiX,roiY]  = meshgrid(-analyVar.roiWinRadAtom(basenameNum):analyVar.roiWinRadAtom(basenameNum));

%% Create cell for the individual windows with the ROI
numWin       = sum(analyVar.LatticeAxesFit);
roiWin_Index = mat2cell(repmat(roi_Index,numWin,1),ones(numWin,1)*size(roi_Index,1),size(roi_Index,2));

%% Find number of  cloud windows and their relative offsets from the center
% Enumerate the number of windows to consider into vector of center positions
% If analyzing lattice then look for multiple windows
peakOffset = round(analyVar.LatticeAxesFit.*analyVar.LatFreeExpCalib.*analyVar.droptimeAtom(basenameNum));

%% Check if the ROI that is defined can fit all the windows
% ROI should be large enough for all the smaller windows to fit inside
farWinEdge = max(peakOffset) + analyVar.cloudWinRadAtom; %Farthest window edge from the center
if farWinEdge > analyVar.roiWinRadAtom
    error('The ROI window is not large enough. Please increase to %g or greater.',farWinEdge)
end

%% Check that at least one window is defined
if isempty(nonzeros(analyVar.LatticeAxesFit))
    error('Please select at least one window to analyze.')
end
                  
%% Define ROI window in image_Index
relX = X - analyVar.cloudColCntrAtom(basenameNum); % Create relative grid by centering
relY = Y - analyVar.cloudRowCntrAtom(basenameNum); % around the cloud
% full image index (size of camera image)
image_Index(abs(relX) <= analyVar.roiWinRadAtom(basenameNum) & abs(relY) <= analyVar.roiWinRadAtom(basenameNum)) = 1;

%% Define cloud windows in image_Index
% Cloud window borders - [StartX, StopX, StartY, StopY]
cloudBorder = [-1 1 -1 1].*analyVar.cloudWinRadAtom(basenameNum);
j = 1; % iteration variable to correctly index into the roi cell
for i = 1:length(peakOffset)
    if analyVar.LatticeAxesFit(i)
        % Initialize translation vector on every iteration
        translateVec = zeros(1,4);
        
        % Following convention of ordering axes defined in AnalysisVariables
        % then i = 1 is the central peak, i = 2:5 is horizontal displacement,
        % and i = 6:7 are vertical displacement
        if i <= 5
            translateVec(1:2) = peakOffset(i);
        else
            translateVec(3:4) = peakOffset(i);
        end
        
        % Borders of the window being considered
        newCloudBorder = cloudBorder + translateVec;
        
        % Aggregate cloud windows into full image_Index
        image_Index(relX >= newCloudBorder(1) & relX <= newCloudBorder(2)  &...
                    relY >= newCloudBorder(3) & relY <= newCloudBorder(4)) = 2;
        
        % Save each window into the roi cell
        roiWin_Index{j}(roiX >= newCloudBorder(1) & roiX <= newCloudBorder(2)  &...
                        roiY >= newCloudBorder(3) & roiY <= newCloudBorder(4)) = 1;
        j = j + 1;
    end
end