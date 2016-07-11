function [ output_args ] = plot_AveUVSpectrum_AveOverDensity(analyVar, indivDataset, unique_Freq, unique_Density, AveUVSpectrum, AveUVSpectrum_error, Lorentzian_Amplitude, Lorentzian_LineCenter, Lorentzian_Width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Load Data
%     xData = unique_Freq;
    xData = 1:length(unique_Freq);
    yData = AveUVSpectrum; 
    yData_error = AveUVSpectrum_error;
    NumDensities = length(yData);
    
    ZoomMag = 1; %magnification of zoomed in data
    numRamps = analyVar.numLoopsSets(1);
    exposuretime = analyVar.Exposure_Time(1)*1e6; %us
    SignalNormalize = 1/numRamps/exposuretime;
        
    yAtomic =  Lorentzian_Amplitude(1)*lorentzian(unique_Freq, Lorentzian_LineCenter(1), Lorentzian_Width(1));
    
%space out the diff densities
%     for yIndex = 1:length(yData)
% %         yData{yIndex} = offset_scale*ZoomMag*(yData{yIndex}(cutZoom:end)- yAtomic(cutZoom:end));
% 
% %         yData{yIndex} = 10^(length(yData)-yIndex+1)*yData{yIndex};
% %         yData_error{yIndex} = 10^(length(yData)-yIndex+1)*yData_error{yIndex}; 
% 
%     end

yData1 = yData(1:length(yData)/2);
yData2 = yData(length(yData)/2+1:end);

yData1 = cell2mat(yData1);
yData1 = nanmean(yData1,2);
yData1 = SignalNormalize*yData1;
yData2 = cell2mat(yData2);
yData2 = nanmean(yData2,2);
yData2 = SignalNormalize*yData2;

yData = cell2mat(yData);
yData = nanmean(yData,2);
yData = SignalNormalize*yData;

% yData = cell2mat(yData);
% yData = nanmean(yData,2);
% yData = SignalNormalize*yData;
% 
% yData_error = cell2mat(yData_error);
% yData_error = nanmean(yData_error,2);
% yData_error = SignalNormalize*yData_error;


%% Format Data
    AtomicFreq = Lorentzian_LineCenter(1);
    FreqConversion = 8; %unitless, unit of UV freq per unit of Synth Freq.
%     xData = -FreqConversion.*(xData - AtomicFreq);
    
%% Plot    

figHan = figure('Units', 'pixels', ...
    'Position', [100 100 3*315 3*200]);

set(figHan, 'Renderer', 'painters')
hold on

axHan = gca;

%     lorFun = @(x) offset_scale*Lorentzian_Amplitude(1)*lorentzian(x, 0 , FreqConversion*Lorentzian_Width(1) );
% [lorX, lorY] = fplot(lorFun, [-10,2]);
% plot(lorX, lorY, 'Color', analyVar.COLORS(1,:),'LineWidth', 1.5)

    xDataLorentzian = linspace(-0.736, max(xData), 1e3);
%     xDataLorentzian2 = linspace(min(xData), max(xData), 1e3);

%     plot(xDataLorentzian, offset_scale*Lorentzian_Amplitude(1)*lorentzian(xDataLorentzian, 0 , FreqConversion*Lorentzian_Width(1) ), 'Color', analyVar.COLORS(1,:),'LineWidth', 1.5) 

% lorvec = offset_scale*Lorentzian_Amplitude(1)*lorentzian(xDataLorentzian, 0 , FreqConversion*Lorentzian_Width(1) );
% vq1 = interp1(xDataLorentzian,lorvec, xDataLorentzian2);
% plot(xDataLorentzian2, vq1, 'Color', analyVar.COLORS(1,:),'LineWidth', 1.5)


    DataPlotHan1 = plot(...
        xData,...
        yData);
    set(DataPlotHan1, ...
        'Marker'          , 'o',...
        'LineWidth'       , 0.5,...
        'Color'           , [.75 0 0],...
        'markerfacecolor' , [.75 0 0],...        
        'MarkerSize'      , 3 ...
        ); 
%     DataPlotHan2 = plot(...
%         xData,...
%         yData2);
%     set(DataPlotHan2, ...
%         'Marker'          , 'o',...
%         'LineWidth'       , 0.5,...
%         'Color'           , [0 0 .75],...
%         'markerfacecolor' , [0 0 .75],...
%         'MarkerSize'      , 3 ...
%         );     

%     DataPlotHan = plot(...
%         xData,...
%         yData);
%     set(DataPlotHan, ...
%         'Marker'          , 'o',...
%         'LineWidth'       , 0.5,...
%         'Color'           , [0 0 .75],...
%         'markerfacecolor' , [0 0 .75],...
%         'MarkerSize'      , 3 ...
%         ); 
%     removeErrorBarEnds(DataPlotHan)
   
    
% for DensityIndex = 1:NumDensities
%     DataPlotHan{DensityIndex} = plot(xData, SignalNormalize*yData{DensityIndex});
%     set(DataPlotHan{DensityIndex}, ...
%         'Marker'          , 'o',...
%         'LineWidth'       , 0.5,...
%         'Color'           , mycolors(DensityIndex,:),...
%         'markerfacecolor' , mycolors(DensityIndex,:),...
%         'MarkerSize'      , 3 ...
%         ); 
%     removeErrorBarEnds(DataPlotHan{DensityIndex})
% end

    FontSize = 12;
    
    hold off
    axis tight
    
%     DensityScale = 1E-18;
%     legendstr = indivDataset{1}.densityvector;
%     legendstr = round(legendstr*DensityScale)/10;
%     legendstr = textscan(num2str(legendstr'),'%s');
%     legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
%     legarray = [];
%     for dIndex = 1:NumDensities
%         legarray = cat(1, legarray, DataPlotHan{dIndex});
%     end
%     hLegend = legend(legarray, legendstr);
%     set(get(hLegend,'title'),'string','Ave. Density (10^{13} cm^{-3})')

% hLegend = legend([DataPlotHanZoom{1} DataPlotHanZoom{2} DataPlotHanZoom{3} DataPlotHanZoom{4}], '\times 10^0' , '\times 10^1', '\times 10^2', '\times 10^3');
%     hLegend = legend([DataPlotHan1, DataPlotHan2], 'First Half', 'Second Half');
    
%     set(hLegend,...
%     'FontSize', FontSize,...
%     'Units', 'Pixels',...
%     'Box', 'on',...
%     'Position', [60 115 100 500])    
%% Make it Pretty    

%     grid on
    hXLabel = xlabel('UV Detuning (MHz)');
%     hYLabel = ylabel('Count Rate $\mu$','Interpreter','LaTex');

% hYLabel = ylabel(texlabel('Count Rate $\mu s^{-1}$'));
    hYLabel = ylabel('Counts / \tau_{Ex} (\mus^{-1})');

    set([hXLabel, hYLabel, axHan] , 'FontSize', FontSize);
set(axHan,'YScale','log')
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

% Sub1Index = 50:80;
% axes('Position',[.7 .7 .2 .2])
% box on
% Sub1Han = plot(xData(Sub1Index),yDataSub{yIndex}(Sub1Index));
% axHanSub1 = gca;

output_args = nan;
end