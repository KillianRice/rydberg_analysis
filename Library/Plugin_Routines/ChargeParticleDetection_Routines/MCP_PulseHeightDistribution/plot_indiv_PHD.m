function [ output_args ] = plot_indiv_PHD(analyVar,indivDataset)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NumRepetitions = analyVar.numBasenamesAtom;
[xData, yData, DataPlotHan] = deal(cell(1,NumRepetitions));
%% Load Data
for mbIndex = 1:NumRepetitions         
%     xData{mbIndex} = indivDataset{mbIndex}.imagevcoAtom;
    [xData{mbIndex}, ~] = EngineeringForm(indivDataset{mbIndex}.imagevcoAtom);
    yData{mbIndex} = indivDataset{mbIndex}.SinglePHD;              
end
%% Plot    
figure('Units', 'pixels', ...
    'Position', [100 100 315 200]);

hold on
for mbIndex = 1:NumRepetitions 

    DataPlotHan{mbIndex} = plot(xData{mbIndex}, yData{mbIndex});
    set(DataPlotHan{mbIndex}   , ...
        'Marker'          , analyVar.MARKERS2{mbIndex},...
        'LineStyle'       , '-' , ...
        'Color'           , analyVar.COLORS(mbIndex,:),...
        'markerfacecolor' , analyVar.COLORS(mbIndex,:),...
        'MarkerSize'      , 3 ...
        );
end 
        
axHan = gca;

hold off
        
%% Make it Pretty    

    grid on
    hXLabel = xlabel('Discriminator Voltage (mV)');
    hYLabel = ylabel('Signal (Arb. Units)');

    set([hXLabel, hYLabel, axHan] , 'FontSize', 8);
    
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickLength'  , [.02 .02] , ...        
      'XMinorTick'  , 'on'      , ...
      'XColor'      , [0 0 0]   , ...
      'XScale'      , 'Log'     , ...
      'YMinorTick'  , 'on'      , ...
      'YMinorGrid'  , 'on'      ,...
      'YColor'      , [0 0 0]   , ...
      'YScale'      , 'Log'     , ...
      'LineWidth'   , 0.5         ...
            );    
       
    output_args = nan;
end


