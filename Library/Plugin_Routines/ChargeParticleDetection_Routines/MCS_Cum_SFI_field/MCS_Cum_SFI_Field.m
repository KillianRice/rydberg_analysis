function indivDataset = MCS_Cum_SFI_Field( analyVar, indivDataset, avgDataset)
%MCS_CUM_SFI_FIELD Summary of this function goes here
%   Detailed explanation goes here

    figure
    hold on
    xlabel('Total Plate Voltage Difference (V)')
    ylabel('Total MCS Counts')
    for i = 1:analyVar.numBasenamesAtom
        
        ramp_coeffs = param_extract_ramp_coeffs(analyVar, indivDataset{i});
        [roi_min, roi_max] = param_extract_sfi_roi(analyVar, indivDataset{i});
        indivDataset{i}.cumSFI = zeros(size(indivDataset{i}.mcsSpectra{1}));
        indivDataset{i}.cumSFI(:,1) = indivDataset{i}.mcsSpectra{1}(:,1);
        
        totsfi = zeros(size(indivDataset{i}.mcsSpectra{1}(:,2:end)));
        for j = 1:indivDataset{i}.CounterAtom
            
            totsfi = totsfi + indivDataset{i}.mcsSpectra{j}(:,2:end);
            
        end
        
        indivDataset{i}.cumSFI(:,2:end) = totsfi;
        indivDataset{i}.SFIvoltages = polyval(ramp_coeffs, indivDataset{i}.cumSFI(:,1)*10^6);
        sfiTimes = indivDataset{i}.cumSFI(roi_min:roi_max,1)*10^6;
        
        for s = 1:size(totsfi(1,:),2)
            plot(indivDataset{i}.SFIvoltages(roi_min:roi_max),indivDataset{i}.cumSFI(roi_min:roi_max,s+1),'-o','Color',analyVar.COLORS(i,:));
            mean = sum(indivDataset{i}.SFIvoltages(roi_min:roi_max).*indivDataset{i}.cumSFI(roi_min:roi_max,s+1))/sum(indivDataset{i}.cumSFI(roi_min:roi_max,s+1));
            std = sqrt(sum(indivDataset{i}.cumSFI(roi_min:roi_max,s+1).*(indivDataset{i}.SFIvoltages(roi_min:roi_max)-mean).^2)/sum(indivDataset{i}.cumSFI(roi_min:roi_max,s+1)));
            disp(['mean: ' num2str(mean)])
            disp(['std: ' num2str(std)])
            
        end
        
    end
    hold off
    
    figure
    plot(sfiTimes, polyval(ramp_coeffs, sfiTimes), 'o-');
    xlabel('Time (us)')
    ylabel('Ramp Voltage (V)')

    figure
    plot(polyval(ramp_coeffs,sfiTimes), polyval(polyder(ramp_coeffs), sfiTimes), 'o-');
    xlabel('Ramp Voltage (V)')
    ylabel('Slew Rate (V/us)')

end

