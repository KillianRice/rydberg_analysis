function imagefit_GaussianBimodalAndHistogramFittingA(varargin)
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
    optimOptions = optimset('Display','off','MaxFunEvals',100,'MaxIter',100,'TolX',1e-2);
elseif analyVar.quickFit == 0
    optimOptions = optimset('Display','off');
end

%% Initialize parallel workers
%Open matlabpool if none open
if matlabpool('size') == 0
    matlabpool open
end

%% Loop through each batch file listed in analyVar.basenamevectorAtom
for basenamenumber = 1:analyVar.numberofbasenamesAtom
    % this will keep track of all the files analyzed in all the batches
    fprintf('\nBackground fitting batch file %g of %g\n',basenamenumber,analyVar.numberofbasenamesAtom)
    
    %%% Setup parallel processing workspace
    InitialCondition = ones(1,indivDataset{basenamenumber}.CounterBack)./indivDataset{basenamenumber}.CounterBack; % vector for fminsearch
    parfor k = 1:indivDataset{basenamenumber}.CounterAtom  %this loop fits the background for all atom files in this dataset
        % Check whether cloud center changes
        if (analyVar.dynamicCenter); q = k; else q = 1; end;
        
        % Minimization procedure to find coefficients of the background images to fit the AtomNotCloud (background around cloud image)
        [A]  = fminsearch(@(A) WeightedBackgroundFunction(A,indivDataset{basenamenumber}.AtomsNotCloud(k,:),...
                  indivDataset{basenamenumber}.BackgroundNotCloud(:,:,q)),InitialCondition,optimOptions);
        
        % Write output to disk
        dlmwrite([analyVar.analyOutDir char(indivDataset{basenamenumber}.fileAtom(k)) analyVar.BackFitParamsFilename],A,'\t');
        
    end %loop through files in dataset (one batchfile)
end %end loop through batches

%% Cleanup Parallel workspace
warning('on','all') %% Reenable warnings

%% Wrap Up
fclose('all'); % Close any file handles which may be open
fprintf('The background fitting is completed.\n\n')