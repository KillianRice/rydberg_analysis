function plot_OD_Images
% Function used for troubleshooting that will plot the OD images calculated
% in imagefit_Background_PCA

analyVar     = AnalysisVariables;
indivDataset = get_indiv_batch_data(analyVar);

evolAxH = create_plot_evol(analyVar,add_fit_indiv_batch(analyVar,indivDataset));

% Set color limits as the same for all plots in a scan
for basenameNum = 1:analyVar.numBasenamesAtom
    bestColorLim = diag(feval(@(x) [min(x);max(x)],cell2mat(get(evolAxH{basenameNum},'CLim'))));
    set(evolAxH{basenameNum},'CLim', bestColorLim)  % apply color lim to evolution
end