function [unique_xData, unique_Density, AveUVSpectrum, AveUVSpectrum_error, stats_counter] = Average_UV_Spectrum2(analyVar,indivDataset, SFI_roi)
% Combine all the data sets into one.

Num_mb = analyVar.numBasenamesAtom;
stats_counter = Num_mb;

%% Independant Variable
% Find the unique values of the independant variable and their locations.
xData = [];
for mbIndex = 1:Num_mb
    xData = cat(1, xData, indivDataset{mbIndex}.imagevcoAtom);
end
unique_xData = unique(xData,'sorted');
NumUnique_xData = length(unique_xData);

UniquexDataIndex = cell(1,Num_mb);
for mbIndex = 1:Num_mb
    UniquexDataIndex{mbIndex} = arrayfun(@(x) find(unique_xData == x),...
        indivDataset{mbIndex}.imagevcoAtom,'UniformOutput',0);
end

%% Density
Densities = [];
for mbIndex = 1:Num_mb
    Num_xData = indivDataset{mbIndex}.CounterAtom;
    for bIndex = 1:Num_xData
% % %         NumDensities = indivDataset{mbIndex}.numDensityGroups{bIndex};
        Densities = cat(1, Densities, indivDataset{mbIndex}.densityvector);
    end
end

unique_Density = unique(Densities,'sorted');
NumUniqueDensity = length(unique_Density);

%% Aggregate
[yData, yData_Average, yData_error]  = deal(cell(NumUnique_xData, 1));
for uniquexDataIndex = 1:NumUnique_xData
    [yData{uniquexDataIndex} , yData_Average{uniquexDataIndex} , yData_error{uniquexDataIndex} ]= deal(cell(NumUniqueDensity, 1));
end

for mbIndex = 1:Num_mb
    Num_xData = indivDataset{mbIndex}.CounterAtom;
    for bIndex = 1:Num_xData
        if size(indivDataset{mbIndex}.delay_spectra{bIndex},2)>1
            error('Expecting UV Spectra at single value of field delay.')
        end
        Signal = indivDataset{mbIndex}.delay_spectra{bIndex};
        if SFI_roi == -1
            Signal = nansum(Signal,1);
        else
            Signal = nansum(Signal(SFI_roi,:,:),1);
        end
        Signal = squeeze(Signal);
        
        for DensityIndex = 1:length(indivDataset{mbIndex}.densityvector)
            yData{UniquexDataIndex{mbIndex}{bIndex}}{DensityIndex} = cat(1, yData{UniquexDataIndex{mbIndex}{bIndex}}{DensityIndex}, Signal(DensityIndex));
        end
    end
end

for uniquexDataIndex = 1:NumUnique_xData
    for uniqueDensityIndex = 1:NumUniqueDensity
        yData_Average{uniquexDataIndex}{uniqueDensityIndex} = mean(yData{uniquexDataIndex}{uniqueDensityIndex}); % average over the data from the different data sets at unique frequency and density points
        yData_error{uniquexDataIndex}{uniqueDensityIndex} = std(yData{uniquexDataIndex}{uniqueDensityIndex}, 0 );
    end
end

[AveUVSpectrum, AveUVSpectrum_error] = deal(cell(1,NumUniqueDensity ));

NumUniqueDensity = size(yData_Average{uniquexDataIndex},1);
for uniqueDensityIndex = 1:NumUniqueDensity 
    for uniquexDataIndex = 1:NumUnique_xData
        AveUVSpectrum{uniqueDensityIndex} = cat(1, AveUVSpectrum{uniqueDensityIndex}, yData_Average{uniquexDataIndex}{uniqueDensityIndex});
        AveUVSpectrum_error{uniqueDensityIndex} = cat(1, AveUVSpectrum_error{uniqueDensityIndex}, yData_error{uniquexDataIndex}{uniqueDensityIndex});
    end
end    

end

