function [ output_args ] = plot_StateEvolution_sameState_diffDensity( analyVar, indivDataset )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

NumDensities = indivDataset{1}.numDensityGroups{1};
NumBatches = indivDataset{1}.CounterAtom;
timescale = 1E6;
%% Load Fitted Parameters for Peak Bin

for axisIndex = 3

NumSets = analyVar.numBasenamesAtom;
for mbIndex = 1

    figure('Units', 'pixels', ...
        'Position', [100 100 500 500]);
    hold on

[SumPlotHan, FeaturePlotHan] = deal(cell(1,NumSets)); 
    numcolors = RedToBlue(NumDensities);
for densityIndex = 1:NumDensities;%1:NumDensities
    featureIndex = analyVar.DrivenStateGroup(mbIndex);

for Feature_or_Sum = 2
    xData = indivDataset{mbIndex}.timedelayOrderMatrix{1}'; %s, Electric Field delay times
    fitIndVar = linspace(0,max(xData),1e4)';

    %% Fit Model
        Functional_Form = @(coeffs,x) ...
            coeffs(1)*exp(-coeffs(2)*x)+coeffs(3);    

        switch Feature_or_Sum
            case 1
                %% Load Fit Parameters
                    Peak_InitialValue    =   indivDataset{mbIndex}.Peak_InitialValue(densityIndex,1);
                    scaleFactor = 1/Peak_InitialValue;
                    Peak_InitialValue    =   1;
                    Peak_DecayRate       =   indivDataset{mbIndex}.Peak_DecayRate(densityIndex,1);   
                    Peak_Offset          =   indivDataset{mbIndex}.Peak_Offset(densityIndex,1);                                       
            
                %% Load Field Data
                    Feature_AvgSpectra       = indivDataset{mbIndex}.Feature_AbsNormAvgSpectra;
                    Feature_AvgSpectra       = Feature_AvgSpectra{featureIndex}(:,densityIndex);
                    Feature_AvgSpectra       = Feature_AvgSpectra*scaleFactor; 
                    Feature_AvgSpectra_error = indivDataset{mbIndex}.Feature_AbsNormAvgSpectra_error;
                    Feature_AvgSpectra_error = Feature_AvgSpectra_error{featureIndex}(:,densityIndex);
                    Feature_AvgSpectra_error = Feature_AvgSpectra_error*scaleFactor;
               
                %% Plot Data
                    if axisIndex ~= 2
                         FeaturePlotHan{densityIndex} = errorbar(...
                            xData*timescale,...
                            Feature_AvgSpectra,...
                            Feature_AvgSpectra_error);

                        set(FeaturePlotHan{densityIndex}   , ...
                          'Marker'          , analyVar.MARKERS2{densityIndex+NumSets*(Feature_or_Sum-1)},...
                          'LineStyle'       , 'none' , ...   
                          'LineWidth'       , 2,...
                          'Color'           , numcolors(densityIndex,:),...
                          'markerfacecolor' , numcolors(densityIndex,:),...
                          'MarkerSize'      , 6 ...
                          );
                        
                    else
                        FeaturePop_Fit = Functional_Form([Peak_InitialValue Peak_DecayRate Peak_Offset], xData);
                        Residuals = (FeaturePop_Fit - Feature_AvgSpectra)./Feature_AvgSpectra;
                        plot(...
                            xData*timescale,...
                            Residuals,...
                            analyVar.MARKERS2{densityIndex},...
                            'Color',numcolors(densityIndex,:),...
                            'MarkerSize',analyVar.markerSize/2);
                    end

                %% Plot Fit
                if axisIndex ~=2
                    plot(fitIndVar*timescale, Functional_Form(...
                        [Peak_InitialValue Peak_DecayRate Peak_Offset],...
                        fitIndVar),'-',...
                        'Color',numcolors(densityIndex,:),...
                    'LineWidth'       , 1)
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
                    TotalRydPop_error{mbIndex}   = TotalRydPop_error{mbIndex}*scaleFactor;
                %% Plot Data
                if axisIndex ~= 2

                    SumPlotHan{densityIndex} = errorbar(...
                        xData*timescale,...
                        TotalRydPop{mbIndex},...
                        TotalRydPop_error{mbIndex});
                    
                    set(SumPlotHan{densityIndex}   , ...
                      'Marker'          , analyVar.MARKERS2{densityIndex},...
                      'LineStyle'       , 'none' , ...
                      'LineWidth'       , 2,...
                      'Color'           , numcolors(densityIndex,:),...
                      'MarkerSize'      , 6 ...
                      );
                    
                else
                    TotalRydPop_Fit = Functional_Form([Sum_InitialValue Sum_DecayRate Sum_Offset], xData);
                    TotalRydPop{mbIndex} = (TotalRydPop_Fit - TotalRydPop{mbIndex})./TotalRydPop{mbIndex};
                    plot(...
                        xData*timescale,...
                        TotalRydPop{mbIndex},...
                        analyVar.MARKERS2{densityIndex+NumSets*(Feature_or_Sum-1)},...
                        'Color',numcolors(densityIndex,:),...
                        'MarkerSize',analyVar.markerSize/2);
                end

                %% Plot Fit
                if axisIndex ~=2
                    plot(fitIndVar*timescale, Functional_Form(...
                        [Sum_InitialValue Sum_DecayRate Sum_Offset],...
                        fitIndVar),...
                        '-.',...
                        'Color',numcolors(densityIndex,:),...
                        'LineWidth'       , 1)
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
    grid on 

    xlim([0 round(xData(end)*timescale)])
    if axisIndex ~=2
        ylim([0 1])
        hYLabel = ylabel('Fractional Population');
    else
        hYLabel = ylabel('Fractional Population Residuals');
    end
    hXLabel = xlabel('Field Delay (us)');
    axis square
    box on
    titlehan = title(['Atomic State']);
        
    legendstr = indivDataset{mbIndex}.densityvector;
    legendstr = round(legendstr*10^-18)/10;
%     legendstr = int32(legendstr);
%         [legendstr, ~, ~] = AxisTicksEngineeringForm(legendstr);
%         legendstr = round(legendstr);
        legendstr = textscan(num2str(legendstr'),'%s');
        legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
        legarray = [];
        for dIndex = 1:NumDensities
            legarray = cat(1, legarray, SumPlotHan{dIndex });
        end
        hLegend = legend(legarray, legendstr);
        set(get(hLegend,'title'),'string','Density (10^{13} cm^{-3})')

        
set(hLegend,...
    'FontSize', 12,...
    'Units', 'Normalized',...
    'Position', [.25 .3 .2 .175])

set([hXLabel, hYLabel, axHan, titlehan] , 'FontSize', 14);
set(titlehan, 'Color', [.3,.3,.3])
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

end
% [legendstr, ~, ~] = AxisTicksEngineeringForm(abs(analyVar.ElectricField)');
% legendstr = round(legendstr);
% legendstr = textscan(num2str(legendstr),'%s');
% legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);


end

end

