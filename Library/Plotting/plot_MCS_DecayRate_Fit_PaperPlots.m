function [ output_args ] = plot_MCS_DecayRate_Fit_PaperPlots( analyVar, indivDataset )

NumBatches  = indivDataset{1}.CounterAtom;

Functional_Form = @(coeffs,x) coeffs(1)*x+coeffs(2);

scaleY = 1E-3;
scaleX = 1E-19;

synthFreq = indivDataset{1}.synthFreq;
synthFreq = cat(2,synthFreq,synthFreq);
synthFreq = synthFreq';
synthFreq = synthFreq(:);

NumSets         = analyVar.numBasenamesAtom;

[PeakslopeArray, PeakyintArray, SumslopeArray, SumyintArray] = deal(nan(NumSets,2));

for Peak_or_Sum = 1
    figure('Units', 'pixels', ...
    'Position', [100 100 315 205]);
    hold on
    DataPlotHan = cell(1,NumSets);
for mbIndex = 1:NumSets
x_data      = indivDataset{mbIndex}.densityvector;
        switch Peak_or_Sum
            case 1
                y_data      = indivDataset{mbIndex}.Peak_DecayRate(:,1);
                y_error     = indivDataset{mbIndex}.Peak_DecayRate(:,2);
                if mbIndex~=4
                    y_error = y_error*2;
                end
                slope       = indivDataset{mbIndex}.Avg_Slope_Peak(1);
                y_intercept = indivDataset{mbIndex}.Avg_y_intercept_Peak(1);
                PeakslopeArray(mbIndex,:) = indivDataset{mbIndex}.Avg_Slope_Peak;
                PeakyintArray(mbIndex,:) = indivDataset{mbIndex}.Avg_y_intercept_Peak;
            case 2
                y_data      = indivDataset{mbIndex}.Sum_DecayRate(:,1);
                y_error     = indivDataset{mbIndex}.Sum_DecayRate(:,2);
                slope       = indivDataset{mbIndex}.Avg_Slope_Sum(1);
                y_intercept = indivDataset{mbIndex}.Avg_y_intercept_Sum(1);        
                SumslopeArray(mbIndex,:) = indivDataset{mbIndex}.Avg_Slope_Sum;
                SumyintArray(mbIndex,:) = indivDataset{mbIndex}.Avg_y_intercept_Sum;
        end
         
        DataPlotHan{mbIndex} = errorbar(...
            x_data*scaleX,...
            y_data*scaleY,...
            y_error*scaleY);
        removeErrorBarEnds(DataPlotHan{mbIndex})
%         y_data2 = y_data.^-1;
%         y_error = y_error.*y_data.^-2;
%         
%         [y_data2 y_error]
        
        set(DataPlotHan{mbIndex}   , ...
          'Marker'          , analyVar.MARKERS2{mbIndex},...
          'LineStyle'       , 'none' , ...   
          'LineWidth'       , 0.5,...
          'Color'           , analyVar.COLORS(mbIndex,:),...
          'markerfacecolor' , analyVar.COLORS(mbIndex,:),...
          'MarkerSize'      , 3 ...
          );       
        
%       if Peak_or_Sum == 1
%           set(DataPlotHan{mbIndex}, 'markerfacecolor' , analyVar.COLORS(mbIndex,:))
%       end
      
        fitIndVar = linspace(0, 5e19,1e4)';
        
        switch Peak_or_Sum
            case 1
            fitdataHan = ...
                plot(...
                fitIndVar*scaleX,...
                scaleY*Functional_Form(...
                    [slope, y_intercept], fitIndVar),...
                '-',...
                'Color',analyVar.COLORS(mbIndex,:),...
                'LineWidth'       , 0.5 ...
                );
            case 2
            fitdataHan = ...
                plot(...
                fitIndVar*scaleX,...
                scaleY*Functional_Form(...
                    [slope, y_intercept], fitIndVar),...
                '--',...
                'Color',analyVar.COLORS(mbIndex,:),...
                'LineWidth'       , 0.5 ...
                );
        end
        hXLabel = xlabel('Average Density (10^{13} cm^{-3})','FontSize',analyVar.axisfontsize);
        hYLabel = ylabel('Decay Rate (10^{3} s^{-1})','FontSize',analyVar.axisfontsize);

end

    axHan = gca;
    set([hXLabel, hYLabel, axHan] , 'FontSize', 8);
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickLength'  , [.02 .02] , ...        
      'XMinorTick'  , 'off'      , ...
      'XColor'      , [0 0 0], ...
      'XLim'        , [0 2],...
      'YColor'      , [0 0 0], ...
      'YMinorTick'  , 'on'      , ...
      'YMinorGrid'  , 'off'      ,...
      'YLim'        , [45 80],...
      'YMinorTick'  , 'off'      , ...
      'LineWidth'   , 0.5, ...
      'Clipping' , 'off' ...
            ); 
    hold off

    plotObjHan = [DataPlotHan{1} DataPlotHan{2} DataPlotHan{3} DataPlotHan{4}];
    plotObjLabel = {'Atom', 'v = 0', 'v = 1', 'v = 2'};
    
    hLegend = legend(plotObjHan,plotObjLabel);

    set(hLegend,...
    'FontSize', 8,...
    'Units', 'Pixels',...
    'Box', 'off',...
    'Position', [50 128 30 60])
    
end
PeakslopeArray
PeakyintArray
SumslopeArray
SumyintArray

%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%

scaleX = 1E16;

figure('Units', 'pixels', ...
'Position', [100 100 315 205]);
hold on



for Peak_or_Sum = 1:2
    plotHan = cell(1,NumSets);
    [x_data, x_error, y_data, y_error] = deal([]);
for mbIndex = 1:NumSets

        switch Peak_or_Sum
            case 1
                x_data      = indivDataset{mbIndex}.Avg_Slope_Peak(1);
                x_error     = indivDataset{mbIndex}.Avg_Slope_Peak(2);
                y_data      = indivDataset{mbIndex}.Avg_y_intercept_Peak(1);
                y_error     = indivDataset{mbIndex}.Avg_y_intercept_Peak(2);
        case 2
                x_data      = indivDataset{mbIndex}.Avg_Slope_Sum(1);
                x_error     = indivDataset{mbIndex}.Avg_Slope_Sum(2);
                y_data      = indivDataset{mbIndex}.Avg_y_intercept_Sum(1);
                y_error     = indivDataset{mbIndex}.Avg_y_intercept_Sum(2);  
        end
        
        x_data = x_data*scaleX;
        x_error = x_error*scaleX;
        y_data = y_data*scaleY;
        y_error = y_error*scaleY;
        
        plotHan{mbIndex} = ploterr(...
            x_data,...
            y_data,...
            x_error,...
            y_error,...
            analyVar.MARKERS2{mbIndex});
        set(plotHan{mbIndex}(1),'Color',analyVar.COLORS(mbIndex,:))
        if Peak_or_Sum == 1
          set(plotHan{mbIndex}(1), 'markerfacecolor' , analyVar.COLORS(mbIndex,:))
        end
        set(plotHan{mbIndex}(2),'Color',analyVar.COLORS(mbIndex,:))
        if Peak_or_Sum == 1
          set(plotHan{mbIndex}(2), 'markerfacecolor' , analyVar.COLORS(mbIndex,:))
        end        
        set(plotHan{mbIndex}(3),'Color',analyVar.COLORS(mbIndex,:))
        if Peak_or_Sum == 1
          set(plotHan{mbIndex}(3), 'markerfacecolor' , analyVar.COLORS(mbIndex,:))
        end        
        
        fitIndVar = linspace(0,max(x_data),1e4)';
        
        hXLabel = xlabel('Slope (10^{-10} cm^3 s^{-1})','FontSize',analyVar.axisfontsize);
        hYLabel = ylabel('Natural Decay Rate (s^{-1})','FontSize',analyVar.axisfontsize);

end
end
    grid on
    axis tight
    axHan = gca;
    set([hXLabel, hYLabel, axHan] , 'FontSize', 8);
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'on'      , ...
      'YMinorTick'  , 'on'      , ...
      'YMinorGrid'  , 'off'     ,...
      'XColor'      , [0 0 0], ...
      'YColor'      , [0 0 0], ...
      'LineWidth'   , 1         );
    hold off
    
%     hLegend = legend([plotHan{1}(1) plotHan{2}(1) plotHan{3}(1) plotHan{4}(1) RbplotHan{1}(1) RbplotHan{2}(1) RbplotHan{3}(1)],...
%         'Atomic State', 'Mol. Ground', 'Mol. 1st Ex.', 'Mol. 2nd Ex.', 'Rb 35s Atomic', 'Rb 35s Mol. Ground', 'Rb 35s Mol. 1st Ex.');
%     set(hLegend,...
%     'FontSize', 12,...
%     'Units', 'Normalized',...
%     'Position', [.25 .3 .2 .175])
    
end

