function [ output_args ] = plotMCSTraces_counts_vs_delaytime( analyVar,indivDataset )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for mbIndex = 1:analyVar.numBasenamesAtom
    delay_spectra = cell(length(indivDataset{mbIndex}.delay_spectra),1);
    figure(mbIndex*1000);
    for bIndex = 1:indivDataset{mbIndex}.CounterAtom
        delay_spectra{bIndex}=indivDataset{mbIndex}.delay_spectra{bIndex};
%         delay_spectra{bIndex}=permute(delay_spectra{bIndex},[2 1 3]);
%         delay_spectra{bIndex}=log10(delay_spectra{bIndex});
        % delay_spectra{bIndex}=flipdim(delay_spectra{bIndex},1);
        for DensityIndex = 1:indivDataset{mbIndex}.numDensityGroups{bIndex}
                subplot(...
                    indivDataset{mbIndex}.numDensityGroups{1},...
                    indivDataset{mbIndex}.CounterAtom,...
                    bIndex+(DensityIndex-1)*indivDataset{mbIndex}.CounterAtom);                
%                 imagesc(delay_spectra{bIndex}(:,:,DensityIndex))
                hold on
                PeakBin = analyVar.PeakSignalBin- analyVar.roiStart+1;%adjust which bin to look at and correct for possible "off-by one error"
                for bin = PeakBin-2:PeakBin
                    [xticks, ~, xSpacing] = AxisTicksEngineeringForm(indivDataset{mbIndex}.timedelayOrderMatrix{bIndex});
                    [yticks, ~, ySpacing] = AxisTicksEngineeringForm(delay_spectra{bIndex}(bin,:,DensityIndex));

                    plot(xticks,yticks)
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
                        mat2str(indivDataset{mbIndex}.synthFreq(bIndex)),...
                        'MHz'...
                    )...
                )
                
        end
    end
    mtit(sprintf('%s %s %s %s','Date:', mat2str(analyVar.dataDirName),'Time:', mat2str(analyVar.timevectorAtom(mbIndex))))
end
     

end
