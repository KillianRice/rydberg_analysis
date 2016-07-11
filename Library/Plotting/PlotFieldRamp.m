function [ output_args ] = PlotFieldRamp(analyVar)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
xData = analyVar.ArrivalTime/1e-6;
Conversion = analyVar.Potential2Field*analyVar.FieldCalibration;
yData2 = [min(analyVar.ElectricField) max(analyVar.ElectricField)];% %V, potential difference
yData1 = analyVar.ElectricField; %electric field

figHan = figure('Units', 'pixels', ...
'Position', [100 100 400 300]);
plot(xData,yData1,'LineWidth', 2);


box on
grid on
xlabel('Ramp Time (us)')
ylabel('Electric Field V/cm')
set(gca,'Box','off',...
    'XColor', [.3, .3, .3],...
    'YColor', [.3, .3, .3]);   % Turn off the box surrounding the whole axes
axesPosition = get(gca,'Position');          % Get the current axes position
axesLimits = get(gca, 'YLim');
axesLimits = axesLimits/Conversion/1e3;
hNewAxes = axes('Position',axesPosition,...  % Place a new axes on top...
                'Color','none',...           %   ... with no background color
                'YLim',axesLimits,...            %   ... and a different scale
                'YColor', [.3, .3, .3],... 
                'YAxisLocation','right',...  %   ... located on the right
                'XTick',[],...              %   ... with no x tick marks
                'XColor', [.3, .3, .3],... 
                'Box','off');                %   ... and no surrounding box
ylabel(hNewAxes,'Potential Difference (kV)');  % Add a label to the right y axis

Saturation = Conversion*analyVar.MaxFieldRampVoltage; 
tau = analyVar.FieldRampTimeConstant; 
toff = analyVar.FieldRampTimeOffset; 

string = [{'$$F = F_0 \left [ 1-\exp\left ( -\frac{t-t_0}{\tau} \right ) \right ]\Theta (t-t_0) $$'},...
    {['$$F_0 = ~$$' mat2str(round(Saturation)) ' V/cm']},...
    {['$$~\tau = ~$$' mat2str(round(100*tau/1e-6)/100) 'us']}...
    {['$$~t_0 = ~$$' mat2str(round(100*toff/1e-6)/100) 'us']}...
    ];

hText1   = text(0,0, string ,'Interpreter','latex');
set(hText1,...
    'Units', 'Normalized',...
    'BackgroundColor', 'white',...
    'EdgeColor', 'black',...
    'Position', [.22, .25],...
    'FontSize', 10)

%     mTextBox = uicontrol('style','text');
% 
%     set(mTextBox,'String',string)
%     set(mTextBox,'Units','characters')
% %     set(mTextBox,'Units','Normalized')
%     set(mTextBox,'Position',[35 10 30 4.5])
    box on
end