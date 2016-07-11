function [indivDataset] = MCP_PulseHeightDistribution(analyVar,indivDataset,avgDataset)

%% Load Data
indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

%% plot indiv UV spectra
[ indivDataset ] = FormatPHD(analyVar,indivDataset);
[ output_args ]  = plot_indiv_PHD(analyVar,indivDataset);

%% Calculated Average Pulse Distribution
[unique_Voltage, AveUVSpectrum, AveUVSpectrum_error] = Average_PHD(analyVar,indivDataset);

%% Plots Average UV Spectra
[ output_args ]  = plot_AvePHD(analyVar, indivDataset, unique_Voltage, AveUVSpectrum, AveUVSpectrum_error);
  
end

