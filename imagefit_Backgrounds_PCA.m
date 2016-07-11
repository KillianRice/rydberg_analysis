function imagefit_Backgrounds_PCA(varargin)
%This program is designed to read several datafiles and corresponding background
%files, plots these normalized data sets on the same graph.
%
% INPUTS:
%   varargin - variable input argument to allow passing of analysis
%              variables from BEC_Analysis_Runner. If not passed, the
%              program will call AnalysisData and get_indiv_batch_data itself.
%              It is important to follow the input construction below for
%              varargin to retrieve variable data from other programs.
%              -- first  argument - analyVar
%              -- second argument - indivDataset
%
% OUTPUTS:
%   none
%
% MISC:
%#ok<*PFBNS> - suppress all instances of 'this variables is indexed but not
%              sliced'. Passing large arrays may incur unnecessary communication
%              overhead to the workers but we are only reading from the
%              analyVar and indivDataset structures and not changing them.
%              If there is a performance issue look into the function
%              WorkerObjWrapper
%
% NOTES:
%   12.10.13 - Changed name from imagefit_GaussianBimodalAndHistogramFittingA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Workspace specific options
warning('off','all') % Suppress parfor warnings in command window

%% Load variables and file data
if nargin == 0 % If run without arguments
    analyVar     = AnalysisVariables;
    indivDataset = get_indiv_batch_data(analyVar);
else
    analyVar     = varargin{1}; % if arguments are passed analyVar must be first
    indivDataset = varargin{2}; % indivDataset must be second
end

%%% Reduce time needed for fitting by stopping evaluations forcibly
if analyVar.quickFit == 1
    optimOptions = optimset('Display','off','LargeScale','off','MaxFunEvals',100,'MaxIter',100,'TolX',1e-2);
elseif analyVar.quickFit == 0
    optimOptions = optimset('Display','off','LargeScale','off');
end

%% Initialize parallel workers
%Open matlabpool if none open
if matlabpool('size') == 0
     matlabpool open
end

%% Loop through each batch file listed in analyVar.basenamevectorAtom
parfor basenameNum = 1:analyVar.numBasenamesAtom
    % this will keep track of all the files analyzed in all the batches
    fprintf('\nBackground fitting batch file %g of %g\n',basenameNum,analyVar.numBasenamesAtom)
    
%% Approximation of orthogonal background basis using PCA
%%%%%%%-----------------------------------%%%%%%%%%%
    % Using background images to find orthogonal basis to approximate cloud background
    % Compute principal components from background images
    [pcCoeffs, pcBasis, pcEigenVals] = princomp(indivDataset{basenameNum}.BackgroundNotCloud);
    if length(pcEigenVals) > analyVar.dimReduceLim
        % find number of vectors with cumulative variance set in AnalysisVariables )varianceLim)
        varLim = length(nonzeros(cumsum(pcEigenVals./sum(pcEigenVals)) <= analyVar.varianceLim));
    else
        varLim = length(pcEigenVals); % If less than dimensional reduction limit then use all states
    end
    
%% Loop through each image and find background state
%%%%%%%-----------------------------------%%%%%%%%%%
    % this loop fits the background for all atom files in this dataset
    for k = 1:indivDataset{basenameNum}.CounterAtom  
        % take the inital conditions of the nth image as the projection onto the pcBasis
        InitialCondition = pcCoeffs(k,1:varLim);
        
        % Minimize the nth state in the original basis to the new pcBasis
        A  = fminunc(@(A) WeightedBackgroundFunction(A,...
            indivDataset{basenameNum}.AtomsNotCloud(:,k) - mean(indivDataset{basenameNum}.AtomsNotCloud(:,k)),...
            pcBasis(:,1:varLim)),InitialCondition,optimOptions);

        % Coefficients define how to transform original basis into pcBasis
        % Need BackCloud in PCA basis to construct the nth image background in
        % terms of the PCA basis of the cloud background
        pcBGCloud = (pcCoeffs(:,1:varLim)'*indivDataset{basenameNum}.BackgroundCloud')';
        % Construct linear approximation of cloud background using PCA basis of not cloud backgrounds
        BackCloudApproxState = sum(bsxfun(@times,pcBGCloud,A),2);

%% Create optical depth (OD) image
%%%%%%%-----------------------------------%%%%%%%%%%
        % Retrieve cloud matrix for single image
        roiImageAtom = reshape(indivDataset{basenameNum}.AtomsCloud(:,k),[1 1].*(2*analyVar.roiWinRadAtom(basenameNum) + 1));
        roiImageBack = reshape(BackCloudApproxState, size(roiImageAtom));
        
        % Bin and trim atoms images
        cutImageCell = TrimAndBin(analyVar,mat2cell([roiImageAtom;roiImageBack],[1 1]*size(roiImageAtom,1),size(roiImageAtom,2)));
        [cutImageAtom, cutImageBack] = cutImageCell{:};
        
        % Generate OD image using Beer's Law (subtract fitted background)
        OD_Image_Single = (log(abs(cutImageBack)) - log(abs(cutImageAtom)));
        
        %%% Save OD
        dlmwrite([analyVar.analyOutDir char(indivDataset{basenameNum}.fileAtom(k)) analyVar.ODimageFilename],OD_Image_Single,'\t');
        
    end %loop through files in dataset (one batchfile)
end %end loop through batches

%% Cleanup Parallel workspace
warning('on','all') %% Reenable warnings

%% Wrap Up
fclose('all'); % Close any file handles which may be open
fprintf('The background fitting is completed.\n\n')
end