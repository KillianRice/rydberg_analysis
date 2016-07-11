function CombineSpectraData2(analyVar,indivDataset)

NormalizeFlag = 2;
% 0 - Don't normalize
% 1 - Normalize to number of ramps
% 2 - Normalize to to number of ramps* exposure time
% 3 - Normalize to unity area

% Convert from synth units to UV frequency units
convertFreq = 1;

linear_log = 1;
% 1 - linear
% 2 - log
% 1:2 - both

%% Load Data
    indivDataset = param_extract_mcs_sum(analyVar, indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

%% Sort out uniqueness ID
    [TraceID, TraceID_Index] = sort(analyVar.uniqScanList);
    NumTraces = length(TraceID);
    posOccurUniqVar = analyVar.posOccurUniqVar;
    posOccurUniqVar = posOccurUniqVar(TraceID_Index);    

    ParentCell= cell(1,NumTraces);
    for TraceIndex = 1:NumTraces
        ParentCell{TraceIndex}.NormalizeFlag = NormalizeFlag;
        ParentCell{TraceIndex}.NumDataSets = length(posOccurUniqVar{TraceIndex});
        ParentCell{TraceIndex}.PosDataSets = posOccurUniqVar{TraceIndex};

        %% Calculate Density
            indivDataset = EstimateDensity3(analyVar, indivDataset, ParentCell{TraceIndex});
        %% Aggregate data within trace
            ParentCell{TraceIndex} = CollectData(indivDataset, ParentCell{TraceIndex}); % now a misnomer; not averaging within this function

    end 

%% Average across density
for TraceIndex = 1:NumTraces
%     method = 0; 
%     % 0 - don't group.
%     % 1 - hand picked groupins,
%     % 2 - dicated number of groupings
%     % 3 - group all into 1
%     
%     switch method           
%         case 0 
            ParentCell{TraceIndex}.NumDensities = length(ParentCell{TraceIndex}.Densities);
%             
%             if mod(length(ParentCell{TraceIndex}.Densities),numgroups ) ~= 0
%                 error('FC: Cannot evenly divide the number of densities in to the desired number of groupings')
%             end
            DensityGroupsToAverage = cell(1,ParentCell{TraceIndex}.NumDensities);
%             dummyarray = 1:length(ParentCell{TraceIndex}.Densities);
%             dummyarray = reshape(dummyarray, [], numgroups);
%             for index = 1:numgroups 
%                 DensityGroupsToAverage{index} = dummyarray(:,index);
%             end            
%         case 1
%             
%             DensityGroupsToAverage = {1 1:2 1:3 1:4 1:5}; %cell of arrays to dictate how to average density
%         
%         case 2
%             numgroups = 5;
%             
%             if mod(length(unique_Density),numgroups ) ~= 0
%                 error('FC: Cannot evenly divide the number of densities in to the desired number of groupings')
%             end
%             DensityGroupsToAverage = cell(1,numgroups);
%             dummyarray = 1:length(unique_Density);
%             dummyarray = reshape(dummyarray, [], numgroups);
%             for index = 1:numgroups 
%                 DensityGroupsToAverage{index} = dummyarray(:,index);
%             end
%             
%         case 3
%             numgroups = 1;
%             
%             if mod(length(unique_Density),numgroups ) ~= 0
%                 error('FC: Cannot evenly divide the number of densities in to the desired number of groupings')
%             end
%             DensityGroupsToAverage = cell(1,numgroups);
%             dummyarray = 1:length(unique_Density);
%             dummyarray = reshape(dummyarray, [], numgroups);
%             for index = 1:numgroups 
%                 DensityGroupsToAverage{index} = dummyarray(:,index);
%             end            
%     end
%     
%     if length(ParentCell{TraceIndex}.Densities) < max(cell2mat(DensityGroupsToAverage))
%         error('FC: Trying to average over density groups that dont exist. Data does not contain as many density groups as code expects');
%     end
%     ParentCell{TraceIndex} = AggregateAcrossDensity(DensityGroupsToAverage, ParentCell{TraceIndex});
% 
end

% %% Average across frequency
% 
%     frequencygrouping = 1; % how many neighbors to average together, positive integer value, odd or even
%     stats_counter = stats_counter*frequencygrouping;
%     [unique_Freq, AveUVSpectrum, AveUVSpectrum_error] = AverageAcrossFrequency_UVSpectrum(frequencygrouping, unique_Freq, AveUVSpectrum, AveUVSpectrum_error);  


%% Average Data
    for TraceIndex = 1:NumTraces
        ParentCell{TraceIndex} = Average_UV_Spectrum3(ParentCell{TraceIndex});
    end
    
%% Convert Independant variable
    AtomicFreq = analyVar.atomic_LineCenter;
    FreqConversion = analyVar.FreqConversion; %unitless, unit of UV freq per unit of Synth Freq.
    for TraceIndex = 1:NumTraces
        if convertFreq == 1
            ParentCell{TraceIndex}.xData = -FreqConversion.*(ParentCell{TraceIndex}.xData - AtomicFreq);
        end
    end
    
%% Normalize
    for TraceIndex = 1:NumTraces
        ParentCell{TraceIndex} = NormalizeUVSpectrum(analyVar, ParentCell{TraceIndex});
    end

%% Plot across multiple traces
for axistype = linear_log
    for DensityIndex = 1:ParentCell{1}.NumDensities
        plot_UVSpectrum_MultTraces(analyVar, ParentCell, axistype, DensityIndex);
    end
end    
    
%% Plot Areas
yData_Area = cell(ParentCell{1}.NumDensities);

for DensityIndex = 1:ParentCell{1}.NumDensities
    yData_Area{DensityIndex} = nan(1, NumTraces);
    for TraceIndex = 1:NumTraces
        yData_Area{DensityIndex}(TraceIndex) = ParentCell{TraceIndex}.SpectrumIntegral(DensityIndex);
    end
end

figure
hold on
col = jet(ParentCell{1}.NumDensities);
for DensityIndex = 1:ParentCell{1}.NumDensities
    plot(TraceID , yData_Area{DensityIndex}, 'o', 'LineStyle', '-', 'Color', col(DensityIndex,:))
end

% %% Plot Average UV Spectra at all densities
% for freqgroupindex = analyVar.featuregroup
%     for axistype = linear_log
%         for TraceIndex = 1:NumTraces
%             ParentCell{TraceIndex}.linear_log = axistype; 
%             ParentCell{TraceIndex}.featurePos = ChooseFreqBand(analyVar, ParentCell{TraceIndex}.xData, freqgroupindex );
% %             plot_AveUVSpectrum_DiffDensities(analyVar, ParentCell);
%         end
%     end
% end

end