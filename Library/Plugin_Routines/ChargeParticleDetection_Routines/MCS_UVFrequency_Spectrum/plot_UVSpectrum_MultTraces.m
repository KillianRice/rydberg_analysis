function plot_UVSpectrum_MultTraces(analyVar, ParentCell, axistype, DensityIndex)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NumTraces = length(ParentCell);

[xData, yData, yData_error] = deal(cell(1,NumTraces));

for TraceIndex = 1:NumTraces
    %% Load Data
    xData{TraceIndex}       = ParentCell{TraceIndex}.xData;
    yData{TraceIndex}       = ParentCell{TraceIndex}.yData_Average{DensityIndex};
    yData_error{TraceIndex} = ParentCell{TraceIndex}.yData_Average_error{DensityIndex};
end

PlotStruct.xData        = xData;
PlotStruct.yData        = yData;
% PlotStruct.yData_error  = yData_error;

%% Plot    
PlotStruct.hXLabel      = 'UV Detuning (MHz)';
switch ParentCell{TraceIndex}.NormalizeFlag
    case 0
        PlotStruct.hYLabel = 'Signal (Counts)';
    case 1
        PlotStruct.hYLabel = 'Signal (Counts/Exposure)';
    case 2
        PlotStruct.hYLabel = 'Signal (Counts/\mus)';
    case 3
        PlotStruct.hYLabel = 'Signal (Norm. to Unity Area)';
end

PlotStruct.title        = analyVar.titleString;
PlotStruct.colors       = FC_ColorGradient(NumTraces);
PlotStruct.LineStyle    = '-';
PlotStruct.FCaxisfontsize     = analyVar.FCaxisfontsize;
PlotStruct.FCfigPos     = analyVar.FCfigPos;
PlotStruct.FCmarkerSize = analyVar.FCmarkerSize;
PlotStruct.FCaxesPos    = analyVar.FCaxesPos;

[TraceHan] = FC_Plotter(PlotStruct);

axHan = gca;
if axistype == 1
    set(axHan, 'YScale', 'Linear');
elseif axistype == 2
    set(axHan, 'YScale', 'Log');
end

% %% Make Legend
% [LegendString] = deal(cell(1,NumDensities));
% [MaxY, MinY] = deal(nan);
% for DensityIndex = 1:NumDensities
%     
%     MaxY = max(MaxY , max(yData{DensityIndex}));
%     MinY = min(MinY , min(yData{DensityIndex}));
% 
%     LegendString(DensityIndex) = {['\rho: ' mat2str(DensityGroupsToAverage{DensityIndex}(1)) ':' mat2str(DensityGroupsToAverage{DensityIndex}(end))]};    
% end 
% hLegend = legend([TraceHan{:}], LegendString);    
% set(hLegend,...
%     'FontSize', PlotStruct.FontSize,...
%     'Location', 'Best')   

% %% Make Frequency Bands    
%     axis tight    
%     if isempty(featurePos) ~= 1 && iscell(featurePos) == 1
%         for featureIndex = 1:length(featurePos)
%             featurePos1 = unique_Freq(featurePos{featureIndex}(1));
%             featurePos2 = unique_Freq(featurePos{featureIndex}(end));
%             Start   = min(featurePos1, featurePos2);
%             End     = max(featurePos1, featurePos2);
%             FreqBand = patch([Start End End Start] , [MinY*0.97 MinY*0.97 MaxY*1.03 MaxY*1.03], 'r');
%             set(FreqBand, ...
%                 'FaceColor', FrancyColors3(length(featurePos), featureIndex));
%         end 
%     end
%     
% set(axHan,'children',flipud(get(axHan,'children')))
hold off
