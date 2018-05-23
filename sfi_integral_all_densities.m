function [ analyVar, indivDataset, avgDataset ] = sfi_integral_all_densities( analyVar, indivDataset, avgDataset )

for basename = 1:analyVar.numBasenamesAtom

        roi_min = indivDataset{basename}.mcs_roiMin;
        roi_max = indivDataset{basename}.mcs_roiMax;

        if roi_max == -1
            roi_max = size(indivDataset{basename}.mcsSpectra{1},1);
        end


        num_densities = size(indivDataset{basename}.mcsSpectra{1},2) - 1;
        indivDataset{basename}.sfiIntegral_allDensities = zeros(length(indivDataset{basename}.imagevcoAtom),num_densities);

        for i = 1:length(indivDataset{basename}.imagevcoAtom)
            indivDataset{basename}.sfiIntegral_allDensities(i,:) = ...
                sum(indivDataset{basename}.mcsSpectra{i}(roi_min:roi_max,2:end),1);
        end


end

end

