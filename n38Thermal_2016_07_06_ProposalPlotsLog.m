close all;
data = dlmread('n38ThermalSpectrum_perus_10usExposure_2015_10_31.csv');

pos{1}      = 1:425;
color(1,:)    = [128 0 255]/255; %background
pos{2}      = 1:35;
color(2,:)    = [255 201 14]/255; %atomic
pos{3}      = 57:66;
color(3,:)    = [0 0 255]/255; % D3
pos{4}      = 71:80;
color(4,:)    = [0 139 0]/255; %D2
pos{5}      = 125:148;
color(5,:)    = [255 0 0]/255; %D0
% pos{6}      = 425:425;
% color(6,:)    = [255 127 39]/255; %other

% %Trimer
% pos{6}      = 175:191;
% color(6,:)    = [0 0 255]/255; % D3
% pos{7}      = 192:206;
% color(7,:)    = [0 139 0]/255; %D2
% pos{8}      = 251:274;
% color(8,:)    = [255 0 0]/255; %D0
% 
% %Tetramers
% pos{9}      = 297:315;
% color(9,:)    = [0 0 255]/255; % D3
% pos{10}      = 316:331;
% color(10,:)    = [0 139 0]/255; %D2
% pos{11}      = 379:395;
% color(11,:)    = [255 0 0]/255; %D0

%Trimer
pos{6}      = 251:274;
color(6,:)    = [255 0 0]/255; %D0

%Tetramers
pos{7}      = 379:395;
color(7,:)    = [255 0 0]/255; %D0

[xData, yData] = deal(cell(1,length(pos)));
for kk = 1:length(pos)
    xData{kk} = data(pos{kk}, 1);
%     xData{kk} = pos{kk};
    yData{kk} = data(pos{kk}, 2);
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

set(gca, 'YScale', 'Log');

boxdim = [0.095 0.07];
str = cell(1,10);

boxlocation{1} = [0.831 0.82];
str{1} = '(0000)';

boxlocation{2} = [0.816 0.673];
str{2} = '(0001)';

boxlocation{3} = [0.721 0.649];
str{3} = '(0010)';

boxlocation{4} = [0.591 0.716];
str{4} = '(1000)';

boxlocation{5} = [0.584 0.534];
str{5} = '(1001)';

boxlocation{6} = [0.479 0.518];
str{6} = '(1010)';

boxlocation{7} = [0.355 0.516];
str{7} = '(2000)';

boxlocation{8} = [0.34 0.334];
str{8} = '(2001)';

boxlocation{9} = [0.235 0.286];
str{9} = '(2010)';

boxlocation{10} = [0.14 0.3];
str{10} = '(3000)';

for qq = 1:length(boxlocation)
    annotation('textbox', [boxlocation{qq} boxdim], 'String', str{qq}, 'LineStyle', 'none');
end










