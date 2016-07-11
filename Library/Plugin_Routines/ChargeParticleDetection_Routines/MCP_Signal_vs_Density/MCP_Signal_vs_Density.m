function [indivDataset] = MCP_Signal_vs_Density(analyVar,indivDataset,avgDataset)

%% Load Data
indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

%% Estimate Density
[analyVar, indivDataset] = EstimateDensity2(analyVar, indivDataset);

%% Calculated Average UV spectra
SFI_roi = -1; % -1 for all, note the this is still constrained by values chosen in master batch entry
[unique_Freq, unique_Density, AveUVSpectrum, AveUVSpectrum_error, stats_counter] = Average_UV_Spectrum2(analyVar,indivDataset, SFI_roi);
%% Fit Atomic Lineshape wings
% [Lorentzian_Amplitude, Lorentzian_LineCenter, Lorentzian_Width] = AtomicLineShapeFit2(unique_Freq, unique_Density, AveUVSpectrum);

Lorentzian_LineCenter = analyVar.atomic_LineCenter;
[Lorentzian_Amplitude, Lorentzian_Width] = deal(0);

%% Average across density
    method = 0; % 0 - don't group. 1 - hand picked groupins, 2 - dicated number of groupings
    
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

    
    %% Moving Average across frequency

    frequencygrouping = 1; % how many neighbors to average together, positive integer value, odd or even
    stats_counter = stats_counter*frequencygrouping;
    [unique_Freq, AveUVSpectrum, AveUVSpectrum_error] = AverageAcrossFrequency_UVSpectrum(frequencygrouping, unique_Freq, AveUVSpectrum, AveUVSpectrum_error);  

    %% Convert Independant variable
    convertFreq = 1;
    if convertFreq == 1
        AtomicFreq = Lorentzian_LineCenter(1);
        FreqConversion = analyVar.FreqConversion; %unitless, unit of UV freq per unit of Synth Freq.
        unique_Freq = -FreqConversion.*(unique_Freq - AtomicFreq);
    end
    
    %% Normalize to unit area
    NormalizeFlag = 0;
    if NormalizeFlag == 1
        for densityIndex = 1:length(AveUVSpectrum)            
                [AveUVSpectrum{densityIndex}, AveUVSpectrum_error{densityIndex}] = NormalizeArray3(...
                    unique_Freq, AveUVSpectrum{densityIndex}, AveUVSpectrum_error{densityIndex});
                %Normalize all UV Spectrum to unity area.
        end
    end

FreqType = 2;
freqToGrab = 18:30;
firstdensity = 7;

if FreqType == 1
    featurePos = unique_Freq(freqToGrab);
    
    [band, fit_yData, DecayRate, Lifetime, InitialValue, yData_residuals] = deal(cell(size(featurePos)));
    for featureIndex = 1:length(featurePos)
        [band{featureIndex}] = deal(nan(numgroups,1));
        freqpos = freqToGrab(featureIndex);
        for densityIndex = 1:numgroups
            band{featureIndex}(densityIndex)  = mean(AveUVSpectrum{densityIndex}(freqpos));
        end
    end
    
elseif FreqType == 2   
    %% Choose Frequency Bands
    featurePos = {};
    for freqgroupindex = analyVar.featuregroup
        [ featurePos0 ]   = ChooseFreqBand(analyVar, unique_Freq, freqgroupindex );
        featurePos{end + 1} =  featurePos0;
    end
    featurePos = featurePos{1};

    %% Divide Data According to Frequency Bands
    [band, fit_yData, DecayRate, Lifetime, InitialValue, yData_residuals] = deal(cell(size(featurePos)));
    for featureIndex = 1:length(featurePos)
        [band{featureIndex}] = deal(nan(numgroups,1));

        for densityIndex = 1:numgroups
            Start = featurePos{featureIndex}(1);
            End   = featurePos{featureIndex}(end);
            band{featureIndex}(densityIndex)  = mean(AveUVSpectrum{densityIndex}(Start:End));
        end
    end

end

for featureIndex = 1:length(featurePos)
    %% Exponential Fit
    xData = firstdensity:length(unique_Density);
    yData = band{featureIndex}(xData(1):end);
    [InitialValue{featureIndex}, DecayRate{featureIndex}, ~, Fitting_Routine] = Exponential_Decay_Fit2(xData, yData, yData, 0, 0);
    fit_xData = linspace( min(xData) , max(xData), 1e4)';
    fit_yData{featureIndex} = Fitting_Routine.predict(fit_xData);  
    Lifetime{featureIndex}(1) = DecayRate{featureIndex}(1)^-1;
    Lifetime{featureIndex}(2) = DecayRate{featureIndex}(2)*DecayRate{featureIndex}(1)^-2;
    %% Residuals
    yData_residuals{featureIndex} = (yData-Fitting_Routine.predict(xData'))./Fitting_Routine.predict(xData');
    yData_residuals{featureIndex} = abs(yData_residuals{featureIndex});
    
    %% Display Fitting Results
%     disp(VariableName(InitialValue))
%     disp(InitialValue)  
%     disp(VariableName(Lifetime))
%     disp(Lifetime)
end

%% Plot Decay
for qq = 1
    for featureIndex = 1:length(featurePos)
        if qq == 2
            band{featureIndex} = band{featureIndex}/band{featureIndex}(1);
        end
    end

    for kk = 1:2
        PlotStruct.xData = [1:length(unique_Density)/numgroups:length(unique_Density)]+length(unique_Density)/(2*numgroups)-0.5;
        PlotStruct.yData = band;
        PlotStruct.hXLabel = 'Density Index';
        switch qq
            case 1
                PlotStruct.hYLabel = {'Signal'};
            case 2
                PlotStruct.hYLabel = {'Fractional Signal'};
        end

        PlotStruct.colors = FrancyColors3(length(band));          
      
%         PlotStruct.LineStyle = '-'; 
        FC_Plotter(analyVar, PlotStruct);
        for featureIndex = 1:length(featurePos)
            plot(fit_xData, fit_yData{featureIndex}, 'Color', FrancyColors3(length(band), featureIndex));
        end
        if kk == 2
            set(gca, 'YScale', 'log')
        end
    end
end

%% plot residuals
PlotStructRes.xData = xData;
PlotStructRes.yData = yData_residuals;
PlotStructRes.hXLabel = 'Density Index';
PlotStructRes.hYLabel = {'Residual'};
PlotStructRes.colors = FrancyColors3(length(band));          
PlotStructRes.LineStyle = '-'; 
FC_Plotter(analyVar, PlotStructRes);
plot(xData, ones(size(xData)), 'Color', [0 0 0])
plot(xData, 0.1*ones(size(xData)), 'Color', [0 0 0])
set(gca, 'YScale', 'Log');

%% Plot Decay Rates
decayRate2 = nan(length(featurePos),1);
decayRate2_error = decayRate2;
for ii = 1:length(featurePos)
    decayRate2(ii) = DecayRate{ii}(1);
    decayRate2_error(ii) = DecayRate{ii}(2);
end
xData = nan(size(featurePos));
for gg = 1:length(featurePos)
    xData(gg) = mean([unique_Freq(featurePos{gg}(1)) unique_Freq(featurePos{gg}(2))]);
end
PlotStructRes.xData = xData;
PlotStructRes.yData = {decayRate2};
PlotStructRes.yData_error = {decayRate2_error};
PlotStructRes.hXLabel = 'UV Detuning (MHz)';
PlotStructRes.hYLabel = {'Decay Rate'};
PlotStructRes.colors = FrancyColors3(length(band));          
PlotStructRes.LineStyle = '-'; 
FC_Plotter(analyVar, PlotStructRes);


end