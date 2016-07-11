function ParentStruct = CollectData(indivDataset, ParentStruct)
% Combine data within one trace, trace defined to be data sets sharing the
% same 'ScanIDVarAtom' (third column in the master batch file)

NumDataSets = ParentStruct.NumDataSets; % number of data sets within the trace
PosDataSets = ParentStruct.PosDataSets; % index position of the data sets within the trace

%% Independant Variable
    % Find the unique values of the independant variable and their locations.
    xData = [];
    for mbIndexCounter = 1:NumDataSets
        mbIndex = PosDataSets(mbIndexCounter);
        xData = cat(1, xData, indivDataset{mbIndex}.imagevcoAtom);
    end
    unique_xData = unique(xData,'sorted'); % unique values of the independant variable
    NumUnique_xData = length(unique_xData); % number of unique values of the independant variable

    UniquexDataIndex = cell(1,NumDataSets);
    % for each indiviadual data set, find the location of each value of
    % unique_xData
    for mbIndexCounter = 1:NumDataSets
        mbIndex = PosDataSets(mbIndexCounter);
        UniquexDataIndex{mbIndexCounter} = arrayfun(@(x) find(unique_xData == x),...
            indivDataset{mbIndex}.imagevcoAtom,'UniformOutput',0);
    end

%% Load values of density for each data set
    Densities = cell(1, NumDataSets);
    NumDen = deal(nan(NumDataSets,1));
    for mbIndexCounter = 1:NumDataSets
        mbIndex = PosDataSets(mbIndexCounter);
        Densities{mbIndexCounter} = indivDataset{mbIndex}.densityvector;
        NumDen(mbIndexCounter) = length(Densities{mbIndexCounter});
    end
    
    % check if data sets all have the same number of densities
    errorcheck = NumDen ~= mean(NumDen);
    errorcheck = sum(errorcheck);
    if errorcheck ~= 0
        error('FC: Data sets within trace are not of equal number of densities.')
    end
    
    NumDensities = length(indivDataset{1}.densityvector);

%% Aggregate
    yData  = deal(cell(NumDensities, 1));
    for uniquexDataIndex = 1:NumDensities
        [yData{uniquexDataIndex}]= deal(cell(NumUnique_xData, 1));
    end
    % yData has dimensions of (number of densites) x (number of values of independant variable)
    
    % Load the SFI data, integrate it, and assign it to yData
    for mbIndexCounter = 1:NumDataSets
        mbIndex = PosDataSets(mbIndexCounter);
        Num_xData = indivDataset{mbIndex}.CounterAtom;
        for bIndex = 1:Num_xData
            if size(indivDataset{mbIndex}.delay_spectra{bIndex},2)>1
                error('Expecting UV Spectra at single value of field delay.')
            end
            Signal = indivDataset{mbIndex}.delay_spectra{bIndex}; % array of 
            % SFI of a single data set at a single value of frequency, 
            % dimensions of (number of arrival time bins) x (number of densities)
            Signal = nansum(Signal,1); % Integrate the SFI signal across arrival time
    %         Signal = squeeze(Signal);

            for DensityIndex = 1:NumDensities
                yData{DensityIndex}{ UniquexDataIndex{mbIndexCounter}{bIndex} } = cat(1, yData{DensityIndex}{ UniquexDataIndex{mbIndexCounter}{bIndex} }, Signal(DensityIndex));
            end
        end
    end 

%% Plot the first density, plot all data sets
% plot(unique_xData, cell2mat(yData{1}'))

%% Save to structure
ParentStruct.xData = unique_xData;
ParentStruct.yData = yData;
ParentStruct.Densities = Densities{1};

end

