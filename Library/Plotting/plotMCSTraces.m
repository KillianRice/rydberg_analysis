function [ output_args ] = plotMCSTraces( analyVar,indivDataset )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Max=0;
for mbIndex = 1:analyVar.numBasenamesAtom
    for bIndex = 1:indivDataset{mbIndex}.CounterAtom
        Max0=max(indivDataset{mbIndex}.delay_spectra{bIndex}(:));
        Max = max(Max,Max0);
    end
end
% Max = ceil(Max/100)*100;
order = Order_of_Magnitude(Max);
warning('check Order_of_Magnitude, Order_of_Magnitude2 fails for ~350')
order = order+1;
Max = 10^order;

for mbIndex = 1:analyVar.numBasenamesAtom
    delay_spectra = cell(length(indivDataset{mbIndex}.delay_spectra),1);
    figure(mbIndex*10);
    for bIndex = 1:indivDataset{mbIndex}.CounterAtom
        delay_spectra{bIndex}=indivDataset{mbIndex}.delay_spectra{bIndex};
        delay_spectra{bIndex}=permute(delay_spectra{bIndex},[2 1 3]);
        delay_spectra{bIndex}=log10(delay_spectra{bIndex});
        % delay_spectra{bIndex}=flipdim(delay_spectra{bIndex},1);
        for DensityIndex = 1:indivDataset{mbIndex}.numDensityGroups{bIndex}
                subplot(...
                    indivDataset{mbIndex}.numDensityGroups{1},...
                    indivDataset{mbIndex}.CounterAtom,...
                    bIndex+(DensityIndex-1)*indivDataset{mbIndex}.CounterAtom);  
                
            if analyVar.MCSTrace_x_var == 1
                [xticks, ~, xSpacing] = AxisTicksEngineeringForm(analyVar.ArrivalTime2);
                x_string = 'Arrival Time (us)';
            elseif analyVar.MCSTrace_x_var == 2
                [xticks, ~, xSpacing] = AxisTicksEngineeringForm(abs(analyVar.PushPullPotentialDiff2));
                x_string = 'Ionization Voltage (kV)';
            elseif analyVar.MCSTrace_x_var == 3
                [xticks, ~, xSpacing] = AxisTicksEngineeringForm(abs(analyVar.ElectricField2));
                x_string = 'Ionization Field (V/cm)';
            end
            xticks(2:end) = xticks(1:end-1);
            xticks(1) = 0;
                
%                 [yticks, ~, ySpacing] = AxisTicksEngineeringForm(indivDataset{mbIndex}.timedelayOrderMatrix{bIndex});
%                 yticks = yticks-0.5*ySpacing;   
%                 pcolor(xticks(mbIndex,:),yticks,delay_spectra{bIndex}(:,:,DensityIndex))

                plot(xticks(mbIndex,:),delay_spectra{bIndex}(:,:,DensityIndex))                
                
                axis square tight
%                 caxis([0 order])
                ax = gca; % current axes
                set(ax,'FontSize',8);
                set(ax,'TickDir','out');
                set(ax,'TickLength', [0.02 0.02]);
                xlabel(x_string)
                ylabel('Field Delay (us)')
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
%     axes('Position', [0.07 0.05 0.9 0.9], 'Visible', 'off');
%     c=colorbar('FontSize',12);
%     ylabel(c,['Counts per ',mat2str(analyVar.numLoopsSets),' Loop Sets'])
    mtit(sprintf('%s %s %s %s','Date:', mat2str(analyVar.dataDirName),'Time:', mat2str(analyVar.timevectorAtom(mbIndex))))
end
     

end

