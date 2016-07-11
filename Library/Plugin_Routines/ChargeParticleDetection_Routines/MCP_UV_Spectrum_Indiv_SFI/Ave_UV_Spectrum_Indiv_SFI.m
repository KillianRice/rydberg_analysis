function [unique_Freq, unique_Density, Ave_SFI, Ave_SFI_error, stats_counter] = Ave_UV_Spectrum_Indiv_SFI(analyVar,indivDataset)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
NumStates = analyVar.numBasenamesAtom;

%% Frequency
%find the unique values of frequency and their indeces
Frequencies = [];
for mbIndex = 1:NumStates
    Frequencies = cat(1, Frequencies, indivDataset{mbIndex}.imagevcoAtom);
end
unique_Freq = unique(Frequencies,'sorted');

NumUniqueFreq = length(unique_Freq);

UniqueFreqIndex = cell(1,NumStates);
for mbIndex = 1:NumStates
    UniqueFreqIndex{mbIndex} = arrayfun(@(x) find(unique_Freq == x),...
        indivDataset{mbIndex}.imagevcoAtom,'UniformOutput',0);
end

%% Density
%find the unique values of density, they are already ordered
Densities = [];
for mbIndex = 1:NumStates
    NumFreq = indivDataset{mbIndex}.CounterAtom;
    for bIndex = 1:NumFreq
        Densities = cat(1, Densities, indivDataset{mbIndex}.densityvector);
    end
end

unique_Density = unique(Densities,'sorted');
NumUniqueDensity = length(unique_Density);

%% Aggregate
%create cell of data
%first dimension; cell index to select frequency
%second dimension; cell index to select density
%third dimension; array index to select electric field of SFI

[yData, Ave_SFI, Ave_SFI_error]  = deal(cell(NumUniqueFreq, 1));
for uniqueFreqIndex = 1:NumUniqueFreq
    [yData{uniqueFreqIndex} , Ave_SFI{uniqueFreqIndex} , Ave_SFI_error{uniqueFreqIndex} ]= deal(cell(NumUniqueDensity, 1));
end

for mbIndex = 1:NumStates
    NumFreq = indivDataset{mbIndex}.CounterAtom;
    for bIndex = 1:NumFreq
        if size(indivDataset{mbIndex}.delay_spectra{bIndex},2)>1
            error('FC: Expecting UV Spectra at single value of field delay, not multiple delay times.')
        end
        Signal = indivDataset{mbIndex}.delay_spectra{bIndex};
        Signal = squeeze(Signal);
        
        for DensityIndex = 1:length(indivDataset{mbIndex}.densityvector)
            yData{UniqueFreqIndex{mbIndex}{bIndex}}{DensityIndex} = cat(2, yData{UniqueFreqIndex{mbIndex}{bIndex}}{DensityIndex}, Signal(:,DensityIndex));
        end
        
    end
end

%% Scaling Factor to normalize data
    numRamps = analyVar.numLoopsSets(1);
    exposuretime = analyVar.Exposure_Time(1)*1e6; %us
    ScalingFactor = 1/(numRamps*exposuretime);

%% Average over the different atom samples at a fixed frequency and density
for uniqueFreqIndex = 1:NumUniqueFreq
    for uniqueDensityIndex = 1:NumUniqueDensity
        Ave_SFI{uniqueFreqIndex}{uniqueDensityIndex} = ScalingFactor*nanmean(yData{uniqueFreqIndex}{uniqueDensityIndex},2);
        Ave_SFI_error{uniqueFreqIndex}{uniqueDensityIndex} = ScalingFactor*nanstd(yData{uniqueFreqIndex}{uniqueDensityIndex},0,2);
    end
end

stats_counter = NumStates;

end

