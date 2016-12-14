function indivDataset = param_extract_sfi_integral(analyVar, indivDataset)

    for i = 1:analyVar.numBasenamesAtom % loop over batches
        
        
        indivDataset{i}.sfiIntegral = zeros(indivDataset{i}.CounterMCS,1); %initalize sum vector
        for j = 1:indivDataset{i}.CounterMCS % loop over mcs files
           
            % calculate the sum of the spectrum directly
            roi_min = analyVar.mcs_roi(1);
            if analyVar.mcs_roi(2) == -1
                roi_max = size(indivDataset{i}.mcsSpectra{j}(:,2));
            else
                roi_max = analyVar.mcs_roi(2);
            end
            
            indivDataset{i}.sfiIntegral(j) = sum(indivDataset{i}.mcsSpectra{j}(roi_min:roi_max,2)); 
            
        end
        
    end
    
end