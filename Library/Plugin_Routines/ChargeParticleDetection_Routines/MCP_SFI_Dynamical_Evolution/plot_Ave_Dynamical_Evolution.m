function [ output_args ] = plot_Ave_Dynamical_Evolution(analyVar, indivDataset, unique_ExpTime, Ave_SFI, Ave_SFI_error, NormalizeFlag, avgDataset)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Load Data
[unique_ExpTime,~] = EngineeringForm(unique_ExpTime);
%% xData
EField = analyVar.ElectricField;
NumEField = length(analyVar.ElectricField);
%% yData and yData_error
NumExpTime = length(unique_ExpTime);
[yData, yData_error] = deal(cell(1,NumEField));
for EFieldIndex = 1:NumEField
    [yData{EFieldIndex}, yData_error{EFieldIndex}] = deal(nan(1,NumExpTime));
    for ExpTimeIndex = 1:NumExpTime
        yData{EFieldIndex}(ExpTimeIndex) = Ave_SFI{ExpTimeIndex}(EFieldIndex);
        yData_error{EFieldIndex}(ExpTimeIndex) = Ave_SFI_error{ExpTimeIndex}(EFieldIndex);
    end
end
        
%% Plot    
FontSize = 8;
plotvec = [5,13,17,23,26,30];
[DataPlotHan] = deal(cell(1,NumEField));
figHan = figure('Units', 'pixels', ...
'Position', [100 100 315 200]);
set(figHan, 'Renderer', 'painters')
hold on

colorArray = copper(length(plotvec));
MaxSig = nan(1,NumEField);
for Index = 1:length(plotvec) %1:NumEField
    EFieldIndex = plotvec(Index);
    DataPlotHan{EFieldIndex} = errorbar(unique_ExpTime, yData{EFieldIndex},  yData_error{EFieldIndex});
    removeErrorBarEnds(DataPlotHan{EFieldIndex})
    MaxSig(EFieldIndex) = max(yData{EFieldIndex});
    set(DataPlotHan{EFieldIndex}, ...
        'LineStyle'       , '-' , ...
        'LineWidth'       , 0.5,...
        'Color'           , colorArray(Index,:),...
        'marker'          , 'o',...
        'markersize'      , 4,...
        'markerfacecolor' , colorArray(Index,:)...
        ); 
    
end
AveAtomNum = avgDataset{1}.avgTotNum;
% [AveAtomNum, ~] = EngineeringForm(AveAtomNum);
AveAtomNum = AveAtomNum - min(AveAtomNum); 
ScaleAtomNum = max(MaxSig)/max(AveAtomNum);
AveAtomNum = AveAtomNum*ScaleAtomNum;
plot (unique_ExpTime, AveAtomNum, 'marker', 'o')
    hold off
    axis tight
    hXLabel = xlabel('Exposure Time (\mus)');
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

    
    TimeScale = 1;
    legendstr = EField(plotvec);
    legendstr = round(legendstr/TimeScale);
    legendstr = legendstr(1:length(plotvec));
    legendstr = textscan(num2str(legendstr'),'%s');
    legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
    legarray = [];
    for dIndex = 1:length(DataPlotHan)
        legarray = cat(1, legarray, DataPlotHan{dIndex});
    end
    hLegend = legend(legarray, legendstr);
    set(get(hLegend,'title'),'string','E Field (V/cm)')


output_args = nan;
end