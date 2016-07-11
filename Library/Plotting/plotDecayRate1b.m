function [ output_args ] = plotDecayRate1b( analyVar, indivDataset )

Functional_Form = @(coeffs,x) coeffs(1)*x+coeffs(2);

    figure(10000)
    hold on
for mbIndex     =   1:analyVar.numBasenamesAtom

 
        x_data = indivDataset{mbIndex}.densityvector{1};
        x_data = reshape(x_data,size(x_data));
        y_data = indivDataset{mbIndex}.DecayRate(:,1);
        y_data = reshape(y_data,size(y_data));
        
        plothan=plot(...
            x_data,...
            y_data,...
            analyVar.MARKERS2{mbIndex},...
            'Color',analyVar.COLORS(mbIndex,:),...
            'MarkerSize',analyVar.markerSize...
            );
        
        fitIndVar = linspace(0,max(x_data),1e4)';
        fitdataHan = ...
            plot(...
            fitIndVar,...
            Functional_Form(...
                [indivDataset{mbIndex}.DecayRateSlope(1), indivDataset{mbIndex}.DecayRate_yIntercept(1)],...
                fitIndVar...
                ),...
            'Color',analyVar.COLORS(mbIndex,:)...
            );
        
        xlabel('Atom Number','FontSize',analyVar.axisfontsize);
        ylabel('Decay Rate (s^-1)','FontSize',analyVar.axisfontsize);
        
%         title(sprintf('%s %s','Master Batch Index:',mat2str(mbIndex)),'FontSize',analyVar.titleFontSize)
     
end
        legendVec2= cat(1,1:analyVar.numBasenamesAtom, 1:analyVar.numBasenamesAtom);
        SortedLegendVec=sort(legendVec2);
        hleg = legend(num2str(SortedLegendVec(:)),'Location','Best');
        htitle = get(hleg, 'Title');
        set(htitle,'String', 'Master Batch Index:')
hold off
end

