function [indivDataset] = MCS_Spectrum_Fit(analyVar,indivDataset,avgDataset)

%% Convert TOF arrival time

[analyVar] = CalculateFieldRamp(analyVar);

PlotFieldRamp(analyVar);

%% Convert TOF arrival time II: use for some of the plots to corrext plotting off by 1 error
% analyVar.ArrivalTime2 = bin_time_convert*(analyVar.roiStart:analyVar.roiEnd);
% analyVar.PushPullPotentialDiff2 = ...
%     analyVar.V_div_Push*analyVar.Push_Voltage*(1-exp(-analyVar.ArrivalTime2/analyVar.PushVoltageRC))...
%     -analyVar.V_div_Pull*analyVar.Pull_Voltage*(1-exp(-analyVar.ArrivalTime2/analyVar.PullVoltageRC));%volts
% analyVar.ElectricField2 = 0.3*analyVar.PushPullPotentialDiff2;%V cm^-1, electric field at atoms

%% Load Data
indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

%% UV Frequency Spectrum
%master batch entries are repetitions of experiment, each batch entries is
%an SFI spectrum at different synth frequencies.
if analyVar.UV_Freq_Spectra == 1
    [ indivDataset ] = IntegrateSFI(analyVar,indivDataset);
    plot_SFI_Integral(analyVar,indivDataset);
end

%% Format Data
    %% Average Data
    [ indivDataset ] = AverageData(analyVar,indivDataset);
    
    %% Normalize Data
    [ indivDataset ] = AbsoluteNormalization(analyVar, indivDataset);
    [ indivDataset ] = RelativeNormalization(analyVar, indivDataset);
    
%% Plot Raw Data (No Fitting)    
    
%     %% plot TOF MCS signal
%         if analyVar.plotMCSTraces_Flag
%             plotMCSTraces(analyVar, indivDataset)
%         end
% 
%         if analyVar.plotMCSTraces_counts_vs_delaytime_Flag
%             plotMCSTraces_counts_vs_delaytime( analyVar,indivDataset )
%         end

        if analyVar.permuationPlots
            plot_AvgCounts_vs_xVariable2(analyVar, indivDataset) % ** first number sets the xaxis, second sets the legend, 1 for E field, 2 for Field Delay, 3 for Density, 4 for frequency
%             plot_Diff_States_Together3(analyVar, indivDataset)
            plot_Diff_States_Together_Publish(analyVar, indivDataset)
            
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 1, 3)
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 1, 4)
        %     
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 2, 1) % **
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 2, 3)
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 2, 4)
        %     
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 3, 1)
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 3, 2)
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 3, 4)
        %     
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 4, 1)
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 4, 2)
        %     plot_AvgCounts_vs_xVariable(analyVar, indivDataset, 4, 3)
        end
        
%     %% plot Avg TOF MCS signal
%         if analyVar.plotAvgMCSTraces_Flag
%             plotAvgMCSTraces2( analyVar,indivDataset )
%         end
% 
%         if analyVar.plotNonPeak_AvgMCSTraces_Flag
%             plotNonPeak_AvgMCSTraces( analyVar,indivDataset )
%         end
% 
%         if analyVar.plotAvgMCSTraces_counts_vs_delaytime_Flag
%             plotAvgMCSTraces_counts_vs_delaytime( analyVar,indivDataset )
%         end
% 
%         if analyVar.plotAvgMCSTraces_counts_vs_delaytime_SumNonPeak_Flag
%             plotAvgMCSTraces_counts_vs_delaytime_SumNonPeak( analyVar,indivDataset )
%         end
        
    
    %% Crop Data
    [ indivDataset ] = CropData(analyVar, indivDataset);

%% fit frequency spectrum
% if analyVar.fitMCS_SpectraGaussian
%     indivDataset = MCS_gaussian_fit2(analyVar, indivDataset);
% end

%% Parent State Evolution  
if analyVar.StateEvolution_Fit==1
    [indivDataset] = ParentStateEvolution_Fit(analyVar, indivDataset);
    [indivDataset] = SumSignalEvolution_Fit(analyVar, indivDataset);
    
end

%% Secondary State Evolution
% if analyVar.StateEvolution_Fit==1
%     [indivDataset] = SecondaryStateEvolution_Fit(analyVar, indivDataset);
% end

[analyVar, indivDataset] = EstimateDensity2(analyVar, indivDataset);

%% Plot State Evolution
if analyVar.StateEvolution_Fit && analyVar.plot_StateEvolution
    plot_StateEvolution( analyVar, indivDataset )
%     plot_StateEvolution_sameState_diffDensity( analyVar, indivDataset )
elseif analyVar.plot_StateEvolution
    error('analyVar.StateEvolution_Fit is not set to 1: to makes these plots, need to enable fitting.')
end

%% Decay Rate vs. Density
if analyVar.MCS_DecayRate_Fit
    %% Density Calculation
%     [analyVar, indivDataset] = MCS_DecayRate_Fit_AvgFits(analyVar, indivDataset);
    [analyVar, indivDataset] = MCS_DecayRate_Fit_AvgData(analyVar, indivDataset);
end

if analyVar.plot_MCS_DecayRate_Fit
%     plot_MCS_DecayRate_Fit(analyVar, indivDataset)
    plot_MCS_DecayRate_Fit_PaperPlots(analyVar, indivDataset)
end
   
end

