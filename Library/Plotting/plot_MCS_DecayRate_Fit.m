function [ output_args ] = plot_MCS_DecayRate_Fit( analyVar, indivDataset )

NumBatches  = indivDataset{1}.CounterAtom;

Functional_Form = @(coeffs,x) coeffs(1)*x+coeffs(2);

scaleY = 1E-3;
scaleX = 1E-19;


synthFreq = indivDataset{1}.synthFreq;
synthFreq = cat(2,synthFreq,synthFreq);
synthFreq = synthFreq';
synthFreq = synthFreq(:);

NumSets         = analyVar.numBasenamesAtom;

figure('Units', 'pixels', ...
'Position', [100 100 315 205]);
hold on

for Peak_or_Sum = 2
    DataPlotHan = cell(1,NumSets);
for mbIndex = 1:NumSets
x_data      = indivDataset{mbIndex}.densityvector;
        switch Peak_or_Sum
            case 1
                y_data      = indivDataset{mbIndex}.Peak_DecayRate(:,1);
                y_error     = indivDataset{mbIndex}.Peak_DecayRate(:,2);
                slope       = indivDataset{mbIndex}.Avg_Slope_Peak(1);
                y_intercept = indivDataset{mbIndex}.Avg_y_intercept_Peak(1);

            case 2
                y_data      = indivDataset{mbIndex}.Sum_DecayRate(:,1);
                y_error     = indivDataset{mbIndex}.Sum_DecayRate(:,2);
                slope       = indivDataset{mbIndex}.Avg_Slope_Sum(1);
                y_intercept = indivDataset{mbIndex}.Avg_y_intercept_Sum(1);        

        end
        
        DataPlotHan{mbIndex} = errorbar(...
            x_data*scaleX,...
            y_data*scaleY,...
            y_error*scaleY);

%         y_data2 = y_data.^-1;
%         y_error = y_error.*y_data.^-2;
%         
%         [y_data2 y_error]
        
        set(DataPlotHan{mbIndex}   , ...
          'Marker'          , analyVar.MARKERS2{mbIndex},...
          'LineStyle'       , 'none' , ...
          'LineWidth'       , 1.5,...
          'Color'           , analyVar.COLORS(mbIndex,:),...
          'MarkerSize'      , 6 ...
          );        
        
      if Peak_or_Sum == 1
          set(DataPlotHan{mbIndex}, 'markerfacecolor' , analyVar.COLORS(mbIndex,:))
      end
      
        fitIndVar = linspace(0,max(x_data),1e4)';
        
        switch Peak_or_Sum
            case 1
            fitdataHan = ...
                plot(...
                fitIndVar*scaleX,...
                scaleY*Functional_Form(...
                    [slope, y_intercept], fitIndVar),...
                '-',...
                'Color',analyVar.COLORS(mbIndex,:),...
                'LineWidth'       , 2 ...
                );
            case 2
            fitdataHan = ...
                plot(...
                fitIndVar*scaleX,...
                scaleY*Functional_Form(...
                    [slope, y_intercept], fitIndVar),...
                '-.',...
                'Color',analyVar.COLORS(mbIndex,:),...
                'LineWidth'       , 2 ...
                );
        end
        hXLabel = xlabel('Peak Density (10^{13} cm^{-3})','FontSize',analyVar.axisfontsize);
        hYLabel = ylabel('Decay Rate (10^{3} s^{-1})','FontSize',analyVar.axisfontsize);

end
end
[Rb_yData, Rb_yData_error, RbHanData] = deal(cell(1,3));
Rb_xData = [3.1 3.5 4.5 5.3 6.6 7.8]*1E18; %2011 Butscher

Rb_yData{1} = [1.6 nan nan nan nan nan]*1E4; %decay rate
Rb_yData{2} = [33 29 27.7 24.1 23 22]*1E-6;
Rb_yData{3} = [nan 23 21 20 19 17]*1E-6;

Rb_yData_error{1} = [0.2 nan nan nan nan nan]*1E4;
Rb_yData_error{2} = [2 2 1.4 1.1 2 2]*1E-6;
Rb_yData_error{3} = [nan 3 3 2 2 2]*1E-6;

[Rb, y_intercept] = deal(nan(3,2));

Rb(1,:) = [0 1.6E4];
Rb(2,:) = [3.2E-15 2.3E4];
Rb(3,:) = [3.2E-15 3.2E4];

Rb_error(1,:) = [0 0.2E4];
Rb_error(2,:) = [1 0.4E4];
Rb_error(2,:) = [2 1.2E4];

RbHan = cell(1, size(Rb,1));

for RbIndex = 1:3

if RbIndex ~= 1
    Rb_yData_error{RbIndex} = Rb_yData_error{RbIndex}./Rb_yData{RbIndex}.^2;
    Rb_yData{RbIndex} = Rb_yData{RbIndex}.^-1;
end
    
RbHanData{RbIndex} = errorbar(scaleX*Rb_xData, scaleY*Rb_yData{RbIndex}, scaleY*Rb_yData_error{RbIndex});    

set(RbHanData{RbIndex}, ...
    'Marker'          , analyVar.MARKERS2{RbIndex+4},...
    'LineStyle'       , 'none' , ...
    'LineWidth'       , 1.5,...
    'Color'           , analyVar.COLORS(RbIndex+4,:),...
    'markerfacecolor' , analyVar.COLORS(RbIndex+4,:),...
    'MarkerSize'      , 6 ...
    ); 


RbHan{RbIndex} = ...
    plot(...
    fitIndVar*scaleX,...
    scaleY*Functional_Form(...
        [Rb(RbIndex,1), Rb(RbIndex,2)], fitIndVar),...
    '-',...
    'Color',analyVar.COLORS((RbIndex)+4,:),...
    'LineWidth'       , 2 ...
    );
end


    grid on
    axis tight
    axHan = gca;
    set([hXLabel, hYLabel, axHan] , 'FontSize', 14);
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickDir'     , 'out'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'on'      , ...
      'YMinorTick'  , 'on'      , ...
      'YMinorGrid'  , 'off'     ,...
      'YLim'        , [15, 60]  ,... 
      'XColor'      , [.3 .3 .3], ...
      'YColor'      , [.3 .3 .3], ...
      'LineWidth'   , 1         );
    hold off
    hLegend = legend([DataPlotHan{1} DataPlotHan{2} DataPlotHan{3} DataPlotHan{4} RbHanData{1} RbHanData{2} RbHanData{3}],...
        'Sr 38s Atomic', 'Sr 38s Mol. Ground', 'Sr 38s Mol. 1st Ex.', 'Sr 38s Mol. 2nd Ex.', 'Rb 35s Atomic', 'Rb 35s Mol. Ground', 'Rb 35s Mol. 1st Ex.');
    set(hLegend,...
    'FontSize', 12,...
    'Units', 'Normalized',...
    'Position', [.25 .3 .2 .175])
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%

scaleX = 1E16;

figure('Units', 'pixels', ...
'Position', [100 100 500 375]);
hold on

Rb(1,:) = [0 1.6E4];
Rb(2,:) = [3.2E-15 2.3E4];
Rb(3,:) = [3.2E-15 3.2E4];

Rb_error(1,:) = [0 0.2E4];
Rb_error(2,:) = [1E-15 0.4E4];
Rb_error(3,:) = [2E-15 1.2E4];

for RbIndex = 1:3
    
        RbplotHan{RbIndex} = ploterr(...
        Rb(RbIndex,1)*scaleX,...
        Rb(RbIndex,2)*scaleY,...
        Rb_error(RbIndex,1)*scaleX,...
        Rb_error(RbIndex,2)*scaleY,...
        analyVar.MARKERS2{RbIndex+4});
        
        set(RbplotHan{RbIndex}(1),'Color',analyVar.COLORS(RbIndex+4,:))
        set(RbplotHan{RbIndex}(1), 'markerfacecolor' , analyVar.COLORS(RbIndex+4,:))
        
        set(RbplotHan{RbIndex}(2),'Color',analyVar.COLORS(RbIndex+4,:))
        set(RbplotHan{RbIndex}(2), 'markerfacecolor' , analyVar.COLORS(RbIndex+4,:))
      
        set(RbplotHan{RbIndex}(3),'Color',analyVar.COLORS(RbIndex+4,:))
        set(RbplotHan{RbIndex}(3), 'markerfacecolor' , analyVar.COLORS(RbIndex+4,:))

end


for Peak_or_Sum = 2
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
    set([hXLabel, hYLabel, axHan] , 'FontSize', 14);
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickDir'     , 'out'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'on'      , ...
      'YMinorTick'  , 'on'      , ...
      'YMinorGrid'  , 'off'     ,...
      'XColor'      , [.3 .3 .3], ...
      'YColor'      , [.3 .3 .3], ...
      'LineWidth'   , 1         );
    hold off
    
    hLegend = legend([plotHan{1}(1) plotHan{2}(1) plotHan{3}(1) plotHan{4}(1) RbplotHan{1}(1) RbplotHan{2}(1) RbplotHan{3}(1)],...
        'Atomic State', 'Mol. Ground', 'Mol. 1st Ex.', 'Mol. 2nd Ex.', 'Rb 35s Atomic', 'Rb 35s Mol. Ground', 'Rb 35s Mol. 1st Ex.');
    set(hLegend,...
    'FontSize', 12,...
    'Units', 'Normalized',...
    'Position', [.25 .3 .2 .175])
    
end

