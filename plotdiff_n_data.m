function plotdiff_n_data( analyVar )
% xData{1} = csvread('38Thermal_xData.csv');
% xData{1} = csvread('38BEC_xData.csv');
% xData{2} = csvread('49Thermal_xData.csv');
% xData{2} = csvread('49BEC_xData.csv');
xData{1} = csvread('60Thermal_xData.csv');
xData{2} = csvread('60BEC_HighPower_xData.csv');
xData{3} = csvread('60BEC_LowPower_xData.csv');

% yData{1} = csvread('38Thermal_yData.csv');
% yData{1} = 5*csvread('38BEC_yData.csv');
% yData{2} = csvread('49Thermal_yData.csv');
% yData{2} = 1.4*csvread('49BEC_yData.csv');
yData{1} = csvread('60Thermal_yData.csv');
yData{2} = csvread('60BEC_HighPower_yData.csv');
yData{3} = csvread('60BEC_LowPower_yData.csv');

yData = cellfun(@(x) mean(x(:, 1:10), 2), yData, 'UniformOutput', 0);
colors = FrancyColors2(-1);

PlotStruct_AtomNum.LineStyle = '-';
PlotStruct_AtomNum.xData = xData;
PlotStruct_AtomNum.yData = yData;
PlotStruct_AtomNum.hXLabel = {'UV Detuning (MHz)'};
PlotStruct_AtomNum.hYLabel = {['Signal (Arb. Units)']};
PlotStruct_AtomNum.colors = colors(1:6,:);
PlotStruct_AtomNum.colors2 = colors(7:12,:);
FC_Plotter(analyVar, PlotStruct_AtomNum);
hold off
FC_Plotter(analyVar, PlotStruct_AtomNum);
set(gca,... 
    'YScale'        , 'log');
end

