function [ output_args ] = plot_StateEvolution( analyVar, indivDataset )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
FontSize = 8;

NumDensities = indivDataset{1}.numDensityGroups{1};
NumBatches = indivDataset{1}.CounterAtom;
timescale = 1E6;
%% Load Fitted Parameters for Peak Bin

for axisIndex = 3

NumSets = analyVar.numBasenamesAtom;

for densityIndex = 1:NumDensities
    figure('Units', 'pixels', ...
        'Position', [100 100 315 205]);
    hold on

[SumPlotHan, FeaturePlotHan] = deal(cell(1,NumSets)); 

for mbIndex = 1:NumSets
    
    featureIndex = analyVar.DrivenStateGroup(mbIndex);
for Feature_or_Sum = 1
    xData = indivDataset{mbIndex}.timedelayOrderMatrix{1}'; %s, Electric Field delay times
    fitIndVar = linspace(-5e-6, 65e-6,1e3)';

    %% Fit Model
        Functional_Form = @(coeffs,x) ...
            coeffs(1)*exp(-coeffs(2)*x)+coeffs(3);    

        switch Feature_or_Sum
            case 1
                %% Load Fit Parameters
                    Peak_InitialValue    =   indivDataset{mbIndex}.Peak_InitialValue(densityIndex,1);
                    Peak_DecayRate       =   indivDataset{mbIndex}.Peak_DecayRate(densityIndex,1);   
                    Peak_Offset          =   indivDataset{mbIndex}.Peak_Offset(densityIndex,1);
                    scaleFactor = 1/(Peak_InitialValue+Peak_Offset);
                    Peak_InitialValue    =   Peak_InitialValue*scaleFactor;
                    Peak_Offset          =   Peak_Offset*scaleFactor;
                %% Load Field Data
                    Feature_AvgSpectra       = indivDataset{mbIndex}.Feature_AbsNormAvgSpectra;
                    Feature_AvgSpectra       = Feature_AvgSpectra{featureIndex}(:,densityIndex);
                    Feature_AvgSpectra       = Feature_AvgSpectra*scaleFactor; 
                    Feature_AvgSpectra_error = indivDataset{mbIndex}.Feature_AbsNormAvgSpectra_error;
                    Feature_AvgSpectra_error = Feature_AvgSpectra_error{featureIndex}(:,densityIndex);
                    Feature_AvgSpectra_error = Feature_AvgSpectra_error*scaleFactor;
               
                %% Plot Data
                    if axisIndex ~= 2
                         FeaturePlotHan{mbIndex} = errorbar(...
                            xData*timescale,...
                            Feature_AvgSpectra,...
                            Feature_AvgSpectra_error);

                        set(FeaturePlotHan{mbIndex}   , ...
                          'Marker'          , analyVar.MARKERS2{mbIndex+NumSets*(Feature_or_Sum-1)},...
                          'LineStyle'       , 'none' , ...   
                          'LineWidth'       , 0.5,...
                          'Color'           , analyVar.COLORS(mbIndex,:),...
                          'markerfacecolor' , analyVar.COLORS(mbIndex,:),...
                          'MarkerSize'      , 3 ...
                          );
                        removeErrorBarEnds(FeaturePlotHan{mbIndex})
                    else
                        FeaturePop_Fit = Functional_Form([Peak_InitialValue Peak_DecayRate Peak_Offset], xData);
                        Residuals = (FeaturePop_Fit - Feature_AvgSpectra)./Feature_AvgSpectra;
                        plot(...
                            xData*timescale,...
                            Residuals,...
                            analyVar.MARKERS2{mbIndex},...
                            'Color',analyVar.COLORS(mbIndex,:),...
                            'MarkerSize',analyVar.markerSize/2);
                    end

                %% Plot Fit
                if axisIndex ~=2
                    plot(fitIndVar*timescale, Functional_Form(...
                        [Peak_InitialValue Peak_DecayRate Peak_Offset],...
                        fitIndVar),'-',...
                        'Color',analyVar.COLORS(mbIndex,:),...
                    'LineWidth'       , 0.5)
                end

            %% Sum of All Fields           
            case 2
                [TotalRydPop, TotalRydPop_error] = deal(cell(NumSets,1));

                %% Fit Model
                    Functional_Form = @(coeffs,x) ...
                        coeffs(1)*exp(-coeffs(2)*x)+coeffs(3);
                %% Load Fit Parameters
                    Sum_InitialValue    = indivDataset{mbIndex}.Sum_InitialValue(densityIndex,1);
                    scaleFactor = 1/Sum_InitialValue;
                    Sum_InitialValue = 1;
                    Sum_DecayRate       = indivDataset{mbIndex}.Sum_DecayRate(densityIndex,1);     
                    Sum_Offset          = indivDataset{mbIndex}.Sum_Offset(densityIndex,1);                                       
            
                %% Load Sum Field Data
                    TotalRydPop{mbIndex}         = indivDataset{mbIndex}.NormTotalPopAvgSpectra;
                    TotalRydPop{mbIndex}         = TotalRydPop{mbIndex}(:,densityIndex);         
                    TotalRydPop{mbIndex}         = TotalRydPop{mbIndex}*scaleFactor ;
                    TotalRydPop_error{mbIndex}   = indivDataset{mbIndex}.NormTotalPopAvgSpectra_error;
                    TotalRydPop_error{mbIndex}   = TotalRydPop_error{mbIndex}(:,densityIndex); 
%                     TotalRydPop_error{mbIndex}   = TotalRydPop_error{mbIndex}*scaleFactor;
                %% Plot Data
                if axisIndex ~= 2

                    SumPlotHan{mbIndex} = errorbar(...
                        xData*timescale,...
                        TotalRydPop{mbIndex},...
                        TotalRydPop_error{mbIndex});
                    
                    set(SumPlotHan{mbIndex}   , ...
                      'Marker'          , analyVar.MARKERS2{mbIndex},...
                      'LineStyle'       , 'none' , ...
                      'LineWidth'       , 0.5,...
                      'Color'           , analyVar.COLORS(mbIndex,:),...
                      'MarkerSize'      , 3 ...
                      );
                    
                else
                    TotalRydPop_Fit = Functional_Form([Sum_InitialValue Sum_DecayRate Sum_Offset], xData);
                    TotalRydPop{mbIndex} = (TotalRydPop_Fit - TotalRydPop{mbIndex})./TotalRydPop{mbIndex};
                    plot(...
                        xData*timescale,...
                        TotalRydPop{mbIndex},...
                        analyVar.MARKERS2{mbIndex+NumSets*(Feature_or_Sum-1)},...
                        'Color',analyVar.COLORS(mbIndex,:),...
                        'MarkerSize',analyVar.markerSize/2);
                end

                %% Plot Fit
                if axisIndex ~=2
                    plot(fitIndVar*timescale, Functional_Form(...
                        [Sum_InitialValue Sum_DecayRate Sum_Offset],...
                        fitIndVar),...
                        '-.',...
                        'Color',analyVar.COLORS(mbIndex,:),...
                        'LineWidth'       , 0.5)
                end

        end
        
    axHan = gca;
    if axisIndex== 3
        set(axHan,'YScale','log')
    end

end
    
end
hold off

%% Plot Options

    xlim([0 round(xData(end)*timescale)])
    if axisIndex ~=2
        ylim([0 1])
        hYLabel = ylabel('Fractional Population');
    else
        hYLabel = ylabel('Fractional Population Residuals');
    end
    hXLabel = xlabel('Time Delay t_D (\mus)');
    box on
%     titlehan = title(['Density Group: ' mat2str(round(indivDataset{1}.densityvector(densityIndex)/1e19)) ' x 10^{13} cm^{-3}']);

hLegend = legend([FeaturePlotHan{1}, FeaturePlotHan{2}, FeaturePlotHan{3}, FeaturePlotHan{4}], 'Atom', 'v = 0', 'v = 1', 'v = 2');

% % hLegend = legend([SumPlotHan{1}, SumPlotHan{2}, SumPlotHan{3}, SumPlotHan{4}], 'Atomic State', 'Mol. Ground', 'Mol. 1st Ex.', 'Mol. 2nd Ex.');
% 
% %   'atomic Sum', 'atomic Sum', 'ground Sum', 'ground Sum', '1st Sum', '1st Sum', '2nd Sum', '2nd Sum'
% % set(hLegend,...
% %     'FontSize', FontSize,...
% %     'Units', 'Normalized',...
% %     'Position', [.275 .35 .1 .1])

    set(hLegend,...
    'FontSize', 8,...
    'Units', 'Pixels',...
    'Box', 'off',...
    'Position', [55 60 30 60])

set([hXLabel, hYLabel, axHan] , 'FontSize', FontSize);
% set(titlehan, 'Color', [.3,.3,.3])
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickLength'  , [.02 .02] , ...        
      'XMinorTick'  , 'off'      , ...
      'XColor'      , [0 0 0], ...
      'XLim'        , [-2 62],...
      'YColor'      , [0 0 0], ...
      'YMinorTick'  , 'on'      , ...
      'YMinorGrid'  , 'off'      ,...
      'YLim'        , [0.01 1.4],...
      'LineWidth'   , 0.5, ...
      'Clipping' , 'off' ...
            );  

end
% [legendstr, ~, ~] = AxisTicksEngineeringForm(abs(analyVar.ElectricField)');
% legendstr = round(legendstr);
% legendstr = textscan(num2str(legendstr),'%s');
% legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);


end

end

