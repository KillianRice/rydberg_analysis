function indivDataset = MCS_Cum_SFI(analyVar, indivDataset, avgDataset)

    % Plot the total sfi profile of a given scan
    
    for i = 1:analyVar.numBasenamesAtom
        
        roi_min = analyVar.mcs_roi(1);
        if analyVar.mcs_roi(2) == -1
            roi_max = size(indivDataset{i}.mcsSpectra{1},1);
        else
            roi_max = analyVar.mcs_roi(2);
        end
        
        indivDataset{i}.cumSFI = zeros(size(indivDataset{i}.mcsSpectra{1}));
        indivDataset{i}.cumSFI(:,1) = indivDataset{i}.mcsSpectra{1}(:,1);
        
        totsfi = zeros(size(indivDataset{i}.mcsSpectra{1}(:,2:end)));
        for j = 1:indivDataset{i}.CounterAtom
            
             totsfi = totsfi + indivDataset{i}.mcsSpectra{j}(:,2:end);
            
        end
        
        indivDataset{i}.cumSFI(:,2:end) = totsfi;
        
        figure
        hold on
        for s = 2:size(totsfi(1,:),2)
            bar(indivDataset{i}.cumSFI(roi_min:roi_max,1),indivDataset{i}.cumSFI(roi_min:roi_max,s));
        end
        hold off
    end

    
    
end