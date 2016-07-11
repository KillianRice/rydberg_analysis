clear all
close all
analyVar = AnalysisVariables;
D0 = [...
    29 59.1;...
    30 47.2;...
    33 25.1;...
    34 20.5;...
    35 17.0;...
    36 14.0;...
    38 9.8;... %Rydberg Exp
    49 1.8;... %Rydberg Exp
    ];
Tr00 = [38 19.6;...
        49 3.6]; %thermal
Te000 = [38 29.3;...
        49 5.4]; %thermal

xData{1} = D0(:,1)-analyVar.QDefect;
yData{1} = D0(:,2);
xData{2} = Tr00(:,1)-analyVar.QDefect;
yData{2} = Tr00(:,2);
xData{3} = Te000(:,1)-analyVar.QDefect;
yData{3} = Te000(:,2);

[yData_error, Amplitude, FittingRoutine, fit_xData, fit_yData ] = deal(cell(1, length(xData)));
for index = 1:length(xData)
    yData_error{index} = 0.2*ones(size(yData{index}));
    [Amplitude{index}, FittingRoutine{index}] = ...
        FCpoly_Fit( xData{index}, yData{index}, yData_error{index}, 1, -6 );
    fit_xData{index} = linspace( min(xData{index}) , 60, 1e4)'; 
    fit_yData{index} = FittingRoutine{index}.predict(fit_xData{index});
    Amplitude{index}
end

PlotStruct.xData = xData;
PlotStruct.yData = yData;
PlotStruct.yData_error = yData_error;
PlotStruct.hXLabel = {'n-\delta'};
PlotStruct.hYLabel = {'Binding Energy (MHz)'};
colors = FrancyColors2(-1);
PlotStruct.colors = colors(1:6,:);
PlotStruct.colors2 = colors(7:12,:);

FC_Plotter(analyVar, PlotStruct);

for index = 1:length(xData)
    plot(fit_xData{index}, fit_yData{index}, 'Color', colors(index,:))
    [[xData{index}+analyVar.QDefect; 60] -FittingRoutine{index}.predict([xData{index}; 60-analyVar.QDefect])-.15 -FittingRoutine{index}.predict([xData{index}; 60-analyVar.QDefect])+.15]
end

set(gca,... 
    'XScale'        , 'log',...
    'YScale'        , 'log');
axis tight

BE = @(n, N) N*16.8149e+009/(n-3.372)^6; %MHz, calculate the binding energy of the ground state N-mer at quantum number n.
