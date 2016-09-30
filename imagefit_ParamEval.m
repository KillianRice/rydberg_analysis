function vargout = imagefit_ParamEval(varargin)
% This program is designed to read several datafiles and corresponding background
% files, extract relevant parameters from the number distribution fits, and
% plots these normalized data sets on the same graph.
%
% INPUTS:
%   varargin - variable input argument to allow passing of analysis
%              variables from analysis runner program. If not passed, the
%              program will call AnalysisData itself.
%              It is important to follow the input construction below for
%              varargin to retrieve variable data from other programs.
%              -- first  argument - analyVar
%              -- second argument - indivDataset
%
% OUTPUTS:
%   none
%
%
% NOTES:
%   12.10.13 - Changed name from imagefit_GaussianBimodalAndHistogramV2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load variables and file datacreate
close all
if nargin == 0 % If run without arguments
    analyVar     = AnalysisVariables;
else
    analyVar     = varargin{1}; % if arguments are passed analyVar must be first
end

if analyVar.LoadData 
    
    load([analyVar.dataDir analyVar.DataName])
   
else
    
    if nargin == 0 % If run without arguments
        indivDataset = get_indiv_batch_data(analyVar);
    else
        indivDataset = varargin{2}; % indivDataset must be second
    end

end

%% Modify indivDataset cell to contain fit coefficients and OD image
if analyVar.UseImages
        [indivDataset,avgDataset] = add_fit_indiv_batch(analyVar,indivDataset);

    %% Number Distribution Fit Evaluation
    if analyVar.plotFitEval
        % Plot cloud evolution
        evolAxH = create_plot_evol(analyVar,indivDataset); 
        % Plot 2D fit, 1D cross section of fit, and residuals
        [fit2DAxH, fit1DAxH, resAxH, fitBEC1DAxH] = create_plot_fitEval(analyVar,indivDataset);

        % Set color limits as the same for all plots in a scan
        for basenameNum = 1:analyVar.numBasenamesAtom
            % Find the scales with the greatest range for all plots
            bestColorLim = diag(feval(@(x) [min(x);max(x)],cell2mat(get(evolAxH{basenameNum},'CLim'))));
            best1DLim    = [-0.1 max(max(cell2mat(get(fit1DAxH{basenameNum},'YLim'))))];

            set(evolAxH{basenameNum},'CLim', bestColorLim)  % apply color lim to evolution
            set(fit2DAxH{basenameNum},'CLim', bestColorLim) % apply color lim to fit2D
            set(resAxH{basenameNum},'CLim', bestColorLim)   % apply color lim to residuals
            set(fit1DAxH{basenameNum},'YLim',best1DLim)     % apply y range to fit1D

            if strcmpi(analyVar.InitCase,'Bimodal') % if there is a separate plot showing condensate cross-section
                bestBEC1DLim  = [-0.1 max(max(cell2mat(get(fitBEC1DAxH{basenameNum},'YLim'))))];
                set(fitBEC1DAxH{basenameNum},'YLim',bestBEC1DLim)     % apply y range to fit1D
            end
        end
    end

    %% Image statistics
    % Extract relevant experimental statistics from each image and plot once found

    % Atom Number - Find number in each window of each image
    indivDataset = param_ext_AtomNum(analyVar,indivDataset);
    % Plotting number in each batch
    if analyVar.plotNum; create_plot_AtomNum(analyVar,indivDataset); end

    % Cloud Size - X & Y saved to indivDataset
    indivDataset = param_ext_CloudRadius(analyVar,indivDataset);
    % Plotting radius of each batch
    if analyVar.plotSize; create_plot_CloudRadius(analyVar,indivDataset); end

    % Temperature and/or Trap Frequency only relevant if sampleType is Thermal or bimodal BEC
    if strcmpi(analyVar.sampleType,'Thermal') || strcmpi(analyVar.InitCase,'Bimodal')

    % Temperature - X & Y saved to indivDataset
        indivDataset = param_ext_AtomTemp(analyVar,indivDataset);
        % Plotting temperature of each batch
        if analyVar.plotTemp; create_plot_AtomTemp(analyVar,indivDataset); end

        % If bimodal in particular then find trapping frequency
        if strcmpi(analyVar.InitCase,'Bimodal')
    % Trap Frequency - Saved in Hz
        indivDataset = param_ext_TrapFreq(analyVar,indivDataset);
        % Plotting trap frequencies of each batch
        if analyVar.plotTrapFreq; create_plot_TrapFreq(analyVar,indivDataset); end
        end

    end

    if analyVar.plotCounts
        create_plot_counts(analyVar,indivDataset);
    end


    %% Averaged statistics
    % Only average if necessary by enforcing that some scans share the averaging variable (not every scan is unique)
    % and that the averaging variable is nonzero (zero is default value so may not actually be averagable)
    if length(cell2mat(analyVar.posOccurUniqVar)) > length(analyVar.posOccurUniqVar) & analyVar.uniqScanList ~= 0;
    % Atom Number - average number of atoms in each window across similar scans
        avgDataset = param_ext_MeanNum(analyVar,indivDataset,avgDataset);
        % Plotting mean number in each batch
        if analyVar.plotMeanNum; create_plot_MeanNum(analyVar,avgDataset); end

    % Cloud Size - Average size in each window
        avgDataset = param_ext_MeanCloudRadius(analyVar,indivDataset,avgDataset);
        % Plotting radius of each batch
        if analyVar.plotMeanSize; create_plot_MeanCloudRadius(analyVar,avgDataset); end

        % Temperature and/or Trap Frequency only relevant if sampleType is Thermal or bimodal BEC
        if strcmpi(analyVar.sampleType,'Thermal') || strcmpi(analyVar.InitCase,'Bimodal')

    % Temperature - % Average temperature
            avgDataset = param_ext_MeanTemp(analyVar,indivDataset,avgDataset);
            % Plotting temperature of each batch
            if analyVar.plotMeanTemp; create_plot_MeanTemp(analyVar,avgDataset); end

            % If bimodal in particular then find trapping frequency
            if strcmpi(analyVar.InitCase,'Bimodal')
    % Trap Frequency - Average
                avgDataset = param_ext_MeanTrapFreq(analyVar,indivDataset,avgDataset);
                % Plotting trap frequencies of each batch
                if analyVar.plotMeanTrapFreq; create_plot_MeanTrapFreq(analyVar,avgDataset); end
            end
        end
    end
    else
        avgDataset = [];
end
%% Higher order parameter fitting
% Using the extracted parameters from above (i.e. number) we can call additional functions specified in
% AnalysisVariables to analyze and fit higher order parameters. For example, if the scans show a resonance
% lineshape, we can fit the feature and extract the resonance amplitude, position, and width. 
%
% Function called here can be specified in AnalysisVariables under Lineshape fitting but should be self
% contained. Any additional data needed should not be added to AnalysisVariables. These functions should
% perform all calculations relevant to the specified operation and should not pass data back to
% imagefit_ParamEval.
%
% The idea of this is that further analysis act as 'plugins' that do not change, modify, or obfuscate, the
% core functionality of the imagefit routine.
for lineFitIter = 1:length(analyVar.fitLineFunc)
    % Construct function handle from cell of function names
    funcHand = str2func(analyVar.fitLineFunc{lineFitIter});
    % Call function with default arguments
    funcOut = funcHand(analyVar,indivDataset,avgDataset);
end
%%%%%%%%%%%%%%%%%%%%%%%% might break code
% for index = 1:length(indivDataset)
%     indivDataset{index} = funcOut{index};
% end
%%%%%%%%%%%%%%%%%%%%%%%%%


%% Wrap Up
fclose('all'); % Close any file handles which may be open
if analyVar.SavePlotData == 1 % Output data flag in
    vargout = v2struct(cat(1,'fieldNames',who()));
end