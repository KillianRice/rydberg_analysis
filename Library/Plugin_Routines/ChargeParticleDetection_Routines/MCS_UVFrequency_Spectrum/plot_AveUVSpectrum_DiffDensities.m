function plot_AveUVSpectrum_DiffDensities(analyVar, indivDataset, unique_Freq, unique_Density, DensityGroupsToAverage, AveUVSpectrum, AveUVSpectrum_error, stats_counter, featurePos, linear_log, NormalizeFlag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% FontSize = analyVar.FCaxisfontsize;

%% Load Data
xData = unique_Freq;
%     xData = 1:length(unique_Freq);
yData = AveUVSpectrum; 
yData_error = AveUVSpectrum_error;
NumDensities = length(yData); 
    
%% Plot    

PlotStruct.xData = xData;
PlotStruct.yData = yData;
% PlotStruct_AtomNum.yData_error = yData_error;
PlotStruct.hXLabel = 'UV Detuning (MHz)';
switch NormalizeFlag
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
PlotStruct.colors       = FC_ColorGradient(NumDensities);
PlotStruct.LineStyle    = '-';
PlotStruct.FCaxisfontsize     = analyVar.FCaxisfontsize;
PlotStruct.FCfigPos     = analyVar.FCfigPos;
PlotStruct.FCmarkerSize = analyVar.FCmarkerSize;
PlotStruct.FCaxesPos    = analyVar.FCaxesPos;

TraceHan = FC_Plotter(PlotStruct);

axHan = gca;
if linear_log == 1
    set(axHan, 'YScale', 'Linear');
elseif linear_log == 2
    set(axHan, 'YScale', 'Log');
end

%% Make Legend
[LegendString] = deal(cell(1,NumDensities));
[MaxY, MinY] = deal(nan);
for DensityIndex = 1:NumDensities
    
    MaxY = max(MaxY , max(yData{DensityIndex}));
    MinY = min(MinY , min(yData{DensityIndex}));

    LegendString(DensityIndex) = {['\rho: ' mat2str(DensityGroupsToAverage{DensityIndex}(1)) ':' mat2str(DensityGroupsToAverage{DensityIndex}(end))]};    
end 
hLegend = legend([TraceHan{:}], LegendString);    
set(hLegend,...
    'FontSize', PlotStruct.FCaxisfontsize,...
    'Location', 'Best')   

%% Make Frequency Bands    
    axis tight    
    if isempty(featurePos) ~= 1 && iscell(featurePos) == 1
        for featureIndex = 1:length(featurePos)
            featurePos1 = unique_Freq(featurePos{featureIndex}(1));
            featurePos2 = unique_Freq(featurePos{featureIndex}(end));
            Start   = min(featurePos1, featurePos2);
            End     = max(featurePos1, featurePos2);
            FreqBand = patch([Start End End Start] , [MinY*0.97 MinY*0.97 MaxY*1.03 MaxY*1.03], 'r');
            set(FreqBand, ...
                'FaceColor', FrancyColors3(length(featurePos), featureIndex));
        end 
    end
    
set(axHan,'children',flipud(get(axHan,'children')))
hold off
end