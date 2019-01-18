function plot_MCS_Integrated_SFI_Spectrum(analyVar, indivDataset)

    figure;
    hold on;
    for i = 1:analyVar.numBasenamesAtom
        
        plot(indivDataset{i}.imagevcoAtom, indivDataset{i}.sfiIntegral,...
            analyVar.MARKERS{i}, 'Color', analyVar.COLORS(i,:),...
            'MarkerSize', analyVar.markerSize,...
            'DisplayName',num2str(analyVar.timevectorAtom(i)));
        xlabel('GHz synth. [MHz]');
        ylabel('Total MCS Counts');
    end
    legend('show', 'Location', 'best');
    hold off;    
end