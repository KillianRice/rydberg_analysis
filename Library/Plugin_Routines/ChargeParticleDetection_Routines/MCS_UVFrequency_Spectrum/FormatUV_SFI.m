function [indivDataset] = FormatUV_SFI(analyVar,indivDataset)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
NumRepetitions = analyVar.numBasenamesAtom;

[SinglePHD] = deal(cell(1,NumRepetitions));

for mbIndex = 1:NumRepetitions
    
    NumThreshold = indivDataset{mbIndex}.CounterAtom;
    [SinglePHD{mbIndex}] = deal([]);
    
    for bIndex = 1:NumThreshold
        if size(indivDataset{mbIndex}.delay_spectra{bIndex},2)>1
            error('Expecting Data at single value of field delay, not multiple.')
        end
        data = indivDataset{mbIndex}.delay_spectra{bIndex};
        data = nansum(data(1:end),1);
%         data = squeeze(data);
        SinglePHD{mbIndex} = cat(1,SinglePHD{mbIndex},data);
    end
        
    indivDataset{mbIndex}.SinglePHD = SinglePHD{mbIndex}; %result is just one vector so choose to associate it with the index of the first entry in the master batch instead of makings copies for each entry

end

end

