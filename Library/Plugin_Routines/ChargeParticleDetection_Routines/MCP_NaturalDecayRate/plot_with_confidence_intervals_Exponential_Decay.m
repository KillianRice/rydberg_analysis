function output = plot_with_confidence_intervals_Exponential_Decay(...
    fignum,...
    x_data_vec,...
    y_data_array,...
    InitialValue,...
    DecayRate,...
    Offset)

specFitFig = figure(fignum);
[subPlotRows,subPlotCols] = optiSubPlotNum(length(x_data_vec));

Functional_Form = @(coeffs,x) ...
    coeffs(1)*exp(-coeffs(2)*x)+coeffs(3);

for densityIndex = 1:size(y_data_array,2);
    
    figure(specFitFig);
    fitIndVar = linspace(min(x_data_vec),max(x_data_vec),1e4)';
    
    lower_Coeff_InitialValue=InitialValue(densityIndex,1)-InitialValue(densityIndex,2);
    upper_Coeff_InitialValue=InitialValue(densityIndex,1)+InitialValue(densityIndex,2);
    
    lower_Coeff_DecayRate=DecayRate(densityIndex,1)-DecayRate(densityIndex,2);
    upper_Coeff_DecayRate=DecayRate(densityIndex,1)+DecayRate(densityIndex,2);
    
    lower_Coeff_Offset=Offset(densityIndex,1)-Offset(densityIndex,2);
    upper_Coeff_Offset=Offset(densityIndex,1)+Offset(densityIndex,2);
    
    lower   = Functional_Form([lower_Coeff_InitialValue,upper_Coeff_DecayRate,lower_Coeff_Offset],fitIndVar);
    upper   = Functional_Form([upper_Coeff_InitialValue,lower_Coeff_DecayRate,upper_Coeff_Offset],fitIndVar);
    
    subplot(subPlotRows,subPlotCols,densityIndex)
    ciplot(lower,upper,fitIndVar,'y');
    hold on
    rawdataHan = plot(x_data_vec,y_data_array(:,densityIndex));
    fitdataHan = plot(fitIndVar, Functional_Form(...
        [InitialValue(densityIndex,1),...
            DecayRate(densityIndex,1),...
            Offset(densityIndex,1),...
        ],...
        fitIndVar...
        ));

    xlabel('Ramp Delay (s)'); grid on; axis tight
    set(rawdataHan,'LineStyle','none','Marker','o');
    set(fitdataHan,'LineWidth',2,'Color','b');
%     axis([0 max(x_data_vec) 0.0 1.0])
    
%     subplot(subPlotRows,subPlotCols,densityIndex)
%     ciplot(lower,upper,fitIndVar,'y');
%     hold on
%     rawdataHan = plot(x_data_vec{densityIndex},y_data_array{densityIndex});
%     fitdataHan = plot(fitIndVar, Functional_Form([InitialValue(densityIndex,1), DecayRate(densityIndex,1), Offset(densityIndex,1)],fitIndVar));
%     
%     xlabel('MHz'); grid on; axis tight
%     set(rawdataHan,'LineStyle','none','Marker','o');
%     set(fitdataHan,'LineWidth',2,'Color','b');

end

end