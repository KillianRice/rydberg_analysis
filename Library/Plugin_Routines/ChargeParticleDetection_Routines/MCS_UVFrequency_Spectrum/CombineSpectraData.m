function CombineSpectraData(analyVar,indivDataset)

NormalizeFlag = 2;
% 0 - Don't normalize
% 1 - Normalize to number of ramps
% 2 - Normalize to to number of ramps* exposure time
% 3 - Normalize to unity area

%% Load Data
indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

%% Estimate Density
[analyVar, indivDataset] = EstimateDensity2(analyVar, indivDataset);

%% Calculated Average UV spectra
SFI_roi = -1; % -1 for all, note the this is still constrained by values chosen in master batch entry
[unique_Freq, unique_Density, AveUVSpectrum, AveUVSpectrum_error, stats_counter] = Average_UV_Spectrum2(analyVar,indivDataset, SFI_roi);

%% Average across density
    method = 1; % 0 - don't group. 1 - hand picked groupins, 2 - dicated number of groupings
    
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
            
            DensityGroupsToAverage = {1}; %cell of arrays to dictate how to average density
        
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
            
        case 3
            numgroups = 1;
            
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
    [AveUVSpectrum, AveUVSpectrum_error, stats_counter] = AverageAcrossDensity_UVSpectrum(DensityGroupsToAverage, AveUVSpectrum, AveUVSpectrum_error, stats_counter);

    
    %% Average across frequency

    frequencygrouping = 1; % how many neighbors to average together, positive integer value, odd or even
    stats_counter = stats_counter*frequencygrouping;
    [unique_Freq, AveUVSpectrum, AveUVSpectrum_error] = AverageAcrossFrequency_UVSpectrum(frequencygrouping, unique_Freq, AveUVSpectrum, AveUVSpectrum_error);  


    %% Convert Independant variable
    convertFreq = 1;
    if convertFreq == 1
        AtomicFreq = analyVar.atomic_LineCenter;
        FreqConversion = analyVar.FreqConversion; %unitless, unit of UV freq per unit of Synth Freq.
        unique_Freq = -FreqConversion.*(unique_Freq - AtomicFreq);
    end
    
    %% Normalize
    numRamps = analyVar.numLoopsSets(1);
    exposuretime = analyVar.Exposure_Time(1)*1e6; %us
    switch NormalizeFlag
        case 1
            Norm                = 1/numRamps;
            AveUVSpectrum       = cellfun(@(x) Norm*x, AveUVSpectrum, 'UniformOutput', 0);
            AveUVSpectrum_error = cellfun(@(x) Norm*x, AveUVSpectrum_error, 'UniformOutput', 0);
        
        case 2
            Norm = 1/numRamps/exposuretime;
            AveUVSpectrum       = cellfun(@(x) Norm*x, AveUVSpectrum, 'UniformOutput', 0);
            AveUVSpectrum_error = cellfun(@(x) Norm*x, AveUVSpectrum_error, 'UniformOutput', 0);
            
        case 3
            for densityIndex = 1:length(AveUVSpectrum)            
                [AveUVSpectrum{densityIndex}, AveUVSpectrum_error{densityIndex}] = NormalizeArray3(...
                    unique_Freq, AveUVSpectrum{densityIndex}, AveUVSpectrum_error{densityIndex});
                %Normalize all UV Spectrum to unity area.
            end            
    end

    for densityIndex = 1:length(AveUVSpectrum)            
        area = abs(trapz(AveUVSpectrum{densityIndex}));
    end 

%% Plots Average UV Spectra
% [ output_args ]  = plot_AveUVSpectrum2(analyVar, indivDataset, unique_Freq, unique_Density, AveUVSpectrum, AveUVSpectrum_error, Lorentzian_Amplitude, Lorentzian_LineCenter, Lorentzian_Width);
%% Plot Average UV Spectra at all densities
for freqgroupindex = analyVar.featuregroup
    for linear_log = 1:2
        [ featurePos ]   = ChooseFreqBand(analyVar, unique_Freq, freqgroupindex );
        plot_AveUVSpectrum_DiffDensities(analyVar, indivDataset, unique_Freq, unique_Density, DensityGroupsToAverage, AveUVSpectrum, AveUVSpectrum_error, stats_counter, featurePos, linear_log, NormalizeFlag);
    end
end
%% Plot Average UV Spectra at Average density.... stricly speaking, its the average across density, not the signal at one vaue of density
% [ output_args ]  = plot_AveUVSpectrum_AveOverDensity(analyVar, indivDataset, unique_Freq, unique_Density, AveUVSpectrum, AveUVSpectrum_error, Lorentzian_Amplitude, Lorentzian_LineCenter, Lorentzian_Width);

end