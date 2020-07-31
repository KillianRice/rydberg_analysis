function indivDataset = param_extract_sfi_integral_roi_select(analyVar, indivDataset)
    

    for i = 1:analyVar.numBasenamesAtom % loop over batches
        indivDataset{i}.sfiIntegral_roi1 = zeros(indivDataset{i}.CounterMCS,1); %initalize sum vector
        indivDataset{i}.sfiIntegral_roi2 = zeros(indivDataset{i}.CounterMCS,1); %initalize sum vector
        indivDataset{i}.sfiIntegral_roi1_ratio = zeros(indivDataset{i}.CounterMCS,1); %initalize sum vector
        indivDataset{i}.sfiIntegral_roi2_ratio = zeros(indivDataset{i}.CounterMCS,1); %initalize sum vector
        for j = 1:indivDataset{i}.CounterMCS % loop over mcs files
            roi1_min = analyVar.roi1_minimum;
            roi1_max = analyVar.roi1_maximum;
            roi2_min = analyVar.roi2_minimum;
            roi2_max = analyVar.roi2_maximum;
            indivDataset{i}.sfiIntegral_roi1(j) = sum(indivDataset{i}.mcsSpectra{j}(roi1_min:roi1_max,2));
            indivDataset{i}.sfiIntegral_roi2(j) = sum(indivDataset{i}.mcsSpectra{j}(roi2_min:roi2_max,2));
            indivDataset{i}.sfiIntegral_roi1_ratio(j) = sum(indivDataset{i}.mcsSpectra{j}(roi1_min:roi1_max,2))/sum(indivDataset{i}.mcsSpectra{j}(roi1_min:roi2_max,2));
            indivDataset{i}.sfiIntegral_roi2_ratio(j) = sum(indivDataset{i}.mcsSpectra{j}(roi2_min:roi2_max,2))/sum(indivDataset{i}.mcsSpectra{j}(roi1_min:roi2_max,2));
            
        end
    end
end
