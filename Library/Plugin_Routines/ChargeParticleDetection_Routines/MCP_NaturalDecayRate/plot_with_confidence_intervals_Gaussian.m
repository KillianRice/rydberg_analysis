function output = plot_with_confidence_intervals_Gaussian(x_data_cell,y_data_cell, amplitude, center, sigma, offset, Functional_Form)

%x_data_cell = indVarCell
%y_data_cell = MCS_trace_integrals_wo_Delay
%amplitude = amplitude
%center = center
%sigma = sigma
%offset = offset
%Functional_Form = GaussianFitModel

specFitFig = figure;
[subPlotRows,subPlotCols] = optiSubPlotNum(length(x_data_cell));

for iterVar = 1:length(x_data_cell);
    
    figure(specFitFig);
    fitIndVar = linspace(min(x_data_cell{iterVar}),max(x_data_cell{iterVar}),1e4)';
    
    lower_Coeff_amp=amplitude(iterVar,1)-amplitude(iterVar,2);
    upper_Coeff_amp=amplitude(iterVar,1)+amplitude(iterVar,2);
    
    lower_Coeff_sigma=sigma(iterVar,1)-sigma(iterVar,2);
    upper_Coeff_sigma=sigma(iterVar,1)+sigma(iterVar,2);
    
    lower_Coeff_offset=offset(iterVar,1)-offset(iterVar,2);
    upper_Coeff_offset=offset(iterVar,1)+offset(iterVar,2);
    
    lower= Functional_Form([lower_Coeff_amp,center(iterVar,1),lower_Coeff_sigma,lower_Coeff_offset],fitIndVar);
    upper = Functional_Form([upper_Coeff_amp,center(iterVar,1),upper_Coeff_sigma,upper_Coeff_offset],fitIndVar);
    
    subplot(subPlotRows,subPlotCols,iterVar)
    ciplot(lower,upper,fitIndVar,'y');
    hold on
    rawdataHan = plot(x_data_cell{iterVar},y_data_cell{iterVar});
    fitdataHan = plot(fitIndVar, Functional_Form([amplitude(iterVar,1), center(iterVar,1), sigma(iterVar,1), offset(iterVar,1)],fitIndVar));
    
    xlabel('MHz'); grid on; axis tight
    set(rawdataHan,'LineStyle','none','Marker','o');
    set(fitdataHan,'LineWidth',2,'Color','b');
    if iterVar == length(x_data_cell);
        set(gcf,'Name','SpectraFits');
    end
end

end