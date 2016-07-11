function [unique_ExpTime, Ave_SFI, Ave_SFI_error] = Calculate_Ave_SFI(analyVar,indivDataset)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
NumRepetitions = analyVar.numBasenamesAtom;

%% Exposure Time
ExpTime = [];
for mbIndex = 1:NumRepetitions
    ExpTime = cat(1, ExpTime, indivDataset{mbIndex}.imagevcoAtom);
end
unique_ExpTime = unique(ExpTime,'sorted');

NumUniqueExpTime = length(unique_ExpTime);

[UniqueExpTimeIndex] = deal(cell(1,NumRepetitions));
for mbIndex = 1:NumRepetitions
    UniqueExpTimeIndex{mbIndex} = arrayfun(@(x) find(unique_ExpTime == x),...
        indivDataset{mbIndex}.imagevcoAtom,'UniformOutput',0);
end

%% Density - going to ignore density, if we want to add this in later, look at Ave_UV_Spectrum_Indiv_SFI.m for reference

%% Average SFI's together at each unique value of exposure time.
[yData, Ave_SFI, Ave_SFI_error]  = deal(cell(NumUniqueExpTime, 1));

for mbIndex = 1:NumRepetitions
    NumFreq = indivDataset{mbIndex}.CounterAtom;
    for bIndex = 1:NumFreq
        if size(indivDataset{mbIndex}.delay_spectra{bIndex},2)>1
            error('Expecting UV Spectra at single value of field delay, not multiple delay times.')
        end
        Signal = indivDataset{mbIndex}.delay_spectra{bIndex};
        
        yData{UniqueExpTimeIndex{mbIndex}{bIndex}} = cat(2, yData{UniqueExpTimeIndex{mbIndex}{bIndex}}, Signal);
        
        
    end
end

%% Sacaling Factor to nromalize data
    numRamps = analyVar.numLoopsSets(1);
    exposuretime = analyVar.Exposure_Time(1)*1e6; %us
    ScalingFactor = 1/(numRamps*exposuretime);

for ExpTimeIndex = 1:NumUniqueExpTime

        Ave_SFI{ExpTimeIndex} = ScalingFactor*nanmean(yData{ExpTimeIndex},2);
        Ave_SFI_error{ExpTimeIndex} = ScalingFactor*nanstd(yData{ExpTimeIndex},0,2)/(size(yData{ExpTimeIndex},2))^0.5;
    
end


end

