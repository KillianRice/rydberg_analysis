function [indivDataset] = MCS_UV_Spectrum_Indiv_SFI(analyVar,indivDataset,avgDataset)

%% Convert TOF arrival time

[analyVar] = CalculateFieldRamp(analyVar);

% PlotFieldRamp(analyVar);

%% Load Data
indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

%% Estimate Density
[analyVar, indivDataset] = EstimateDensity2(analyVar, indivDataset);

%% Calculated Average UV spectra
% at fixed frequency and density
[unique_Freq, unique_Density, Ave_SFI, Ave_SFI_error, stats_counter] = Ave_UV_Spectrum_Indiv_SFI(analyVar, indivDataset);

    %% Average across density
    method = 2; % 0 - don't group. 1 - hand picked groupins, 2 - dicated number of groupings
    
    switch method           
        case 0 
            numgroups = length(unique_Density);
            
            if mod(length(unique_Density),numgroups ) ~= 0
                error('FC: Cannot evenly divide the number of densities in to the desired number of groupings')
            end
            DensityGroupsToAverage = cell(1,numgroups);
            dummyarray = 1:length(unique_Density);
            dummyarray = reshape(dummyarray, [], numgroups);
            for index = 1:numgroups 
                DensityGroupsToAverage{index} = dummyarray(:,index);
            end            
        case 1
            
            DensityGroupsToAverage = {1:3}; %cell of arrays to dictate how to average density
        
        case 2
            numgroups = 4;
            
            if mod(length(unique_Density),numgroups ) ~= 0
                error('FC: Cannot evenly divide the number of densities in to the desired number of groupings')
            end
            DensityGroupsToAverage = cell(1,numgroups);
            dummyarray = 1:length(unique_Density);
            dummyarray = reshape(dummyarray, [], numgroups);
            for index = 1:numgroups 
                DensityGroupsToAverage{index} = dummyarray(:,index);
            end
    end
    
    if length(unique_Density) < max(cell2mat(DensityGroupsToAverage))
        error('FC: Trying to average over density groups that dont exist. Data does not contain as many density groups as code expects');
    end
    [Ave_SFI, Ave_SFI_error, stats_counter] = AverageAcrossDensity_SFI(unique_Freq, DensityGroupsToAverage, Ave_SFI, Ave_SFI_error, stats_counter);

    % in BEC it's reasonable to average across density since density varies as
    % Num^2/5
    
    %% Convert Frequency Units
    % convert from synth frequency to UV frequency units

    AtomicFreq = analyVar.atomic_LineCenter; 
    FreqConversion = analyVar.FreqConversion; %unitless, unit of UV freq per unit of Synth Freq.
    UVunique_Freq = -FreqConversion.*(unique_Freq - AtomicFreq);    
    
    %% Average across frequency
    ElectricField0 = analyVar.ElectricField;
    Ave_SFI0 = Ave_SFI;
    Ave_SFI_error0 = Ave_SFI_error;
    stats_counter0 = stats_counter;
    
    for freqgroupindex = analyVar.featuregroup

        [ featurePos ] = ChooseFreqBand(analyVar, UVunique_Freq, freqgroupindex );

        [ Ave_SFI, Ave_SFI_error, stats_counter] = AverageAcrossFrequency_SFI(analyVar, featurePos, Ave_SFI0, Ave_SFI_error0, stats_counter0);

        movingavewindow = 3;
        stats_counter = stats_counter*movingavewindow;
        [analyVar.ElectricField, ~] = Moving_Ave(ElectricField0, ElectricField0, movingavewindow);
        for freqIndex = 1:length(Ave_SFI)
            for densityIndex = 1:length(DensityGroupsToAverage)
                [Ave_SFI{freqIndex}{densityIndex}, Ave_SFI_error{freqIndex}{densityIndex}] = Moving_Ave(...
                    Ave_SFI{freqIndex}{densityIndex}, Ave_SFI_error{freqIndex}{densityIndex}, movingavewindow);
                %moving average of SFI to smooth out the SFI curves.
            end
        end

        NormalizeFlag = 1;
        if NormalizeFlag == 1
            for freqIndex = 1:length(Ave_SFI)
                for densityIndex = 1:length(DensityGroupsToAverage)
                    [Ave_SFI{freqIndex}{densityIndex}, Ave_SFI_error{freqIndex}{densityIndex}] = NormalizeArray3(...
                        analyVar.ElectricField, Ave_SFI{freqIndex}{densityIndex}, Ave_SFI_error{freqIndex}{densityIndex});
                    %Normalize all SFI to unity area.
                end
            end
        end

        %% Plotting
        [ output_args ] = plot_compareFreq_SFI(analyVar, analyVar.ElectricField, Ave_SFI, Ave_SFI_error, DensityGroupsToAverage, featurePos, UVunique_Freq, stats_counter);
        [ output_args ] = plot_compareDensity_SFI(analyVar, analyVar.ElectricField, Ave_SFI, Ave_SFI_error, DensityGroupsToAverage, featurePos, UVunique_Freq, stats_counter);

    end

%% Plots Average UV Spectra
% [ output_args ]  = plot_AveUVSpectrum_Indiv_SFI(analyVar, indivDataset, Ave_SFI, Ave_SFI_error);


end

