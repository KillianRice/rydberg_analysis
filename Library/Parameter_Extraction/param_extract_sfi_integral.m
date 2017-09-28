function indivDataset = param_extract_sfi_integral(analyVar, indivDataset)

    for i = 1:analyVar.numBasenamesAtom % loop over batches
        
        
        indivDataset{i}.sfiIntegral = zeros(indivDataset{i}.CounterMCS,1); %initalize sum vector
        for j = 1:indivDataset{i}.CounterMCS % loop over mcs files
           
            % calculate the sum of the spectrum directly
            [roi_min, roi_max] = param_extract_sfi_roi(analyVar, indivDataset{i});
            
            indivDataset{i}.sfiIntegral(j) = sum(indivDataset{i}.mcsSpectra{j}(roi_min:roi_max,2)); 
            
        end
        
    end
    
end