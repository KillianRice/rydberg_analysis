function [plotHan] = FC_Plotter(PlotStruct)

xData = PlotStruct.xData;
yData = PlotStruct.yData;
if isfield(PlotStruct, 'yData_error') == 1
    yData_error = PlotStruct.yData_error;
end
xLabelString = PlotStruct.hXLabel;
yLabelString = PlotStruct.hYLabel;

if isfield(PlotStruct, 'LineStyle') == 1
    linsty = PlotStruct.LineStyle;
else
    linsty = 'none';
end
if isfield(PlotStruct, 'colors') == 1
    Colors = PlotStruct.colors;
else
    Colors = FrancyColors(length(yData));
end
if isfield(PlotStruct, 'colors2') == 1
    Colors2 = PlotStruct.colors2;
else
    Colors2 = Colors;
end

if iscell(xData) ~= 1
    xData0 = cell(1,length(yData));
    for CellIndex = 1:length(yData)
        xData0{CellIndex} = xData;
    end
    xData = xData0;
end

FontSize = PlotStruct.FCaxisfontsize;

figure(...
    'Color',[1 1 1],...
    'Units', 'pixels',...
    'Position', PlotStruct.FCfigPos)
if isfield(PlotStruct, 'title') == 1
    title(PlotStruct.title, 'FontSize' , FontSize) 
end

hold on
plotHan = cell(1,length(yData));
for CellIndex = 1:length(yData)
    if isfield(PlotStruct, 'yData_error') == 1
        plotHan{CellIndex}   = errorbar(xData{CellIndex}, yData{CellIndex}, yData_error{CellIndex});
        removeErrorBarEnds(plotHan{CellIndex});
    else
        plotHan{CellIndex}   = plot(xData{CellIndex}, yData{CellIndex});
    end    
    

    set(plotHan{CellIndex}, ...
        'LineStyle'         , linsty,...
        'Marker'            , 'o'       ,...
        'MarkerSize'        , PlotStruct.FCmarkerSize, ...
        'MarkerEdgeColor'   , Colors(CellIndex, :),...
        'Color'             , Colors(CellIndex, :),...
        'MarkerFaceColor'   , Colors2(CellIndex, :)...
    );

end

    axis tight
    set(gca,...
        'Box'           , 'on'      , ...
        'TickLength'    , [.02 .02] , ...        
        'XMinorTick'    , 'off'      , ...
        'XColor'        , [0 0 0], ...
        'YColor'        , [0 0 0], ...
        'YMinorTick'    , 'off'      , ...
        'YMinorGrid'    , 'off'      ,...
        'LineWidth'     , 0.5, ... 
        'FontSize'      , FontSize);
    set(gca,...
        'ActivePositionProperty', 'Position',...
        'Units'         , 'pixels',...
        'Position'      , PlotStruct.FCaxesPos)  
    
    hXLabel = xlabel(xLabelString);    
    hYLabel = ylabel(yLabelString);    
    set([hXLabel, hYLabel] , 'FontSize', PlotStruct.FCaxisfontsize);    
 
end