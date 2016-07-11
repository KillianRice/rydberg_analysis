function  output = PlotDiffStates(MultiStateCell)

% Frequency = 2; %choose a batch to sample
NumDelays = 7;

fields = [
   -68.2176e+000
   -92.5141e+000
  -115.2637e+000
  -136.5647e+000
  -156.5094e+000
  -175.1843e+000
  -192.6700e+000
  -209.0424e+000
  -224.3723e+000
  -238.7262e+000
  -252.1661e+000
  -264.7503e+000
  -276.5332e+000
  -287.5658e+000
  -297.8960e+000
  -307.5685e+000
  -316.6251e+000
  -325.1050e+000
  -333.0450e+000
  -340.4794e+000
  -347.4405e+000
  -353.9583e+000
  -360.0612e+000
  -365.7754e+000
  -371.1259e+000
  -376.1356e+000
  -380.8264e+000
  -385.2185e+000];

[xData, ~, ~] = AxisTicksEngineeringForm(abs(fields));
%  xData = reshape(xData, [length(xData),1]);

AvgSpectra2Color = jet(length(MultiStateCell));
        
for DelayIndex = 1:NumDelays
    
    figHan = figure();
    axHan = cell(1,4);
    set(figHan, 'Color', [.5,.5,.5]);
    set(figHan, 'Position', [100, 100, 750, 750]);
    
    for plotType = 1:4
%     hold on
    subplot(2,2,plotType)
    hold on
    for DataSetIndex = 1:length(MultiStateCell)
%         NumDensities    = MultiStateCell{StateIndex}{1}.numDensityGroups{1};
%         NumBatches      = MultiStateCell{StateIndex}{1}.CounterAtom;
%         NumDelays       = length(MultiStateCell{StateIndex}{1}.timedelayOrderMatrix);
        yData = MultiStateCell{DataSetIndex}{plotType,DelayIndex};

        plot(xData,yData,...
            '-o',...
            'MarkerSize',5,...
            'color',AvgSpectra2Color(DataSetIndex,:)...
            )
        
        axHan{plotType} = gca; % current axes
            set(axHan{plotType},'Color',[.5,.5,.5]);
            set(axHan{plotType},'FontSize',10);
            set(axHan{plotType},'Units','normal');
            set(axHan{plotType},'TickDir','out');

            set(axHan{plotType},'TickLength',[.01 0.025]);
            set(axHan{plotType},'xlim',[min(xData) max(xData)])
            
            if plotType == 1 || plotType == 3
                ylabel('Frac. Pop Over All States') 
            else
                ylabel('Frac. Pop Over Rydberg States') 
            end
            
        xlabel('Ionization Field (V/cm)')        
        
    end
    hold off
    grid on
 
    end
    legHandle = legend([{'Atomic'},{'Ground'},{'1st Excited'},{'2nd Excited'}]);
    set(get(legHandle,'title'),'string','State')    
end



end