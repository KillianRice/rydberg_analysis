function [indivDataset] = MCS_Indiv_UV_Spectrum(analyVar,indivDataset,avgDataset)
%% Load Data
indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

%% arrange data into cell array
SFI_roi = -1; % use -1 to use all the bins in the SFI
[SynthFreq, UVSpectrum]  = arrangeData_UVSpectrum_indivdatasets(analyVar,indivDataset,SFI_roi);
%% Plot one figure per data set, plot spectrum at all densitites in each figure.
[ output_args ]  = plot_UVSpectrum_indivdatasets(SynthFreq, UVSpectrum);

%% Plot one figure per density, plot i'th density of each data set
whichDensities = 1:3;
[ output_args ]  = plot_UVSpectrum_indivdensities(SynthFreq, UVSpectrum, whichDensities);

end

