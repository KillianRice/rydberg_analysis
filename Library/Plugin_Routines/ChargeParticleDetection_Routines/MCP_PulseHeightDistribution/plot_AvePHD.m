function [ output_args ]  = plot_AvePHD(analyVar, indivDataset, unique_Voltage, AveUVSpectrum, AveUVSpectrum_error)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Load Data
    [xData, ~] = EngineeringForm(unique_Voltage);
    yData = AveUVSpectrum; 
    yData_error = AveUVSpectrum_error;

    numRamps = analyVar.numLoopsSets(1);
    exposuretime = analyVar.Exposure_Time(1)*1e6; %us
    offset_scale = 1/numRamps/exposuretime;
    yData = offset_scale*yData;
    yData_error = offset_scale*yData_error;
%% Plot    

figHan = figure('Units', 'pixels', ...
    'Position', [100 100 315 200]);

set(figHan, 'Renderer', 'painters')
hold on

axHan = gca;

DataPlotHan = errorbar(xData, yData, yData_error);        
%         DataPlotHan{DensityIndex} = plot(xData, offset_scale*yData{DensityIndex});

set(DataPlotHan, ...
    'Marker'         , 'o',...
    'MarkerSize'      , 3,...
    'LineStyle'       , '-' , ...
    'LineWidth'       , 0.5,...
    'Color'           , analyVar.COLORS(2,:),...
    'markerfacecolor' , analyVar.COLORS(2,:)...
    ); 
removeErrorBarEnds(DataPlotHan)
    
%     DensityScale = 1E-18;
%     legendstr = indivDataset{1}.densityvector;
%     legendstr = round(legendstr*DensityScale)/10;
%     legendstr = textscan(num2str(legendstr'),'%s');
%     legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
%     legarray = [];
%     for dIndex = 1:NumDensities
%         legarray = cat(1, legarray, DataPlotHan{dIndex});
%     end
%     hLegend = legend(legarray, legendstr);
%     set(get(hLegend,'title'),'string','Density (10^{13} cm^{-3})')

    hold off
    axis tight

    FontSize = 8;
%     hLegend = legend([DataPlotHan{1}, DataPlotHanZoom{1}, vertLineHan{2}], 'Data', 'Data (x10)', 'Dimer Calc.');
%     set(hLegend,...
%         'FontSize', FontSize,...
%         'Units', 'Normalized',...
%         'Position', [.265 .65 .2 .175]) 
%% Make it Pretty    

    grid on
    hXLabel = xlabel('Threshold Voltage (mV)');
    hYLabel = ylabel('Count Rate (\mus^{-1})');

    set([hXLabel, hYLabel, axHan] , 'FontSize', FontSize);
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickLength'  , [.02 .02] , ...        
      'XMinorTick'  , 'off'      , ...
      'XColor'      , [0 0 0], ...
      'XScale'      , 'Log'     , ...
      'YColor'      , [0 0 0], ...
      'YMinorTick'  , 'off'      , ...
      'YMinorGrid'  , 'off'      ,...
      'YScale'      , 'Log'     , ...
      'YLim'        , [1e-3, 1e2],...
      'LineWidth'   , 0.5, ...
      'Clipping' , 'off' ...
            );    

output_args = nan;
end