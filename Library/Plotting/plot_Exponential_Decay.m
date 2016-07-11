function output = plot_Exponential_Decay(x_data_cell, y_data_cell, InitialValue, TimeConstant, Offset, Functional_Form)


figure(1111);
hold on;

for iterVar = 1:length(x_data_cell);
    
    fitIndVar = linspace(min(x_data_cell{iterVar}),max(x_data_cell{iterVar}),1e4)';
    
    rawdataHan = plot(x_data_cell{iterVar},y_data_cell{iterVar});
    fitdataHan = plot(fitIndVar, Functional_Form([InitialValue(iterVar,1), TimeConstant(iterVar,1), Offset(iterVar,1)],fitIndVar));
    
    xlabel('Time'); grid on; axis tight
    set(rawdataHan,'LineStyle','none','Marker','o');
    set(fitdataHan,'LineWidth',2,'Color','b');
    if iterVar == length(x_data_cell);
        set(gcf,'Name','SpectraFits');
    end
    
end

end