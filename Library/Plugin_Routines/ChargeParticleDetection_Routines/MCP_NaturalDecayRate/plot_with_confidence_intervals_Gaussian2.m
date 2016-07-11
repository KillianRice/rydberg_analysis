function output = plot_with_confidence_intervals_Gaussian2(...
    analyVar,...
    indivDataset,...
    x_data_Array,...
    y_data_Array,...
    legendVec,...
    amplitude,...
    center,...
    sigma,...
    offset,...
    Functional_Form)

%x_data_cell = indVarCell
%y_data_cell = MCS_trace_integrals_wo_Delay
%amplitude = amplitude
%center = center
%sigma = sigma
%offset = offset
%Functional_Form = GaussianFitModel

specFitFig  = figure;
numSubPlots = size(x_data_Array,3);
numContours = size(x_data_Array,2);
[subPlotRows,subPlotCols] = optiSubPlotNum(numSubPlots);

for iterVar = 1:numSubPlots;
    figure(specFitFig);
    
    for contourIndex = 1:numContours
        
        fitIndVar = linspace(min(x_data_Array(:,contourIndex,iterVar)),max(x_data_Array(:,contourIndex,iterVar)),1e4)';

        lower_Coeff_amp     =amplitude(contourIndex,iterVar,1)-amplitude(contourIndex,iterVar,2);
        upper_Coeff_amp     =amplitude(contourIndex,iterVar,1)+amplitude(contourIndex,iterVar,2);

        lower_Coeff_sigma   =sigma(contourIndex,iterVar,1)-sigma(contourIndex,iterVar,2);
        upper_Coeff_sigma   =sigma(contourIndex,iterVar,1)+sigma(contourIndex,iterVar,2);

        lower_Coeff_offset  =offset(contourIndex,iterVar,1)-offset(contourIndex,iterVar,2);
        upper_Coeff_offset  =offset(contourIndex,iterVar,1)+offset(contourIndex,iterVar,2);

        lower               = Functional_Form([lower_Coeff_amp,center(contourIndex,iterVar,1),lower_Coeff_sigma,lower_Coeff_offset],fitIndVar);
        upper               = Functional_Form([upper_Coeff_amp,center(contourIndex,iterVar,1),upper_Coeff_sigma,upper_Coeff_offset],fitIndVar);

        subplot(subPlotRows,subPlotCols,iterVar)
%         ciplot(lower,upper,fitIndVar,'y');
        hold on
        rawdataHan = plot(...
            x_data_Array(:,contourIndex,iterVar),...
            y_data_Array(:,contourIndex,iterVar),...
            analyVar.MARKERS2{contourIndex},...
            'Color',analyVar.COLORS(contourIndex,:),...
            'MarkerSize',7);
        
        fitdataHan = plot(...
            fitIndVar,...
            Functional_Form([amplitude(contourIndex,iterVar,1), center(contourIndex,iterVar,1), sigma(contourIndex,iterVar,1), offset(contourIndex,iterVar,1)],fitIndVar),...
            'Color',analyVar.COLORS(contourIndex,:)...
            );
        
        legendVec2= cat(1,1e6*legendVec,1e6*legendVec);
        SortedLegendVec=sort(legendVec2);
        
        hleg = legend(num2str(SortedLegendVec(:)),'Location','Best');
        htitle = get(hleg, 'Title');
        set(htitle,'String', 'Time Delay (us)')
        
        xlabel('Synth Freq. (MHz)','FontSize',analyVar.axisfontsize);
        ylabel('Summed Trace Counts','FontSize',analyVar.axisfontsize);
        grid on; 
        axis tight
        
        %         gcf
        %         gca
        %         gco

        
        %         if iterVar == size(x_data_Array,3);
        %             set(gcf,'Name','SpectraFits');
        %         end
        hold off
    end
    
%     set(gca, 'Box', 'on', 'LineWidth', 2)
%     dataHan = get(gca,'Children');
%     for legendIndex = 2:2:2*numContours
%         set(...
%             get(...
%                 get(...
%                     dataHan(legendIndex),'Annotation'...
%                     ),...
%                 'LegendInformation'...
%                 ),...
%             'IconDisplayStyle',...
%             'off'...
%         )
%     end
end

end