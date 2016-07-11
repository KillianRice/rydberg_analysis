function [ output_args ] = plot_Ave_SFI(analyVar, indivDataset, unique_ExpTime, Ave_SFI, Ave_SFI_error, NormalizeFlag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Load Data

%% xData
xData = analyVar.ElectricField;

%% yData and yData_error
NumExpTime = length(unique_ExpTime);
[yData, yData_error] = deal(cell(1,NumExpTime));
for ExpTimeIndex = 1:NumExpTime
        yData{ExpTimeIndex} = Ave_SFI{ExpTimeIndex};
        yData_error{ExpTimeIndex} = Ave_SFI_error{ExpTimeIndex};
end
        
%% Plot    
FontSize = 8;
[DataPlotHan] = deal(cell(1,NumExpTime));
plotvec = floor(NumExpTime/6);
plotvec = 1:plotvec:NumExpTime;
figHan = figure('Units', 'pixels', ...
'Position', [100 100 315 200]);
set(figHan, 'Renderer', 'painters')
hold on

colorArray = FrancyColors(length(plotvec));
for Index = 1:length(plotvec)
    ExpTimeIndex = plotvec(Index);
    DataPlotHan{ExpTimeIndex} = errorbar(xData, yData{ExpTimeIndex},  yData_error{ExpTimeIndex});
    removeErrorBarEnds(DataPlotHan{ExpTimeIndex})
    set(DataPlotHan{ExpTimeIndex}, ...
        'LineStyle'       , '-' , ...
        'LineWidth'       , 0.5,...
        'Color'           , colorArray(Index,:),...
        'marker'          , 'o',...
        'markersize'      , 4,...
        'markerfacecolor' , colorArray(Index,:)...
        ); 
    
end

    hold off
    axis tight
    hXLabel = xlabel('Electric Field (V cm^{-1})');
    if NormalizeFlag
        hYLabel = ylabel('Normalized Signal (Arb. Units)');
    else
        hYLabel = ylabel('Counts per loop');
    end
    axHan = gca;
    set([hXLabel, hYLabel, axHan] , 'FontSize', FontSize);
%     set(axHan{uniqueExpTimeIndex},'YScale','log')
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickLength'  , [.02 .02] , ...        
      'XMinorTick'  , 'off'      , ...
      'XColor'      , [0 0 0], ...
      'YColor'      , [0 0 0], ...
      'YMinorTick'  , 'off'      , ...
      'YMinorGrid'  , 'off'      ,...
      'LineWidth'   , 0.5, ...
      'Clipping' , 'off' ...
            ); 

    
    TimeScale = 1E-6;
    legendstr = unique_ExpTime(plotvec);
    legendstr = round(legendstr/TimeScale);
    legendstr = legendstr(1:length(plotvec));
    legendstr = textscan(num2str(legendstr'),'%s');
    legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
    legarray = [];
    for dIndex = 1:length(DataPlotHan)
        legarray = cat(1, legarray, DataPlotHan{dIndex});
    end
    hLegend = legend(legarray, legendstr);
    set(get(hLegend,'title'),'string','Exposure Time (\mus)')


output_args = nan;
end