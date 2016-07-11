function [ output_args ] = plotAvgMCSTraces_counts_vs_delaytime_SumNonPeak( analyVar,indivDataset )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

PeakBin = analyVar.PeakBin;

[AvgSpectra, AvgSpectra_error]= deal(cell(1,indivDataset{1}.CounterAtom));
figure(analyVar.timevectorAtom(1)*10+3);
for bIndex = 5;%1:indivDataset{1}.CounterAtom
    AvgSpectra{bIndex} = analyVar.AvgSpectra{bIndex};
    AvgSpectra_error{bIndex} = analyVar.AvgSpectra_error{bIndex};
    for DensityIndex = 5;%1:indivDataset{1}.numDensityGroups{bIndex}
            
        subplot(...
            indivDataset{1}.numDensityGroups{1},...
            indivDataset{1}.CounterAtom,...
            bIndex+(DensityIndex-1)*indivDataset{1}.CounterAtom);                

        hold on
            
        [xticks, ~, xSpacing] = AxisTicksEngineeringForm(indivDataset{1}.timedelayOrderMatrix{bIndex});
        for bin = 1:3

            if bin == 1
                [yticks, ~, ySpacing] = AxisTicksEngineeringForm(AvgSpectra{bIndex}(PeakBin,:,DensityIndex));
                y_error = AvgSpectra_error{bIndex}(PeakBin,:,DensityIndex);
            elseif bin == 2
                [yticks, ~, ySpacing] = AxisTicksEngineeringForm(analyVar.Sum_NonPeak_AvgSpectra{bIndex}(:,DensityIndex));
                y_error = analyVar.Sum_NonPeak_AvgSpectra_error{bIndex}(:,DensityIndex)';
            elseif bin == 3
                [yticks, ~, ySpacing] = AxisTicksEngineeringForm(nansum(analyVar.AvgSpectra{bIndex}(:,:,DensityIndex)));
                y_error = (analyVar.Sum_NonPeak_AvgSpectra_error{bIndex}(:,DensityIndex)'+AvgSpectra_error{bIndex}(PeakBin,:,DensityIndex));
            end

            plothan=errorbar(...
                xticks,...
                yticks,...
                y_error,...
                analyVar.MARKERS2{bin},...
                'Color',analyVar.COLORS(bin,:),...
                'MarkerSize',analyVar.markerSize/4);

        end
            
        hold off
        
        axis square tight

        ax = gca; % current axes
        set(ax,'FontSize',8);
        set(ax,'TickDir','out');
        set(ax,'TickLength', [0.02 0.02]);
        xlabel('Field Delay (us)')
        ylabel('MCS Counts')
        title(...
            sprintf(...
                '%s %s %s %s %s',...
                'n0:',...
                mat2str(DensityIndex),...
                ', Synth:',...
                mat2str(indivDataset{1}.synthFreq(bIndex)),...
                'MHz'...
            )...
        )

    end
end
mtit(sprintf('%s %s %s %s','Date:', mat2str(analyVar.dataDirName),'Time:', mat2str(analyVar.timevectorAtom(1))))

     

end
