function indivDataset = MCS_Integrated_SFI_Spectrum(analyVar, indivDataset, avgDataset)
    
    % MCS_Integrated_SFI_Spectrum - Joe Whalen 2016.12.14
    % Generate a plot of MCS counts vs. independent variable
    % (imagevcoatom), integral of mcs counts is calculated over the ROI
    % defined in the master batch file entry for the scan.
    
    %% calculate the integral of the sfi spectrum over the region of interest
    indivDataset = param_extract_sfi_integral(analyVar, indivDataset);
    
    %% plot the data
    plot_MCS_Integrated_SFI_Spectrum(analyVar, indivDataset);
    
end