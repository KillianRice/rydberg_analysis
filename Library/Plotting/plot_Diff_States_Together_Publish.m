function [ output_args ] = plot_Diff_States_Together_Publish(analyVar, indivDataset)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

NumDensities = indivDataset{1}.numDensityGroups{1};
NumBatches = indivDataset{1}.CounterAtom;
NumStates = analyVar.numBasenamesAtom;

%% Choose sample data
% fixedField = analyVar.PeakBin;
fixedDelayTime = 1;
fixedDensity = 1;
fixedFrequency = 1;
DelayDim = 2;
DelayIndex = 1; 

[tickNums, tickNames] = deal(cell(1,3));
tickNums{1} = [160  179  199  224  251  284  321 365];
tickNums{2} = [152  169  189  211  237  267  302 343 391];
tickNums{3} = [148  164  183  204  229  258  291 329 374];

tickNames{1} = {'41', '40', '39', '38', '37', '36', '35', '34'};
tickNames{2} = {'41', '40', '39', '38', '37', '36', '35', '34' '33'};
tickNames{3} = {'41', '40', '39', '38', '37', '36', '35', '34', '33'};


%% Load Data
% [xData, ~, ~] = AxisTicksEngineeringForm(analyVar.ArrivalTime);
[xData, ~, ~] = AxisTicksEngineeringForm(analyVar.ElectricField);
% [xData, ~, ~] = AxisTicksEngineeringForm(analyVar.roiStart:analyVar.roiEnd);

xData = reshape(xData, [length(xData),1]);

[AbsNormAvgSpectra, AbsNormAvgSpectra_error] = deal([]);
for mbIndex = 1:NumStates
    AbsNormAvgSpectra = cat(DelayDim, AbsNormAvgSpectra, indivDataset{mbIndex}.AbsNormAvgSpectra(:,DelayIndex,:));
    AbsNormAvgSpectra_error = cat(DelayDim, AbsNormAvgSpectra_error, indivDataset{mbIndex}.AbsNormAvgSpectra_error(:,DelayIndex,:));
end

[yData, yData_error] = deal(cell(1, NumStates));
for mbIndex = 1:NumStates
    NumBatches   = indivDataset{mbIndex}.CounterAtom;
    yData{mbIndex} = AbsNormAvgSpectra(:,mbIndex,fixedDensity);
    yData_error{mbIndex} = AbsNormAvgSpectra_error(:,mbIndex,fixedDensity)/NumBatches^0.5;
end

%% Plot
% AvgSpectra2Color = flipud(RedToBlue(size(AbsNormAvgSpectra,legendVariable)));

figHan = figure('Units', 'pixels', ...
'Position', [100 100 315 200]);
set(figHan, 'Renderer', 'painters')

[DataPlotHan] = deal(cell(1, NumStates));
hold on

%     numRamps = analyVar.numLoopsSets(1);
%     exposuretime = analyVar.Exposure_Time(1)*1e6; %us
%     offset_scale = 1/numRamps/exposuretime;

% scaleData = [1/0.2883 1/0.1057 1/0.1208 1/0.07575];

for mbIndex = 1:NumStates
% DataPlotHan{mbIndex} = plot(...
%     xData,...
%     scaleData(mbIndex)*yData{mbIndex}...
%     );

DataPlotHan{mbIndex} = errorbar(...
    xData,...
    yData{mbIndex}, yData_error{mbIndex} ...
    );
removeErrorBarEnds(DataPlotHan{mbIndex})
end

axHan = gca;
%     if axisformat==2
%             set(axHan,'YScale','log')
%     end

% PlotVertStateLines

hold off

hLegend = legend('Atom','v = 0','v = 1', 'v = 2');

%% Make it pretty
for mbIndex = 1:NumStates

    set(DataPlotHan{mbIndex}, ...
        'Marker'          , analyVar.MARKERS2{mbIndex},...
        'LineStyle'       , '-' , ...
        'LineWidth'       , .5,...
        'Color'           , analyVar.COLORS(mbIndex,:),...
        'markerfacecolor' , analyVar.COLORS(mbIndex,:),...
        'MarkerSize'      , 3 ...
        ); 

end

x_string = 'Ionization Field (V cm^{-1})';
hXLabel = xlabel(x_string);
hYLabel = ylabel('Fractional Population');

% hText1   = text(0,0,sprintf('nS States'));
% set(hText1,...
%     'Units', 'Normalized',...
%     'Position', [.075, -.195-0.04],...
%     'FontSize', 12)
% 
% hText2   = text(0,0,sprintf('nP States'));
% set(hText2,...
%     'Units', 'Normalized',...
%     'Position', [.075, -.275-0.04],...
%     'FontSize', 12)
% 
% hText3   = text(0,0,sprintf('nD States'));
% set(hText3,...
%     'Units', 'Normalized',...
%     'Position', [.075, -.360-0.04],...
%     'FontSize', 12)

set([hXLabel, hYLabel, axHan] , 'FontSize', 8);

% set(hLegend,...
%     'FontSize', 8,...
%     'Units', 'Normalized',...
%     'Position', [.58 .55 .2 .175])

    set(hLegend,...
    'FontSize', 8,...
    'Units', 'Pixels',...
    'Box', 'off',...
    'Position', [60 120 30 60])

%   'XTick'       , 0:100:500 , ...
%   'XLim'        , [0 450]   ,...
set(axHan, ...
  'Box'         , 'on'       ,...
  'TickLength'  , [.02 .02]  ,...
  'XMinorTick'  , 'off'      ,...
  'XColor'      , [0 0 0]    ,...
  'XLim'        , [150 350]  ,...
  'YColor'      , [0 0 0]    ,...
  'YMinorTick'  , 'off'      ,...
  'YMinorGrid'  , 'off'      ,...
  'YLim'        , [0 0.301]    ,...
  'LineWidth'   , 0.5         );

% StateAxis

% set(gcf, 'PaperPositionMode', 'auto');

end

