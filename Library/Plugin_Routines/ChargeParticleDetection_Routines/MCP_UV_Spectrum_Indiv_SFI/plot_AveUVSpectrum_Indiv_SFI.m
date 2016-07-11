function [ output_args ] = plot_AveUVSpectrum_Indiv_SFI(analyVar, indivDataset, Ave_SFI, Ave_SFI_error)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



%% Load Data
NumUniqueFreq = length(Ave_SFI);
NumUniqueDensity = 1;%length(Ave_SFI{1});
xData = analyVar.ElectricField;
[yData, yData_error] = deal(cell(1,NumUniqueFreq));
for uniqueFreqIndex = 1:NumUniqueFreq
    [yData{uniqueFreqIndex}, yData_error{uniqueFreqIndex}] = deal(cell(1, NumUniqueDensity));
    for uniqueDensityIndex = 1%:NumUniqueDensity
        yData{uniqueFreqIndex}{uniqueDensityIndex} = Ave_SFI{uniqueFreqIndex}{uniqueDensityIndex};
        yData_error{uniqueFreqIndex}{uniqueDensityIndex} = Ave_SFI_error{uniqueFreqIndex}{uniqueDensityIndex};
%         xData{uniqueFreqIndex}{uniqueDensityIndex} = (1:length(yData{uniqueFreqIndex}{uniqueDensityIndex}))';
    end
end
        
%% Plot    
FontSize = 8;

% uniqueFreqIndex = [17, 140, 75, 62, 264, 199, 184, 117, 387, 323, 310, 244]

%% Frequencies of features of interest
% featurePos = cell(1,5);
% featurePos{1}{1} = 039;     %Atomic
% featurePos{1}{2} = 001:050; %Atomic
% 
% featurePos{2}{1} = 160; %Dimer 0 
% featurePos{2}{2} = 145:168; %Dimer 0
% 
% featurePos{3}{1} = 095; %Dimer 1
% featurePos{3}{2} = 088:106; %Dimer 1
% 
% featurePos{4}{1} = 081; %Dimer 2
% featurePos{4}{2} = 072:089; %Dimer 2
% 
% featurePos{5}{1} = 057; %Dimer 4
% featurePos{5}{2} = 050:071; %Dimer 4

[DataPlotHan] = deal(cell(1,NumUniqueFreq));

figHan = figure('Units', 'pixels', ...
'Position', [100 100 2*315 2*200]);
set(figHan, 'Renderer', 'painters')
hold on

    colorArray = FrancyColors(length(DataPlotHan));
    axHan = gca;
for uniqueFreqIndex = 1:length(DataPlotHan)
    freq = uniqueFreqIndex;
%     DataPlotHan{uniqueFreqIndex} = deal(cell(1,NumUniqueDensity));
    
%     yData2 = deal(cell(1,length(yData)));
%     yData{freq} = cell2mat(yData{freq});
%     yData{freq} = nanmean(yData{freq},2);
% %     yData{freqpos} = yData{freqpos}; 
    
%     yData_error{freq} = cell2mat(yData_error{freq});
%     yData_error{freq} = nanmean(yData_error{freq},2);
% %     yData_error{freqpos} = yData_error{freqpos};
    
    DataPlotHan{uniqueFreqIndex} = errorbar(xData, yData{freq}{1},  yData_error{freq}{1});
    removeErrorBarEnds(DataPlotHan{uniqueFreqIndex})
%     DataPlotHan{uniqueFreqIndex} = plot(xData, yData{freqpos});
    set(DataPlotHan{uniqueFreqIndex}, ...
        'LineStyle'       , '-' , ...
        'LineWidth'       , 0.5,...
        'Color'           , colorArray(uniqueFreqIndex,:),...
        'marker'          , 'o',...
        'markerfacecolor' , colorArray(uniqueFreqIndex,:)...
        ); 
    

end

    hold off
    axis tight
    hXLabel = xlabel('Electric Field (V cm^{-1})');
    hYLabel = ylabel('Signal (Arb. Units)');
    set([hXLabel, hYLabel, axHan] , 'FontSize', FontSize);
%     set(axHan{uniqueFreqIndex},'YScale','log')
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickLength'  , [.02 .02] , ...        
      'XMinorTick'  , 'off'      , ...
      'XColor'      , [0 0 0], ...
      'YColor'      , [0 0 0], ...
      'YMinorTick'  , 'off'      , ...
      'YMinorGrid'  , 'off'      ,...
      'LineWidth'   , 0.5, ...
      'Clipping' , 'off' ...
            ); 

    
%     DensityScale = 1E-6;
%     legendstr = indivDataset{1}.imagevcoAtom;
%     legendstr = round(legendstr/DensityScale);
%     legendstr = legendstr(1:length(DataPlotHan));
%     legendstr = textscan(num2str(legendstr'),'%s');
%     legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
%     legarray = [];
%     for dIndex = 1:length(DataPlotHan)
%         legarray = cat(1, legarray, DataPlotHan{dIndex}{1});
%     end
%     hLegend = legend(legarray, legendstr);
%     set(get(hLegend,'title'),'string','Exposure Time (\mu s)')



    
%     hLegend = legend([DataPlotHan{1}, DataPlotHanZoom{1}, vertLineHan{2}], 'Data', 'Data (x10)', 'Dimer Calc.');
%     set(hLegend,...
%         'FontSize', FontSize,...
%         'Units', 'Normalized',...
%         'Position', [.265 .65 .2 .175]) 
%% Make it Pretty    


   

       

% Sub1Index = 50:80;
% axes('Position',[.7 .7 .2 .2])
% box on
% Sub1Han = plot(xData(Sub1Index),yDataSub{yIndex}(Sub1Index));
% axHanSub1 = gca;

output_args = nan;
end