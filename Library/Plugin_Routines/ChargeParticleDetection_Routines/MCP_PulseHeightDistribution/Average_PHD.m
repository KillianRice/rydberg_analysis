function [unique_Voltage, AveUVSpectrum, AveUVSpectrum_error] = Average_PHD(analyVar,indivDataset)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
NumRepetitions = analyVar.numBasenamesAtom;

%% Frequency
ThresholdVoltages = [];
for mbIndex = 1:NumRepetitions
    ThresholdVoltages = cat(1, ThresholdVoltages, indivDataset{mbIndex}.imagevcoAtom);
end
unique_Voltage = unique(ThresholdVoltages,'sorted');

NumUniqueVolt = length(unique_Voltage);
% FreqStruct = cell(1, NumUniqueFreq);
% for uniqueFreqIndex = 1:NumUniqueFreq 
%     FreqStruct{uniqueFreqIndex} = unique_Freq(uniqueFreqIndex);
% end

UniqueVoltageIndex = cell(1,NumRepetitions);
for mbIndex = 1:NumRepetitions
    UniqueVoltageIndex{mbIndex} = arrayfun(@(x) find(unique_Voltage == x),...
        indivDataset{mbIndex}.imagevcoAtom,'UniformOutput',0);
end

%% Aggregate
[yData, yData_Average, yData_error]  = deal(cell(1, NumUniqueVolt));

for mbIndex = 1:NumRepetitions
    NumVoltages = indivDataset{mbIndex}.CounterAtom;
    for bIndex = 1:NumVoltages

%         Exposure_Time = analyVar.Exposure_Time(mbIndex);
%         Signal = indivDataset{mbIndex}.delay_spectra{bIndex}./Exposure_Time;
        Signal = indivDataset{mbIndex}.delay_spectra{bIndex};
        Signal = nansum(Signal(20:end),1);
        Signal = squeeze(Signal);
        
        yData{UniqueVoltageIndex{mbIndex}{bIndex}} = cat(1, yData{UniqueVoltageIndex{mbIndex}{bIndex}}, Signal);

    end
end

for uniqueVoltageIndex = 1:NumUniqueVolt
    yData_Average{uniqueVoltageIndex} = mean(yData{uniqueVoltageIndex});
%     yData_error{uniqueVoltageIndex} = std(yData{uniqueVoltageIndex})/(length(yData{uniqueVoltageIndex}))^0.5;
    yData_error{uniqueVoltageIndex} = std(yData{uniqueVoltageIndex});
end

[AveUVSpectrum, AveUVSpectrum_error] = deal([]);

for uniqueVoltageIndex = 1:NumUniqueVolt
    AveUVSpectrum       = cat(1, AveUVSpectrum, yData_Average{uniqueVoltageIndex});
    AveUVSpectrum_error = cat(1, AveUVSpectrum_error, yData_error{uniqueVoltageIndex});
end    

end

