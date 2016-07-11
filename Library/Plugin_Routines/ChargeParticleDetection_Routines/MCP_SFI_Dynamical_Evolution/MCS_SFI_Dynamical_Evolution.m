function [indivDataset] = MCS_SFI_Dynamical_Evolution(analyVar,indivDataset,avgDataset)

%% Convert TOF arrival time

[analyVar] = CalculateFieldRamp(analyVar);

% PlotFieldRamp(analyVar);

%% Load Data
indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

%% Calculated Average UV spectra
[unique_ExpTime, Ave_SFI, Ave_SFI_error] = Calculate_Ave_SFI(analyVar,indivDataset);

%% Normalize to Unity Area
NormalizeFlag = 1;
if NormalizeFlag 
    for EntryIndex = 1:length(Ave_SFI)
        [Ave_SFI{EntryIndex}, Ave_SFI_error{EntryIndex}] = NormalizeArray3(analyVar.ElectricField, Ave_SFI{EntryIndex}, Ave_SFI_error{EntryIndex});
    end
end
%% Plots Average SFI
[ output_args ]  = plot_Ave_SFI(analyVar, indivDataset, unique_ExpTime, Ave_SFI, Ave_SFI_error, NormalizeFlag);
[ output_args ]  = plot_Ave_Dynamical_Evolution(analyVar, indivDataset, unique_ExpTime, Ave_SFI, Ave_SFI_error, NormalizeFlag, avgDataset);
end

