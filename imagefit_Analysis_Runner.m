% Script to run complete analysis of Neutral table data
% 
% Please be sure to have the correct date defined in AnalysisVariables
% prior to running.

% clear current figures
close all

% Load variables and file data
analyVar = AnalysisVariables;
indivDataset = get_indiv_batch_data(analyVar);

% Background fitting
imagefit_Backgrounds_PCA(analyVar,indivDataset)

% Functional fitting
imagefit_NumDistFit(analyVar,indivDataset)

% Plotting routine
if analyVar.SavePlotData == 1
    % Save data from output
    PlotData = imagefit_ParamEval(analyVar,indivDataset);
else
    imagefit_ParamEval(analyVar,indivDataset);
end