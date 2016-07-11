function [ output_args ] = plot_Diff_States_Together3(analyVar, indivDataset)
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
%         [xData, ~, ~] = AxisTicksEngineeringForm(analyVar.roiStart:analyVar.roiEnd);

xData = reshape(xData, [length(xData),1]);

[AbsNormAvgSpectra, AbsNormAvgSpectra_error] = deal([]);
for mbIndex = 1:NumStates
    AbsNormAvgSpectra = cat(DelayDim, AbsNormAvgSpectra, indivDataset{mbIndex}.AbsNormAvgSpectra(:,DelayIndex,:));
    AbsNormAvgSpectra_error = cat(DelayDim, AbsNormAvgSpectra_error, indivDataset{mbIndex}.AbsNormAvgSpectra_error(:,DelayIndex,:));
end

yData = cell(1, NumStates);
for mbIndex = 1:NumStates
    yData{mbIndex} = AbsNormAvgSpectra(:,mbIndex,fixedDensity);
    yData_error{mbIndex} = AbsNormAvgSpectra_error(:,mbIndex,fixedDensity);
end

%% Plot
figHan = cell(1,2);
for axisformat = 1:2
% AvgSpectra2Color = flipud(RedToBlue(size(AbsNormAvgSpectra,legendVariable)));

figHan{axisformat} = figure('Units', 'pixels', ...
'Position', [100 100 500 500]);

[DataPlotHan] = deal(cell(1, NumStates));
hold on
for mbIndex = 1:NumStates
DataPlotHan{mbIndex} = plot(...
    xData,...
    yData{mbIndex}...
    );

    axHan = gca;

    if axisformat==2
            set(axHan,'YScale','log')
    end

end

PlotVertStateLines

hold off

hLegend = legend('Atomic','Mol. Ground','Mol. 1st Excited', 'Mol. 2nd Excited');

%% Make it pretty
for mbIndex = 1:NumStates
% set(DataPlotHan{mbIndex}   , ...
%   'Marker', analyVar.MARKERS2{mbIndex},...
%   'LineStyle'       , 'none' , ...
%   'Color'           , 0.5*analyVar.COLORS(mbIndex,:),...
%   'markerfacecolor' , analyVar.COLORS(mbIndex,:),...
%   'MarkerSize'      , 3 ...
%   );

set(DataPlotHan{mbIndex}   , ...
  'Marker'          , analyVar.MARKERS2{mbIndex},...
  'LineStyle'       , '-' , ...
  'Color'           , analyVar.COLORS(mbIndex+1,:),...
  'markerfacecolor' , analyVar.COLORS(mbIndex+1,:),...
  'MarkerSize'      , 4 ...
  );

end

x_string = 'Ionization Field (V/cm)';
hXLabel = xlabel(x_string);
hYLabel = ylabel('Fractional Population');
grid on

hText1   = text(0,0,sprintf('nS States'));
set(hText1,...
    'Units', 'Normalized',...
    'Position', [.075, -.195-0.04],...
    'FontSize', 12)

hText2   = text(0,0,sprintf('nP States'));
set(hText2,...
    'Units', 'Normalized',...
    'Position', [.075, -.275-0.04],...
    'FontSize', 12)

hText3   = text(0,0,sprintf('nD States'));
set(hText3,...
    'Units', 'Normalized',...
    'Position', [.075, -.360-0.04],...
    'FontSize', 12)

set([hXLabel, hYLabel, axHan] , 'FontSize', 14);

set(hLegend,...
    'FontSize', 12,...
    'Units', 'Normalized',...
    'Position', [.25 .71 .2 .175])

%   'XTick'       , 0:100:500 , ...
%   'XLim'        , [0 450]   ,...
set(axHan, ...
  'Position'    , [.15 .3 .75 .6],...
  'Box'         , 'on'      , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YMinorGrid'  , 'off'     ,...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );

StateAxis

set(gcf, 'PaperPositionMode', 'auto');
end
end

