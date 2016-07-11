function output = plot_with_confidence_intervals_Exponential_Decay2(...
    fignum,...
    x_data_vec,...
    y_data_array,...
    DecayRate,...
    Noise_to_Sig_Coeff)
 
specFitFig = figure(fignum);
[subPlotRows,subPlotCols] = optiSubPlotNum(size(y_data_array,2));

x0 = min(x_data_vec);

Functional_Form = @(coeffs,x) ...
    (exp(-coeffs(1)*(x-x0))+coeffs(2)*exp(coeffs(1)*x0))...
    /...
    (1+coeffs(2)*exp(coeffs(1)*x0));

for densityIndex = 1:size(y_data_array,2);

    figure(specFitFig);
    fitIndVar = linspace(min(x_data_vec),max(x_data_vec),1e4)';

    lower_Coeff_DecayRate=DecayRate(densityIndex,1)-DecayRate(densityIndex,2);
    upper_Coeff_DecayRate=DecayRate(densityIndex,1)+DecayRate(densityIndex,2);

    lower_Noise_to_Sig=Noise_to_Sig_Coeff(densityIndex,1)-Noise_to_Sig_Coeff(densityIndex,2);
    upper_Noise_to_Sig=Noise_to_Sig_Coeff(densityIndex,1)+Noise_to_Sig_Coeff(densityIndex,2);

    lower   = Functional_Form([upper_Coeff_DecayRate,lower_Noise_to_Sig],fitIndVar);
    upper   = Functional_Form([lower_Coeff_DecayRate,upper_Noise_to_Sig],fitIndVar);

    subplot(subPlotRows,subPlotCols,densityIndex)
    ciplot(lower,upper,fitIndVar,'y');
    hold on
    rawdataHan = plot(x_data_vec,y_data_array(:,densityIndex));
    fitdataHan = plot(fitIndVar, Functional_Form(...
        [DecayRate(densityIndex,1), Noise_to_Sig_Coeff(densityIndex,1)],...
        fitIndVar...
        ));

    xlabel('Ramp Delay (s)'); grid on; axis tight
    set(rawdataHan,'LineStyle','none','Marker','o');
    set(fitdataHan,'LineWidth',2,'Color','b');
    axis([0 max(x_data_vec) 0.0 1.0])
end

end