close all;
data = dlmread('n38ThermalSpectrum_perus_10usExposure_2015_10_31.csv');

color = nan(5,3);
pos{1}      = 1:160;
color(1,:)    = [128 0 255]/255;
factor(1)       = 1;
pos{2}      = 1:45;
color(2,:)    = [255 201 14]/255;
factor(2)       = 1;
pos{3}      = 57:66;
color(3,:)    = [0 0 255]/255;
factor(3)       = 5;
pos{4}      = 71:80;
color(4,:)    = [0 139 0]/255;
factor(4)       = 5;
pos{5}      = 135:146;
color(5,:)    = [255 0 0]/255;
factor(5)       = 5;
% pos{6}      = 179:335;
% color(6,:)    = [255 127 39]/255;

[xData, yData] = deal(cell(1,length(pos)));
for kk = 1:length(pos)
    xData{kk} = data(pos{kk}, 1);
    yData{kk} = data(pos{kk}, 2)*factor(kk);
    if kk > 1
        yData{1}(pos{kk})  = nan;
    end
end

PlotStruct.xData        = xData;
PlotStruct.yData        = yData;
% PlotStruct.yData_error  = yData_error;

%% Plot    
PlotStruct.hXLabel      = 'UV Detuning (MHz)';
PlotStruct.hYLabel      = 'Signal (Counts/\mus)';

PlotStruct.title        = analyVar.titleString;
% PlotStruct.colors       = FC_ColorGradient(1);
PlotStruct.colors       = color;
PlotStruct.LineStyle    = '-';
PlotStruct.FCaxisfontsize     = analyVar.FCaxisfontsize;
PlotStruct.FCfigPos     = analyVar.FCfigPos;
PlotStruct.FCmarkerSize = analyVar.FCmarkerSize;
PlotStruct.FCaxesPos    = analyVar.FCaxesPos;

[TraceHan] = FC_Plotter(PlotStruct);

boxdim = [0.095 0.07];
str = cell(1,4);

boxlocation{1} = [0.61 0.313];
str{1} = '\nu = 2';

boxlocation{2} = [0.526 0.449];
str{2} = '\nu = 1';

boxlocation{3} = [0.193 0.521];
str{3} = '\nu = 0';

boxlocation{4} = [0.755 0.809];
str{4} = 'Atomic';

for qq = 1:length(boxlocation)
    annotation('textbox', [boxlocation{qq} boxdim], 'String', str{qq}, 'LineStyle', 'none');
end

