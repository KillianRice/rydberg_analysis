function [ output_args ] = plotDecayRate( analyVar, indivDataset )

Functional_Form = @(coeffs,x) coeffs(1)*x+coeffs(2);

for mbIndex     =   1:analyVar.numBasenamesAtom
    figure(mbIndex*10000)
    hold on
    for bIndex  =   1:indivDataset{mbIndex}.CounterMCS
        
        x_data = indivDataset{mbIndex}.densityvector{bIndex};
        x_data = reshape(x_data,size(x_data));
        y_data = indivDataset{mbIndex}.DecayRate{bIndex}(:,1);
        y_data = reshape(y_data,size(y_data));
        
        plothan=plot(...
            x_data,...
            y_data,...
            analyVar.MARKERS2{bIndex},...
            'Color',analyVar.COLORS(bIndex,:),...
            'MarkerSize',analyVar.markerSize...
            );
        
        fitIndVar = linspace(0,max(x_data),1e4)';
        fitdataHan = ...
            plot(...
            fitIndVar,...
            Functional_Form(...
                [indivDataset{mbIndex}.DecayRateSlope(bIndex,1), indivDataset{mbIndex}.DecayRate_yIntercept(bIndex,1)],...
                fitIndVar...
                ),...
            'Color',analyVar.COLORS(bIndex,:)...
            );
        
        xlabel('Atom Number','FontSize',analyVar.axisfontsize);
        ylabel('Decay Rate (s^-1)','FontSize',analyVar.axisfontsize);
        
        title(sprintf('%s %s','Master Batch Index:',mat2str(mbIndex)),'FontSize',analyVar.titleFontSize)
        
        legendVec2= cat(1,indivDataset{mbIndex}.synthFreq, indivDataset{mbIndex}.synthFreq);
        SortedLegendVec=sort(legendVec2);
        hleg = legend(num2str(SortedLegendVec(:)),'Location','Best');
        htitle = get(hleg, 'Title');
        set(htitle,'String', 'Synth Freq. (MHz)')
    end
    hold off
end

end

