function [ output_args ] = plot_AveUVSpectrum2(analyVar, indivDataset, unique_Freq, unique_Density, AveUVSpectrum, AveUVSpectrum_error, Lorentzian_Amplitude, Lorentzian_LineCenter, Lorentzian_Width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Load Data
    xData = unique_Freq;
%     xData = 1:length(unique_Freq);
    yData = AveUVSpectrum; 
    NumDensities = length(yData);
    yData_error = AveUVSpectrum_error;
    cutZoom = cell(4,2);
    for cutIndex = 1:size(cutZoom,1)
        cutZoom{cutIndex,2} =  10^(cutIndex-1);
    end
    cutZoom{1, 1} = 1:26;
    cutZoom{2, 1} = [027:112 125:161];
    cutZoom{3, 1} = [113:124 162:235 251:length(xData)];
    cutZoom{4, 1} = 236:250;
%     cutZoom = 30; %select where data will be broken up to magnify
    ZoomMag = 1; %magnification of zoomed in data
    numRamps = analyVar.numLoopsSets(1);
    exposuretime = analyVar.Exposure_Time(1)*1e6; %us
    offset_scale = 1/numRamps/exposuretime;
        
    FeaturePos{1}           = [0];
    FeatureRelativeProb{1}  = 11; 
    FeaturePos{2}           = [-9.626875 -4.352663 -3.455487 -2.557472 -1.677280 -0.960187]; % values from Shuhei Yoshida 2015-10-21
    FeatureRelativeProb{2}  = [1         0.895936  0.288099  0.003575  0.282508  0.072952];  % values from Shuhei Yoshida 2015-10-21
    FeatureRelativeProb{2}  = ZoomMag*FeatureRelativeProb{2}; %scale to match data
    yAtomic =  Lorentzian_Amplitude(1)*lorentzian(unique_Freq, Lorentzian_LineCenter(1), Lorentzian_Width(1));
    
%     [yDataZoom,yDataZoom_error] = deal(cell(1,length(yData)));
%     for yIndex = 1:length(yData)
% %         yDataZoom{yIndex} = offset_scale*ZoomMag*(yData{yIndex}(cutZoom:end)- yAtomic(cutZoom:end));
%         yDataZoom{yIndex} = offset_scale*ZoomMag*yData{yIndex}(cutZoom:end);
%         yDataZoom_error{yIndex} = offset_scale*ZoomMag*yData_error{yIndex}(cutZoom:end); 
%     end
    
%% Format Data
    AtomicFreq = Lorentzian_LineCenter(1);
    FreqConversion = 8; %unitless, unit of UV freq per unit of Synth Freq.
    xData = -FreqConversion.*(xData - AtomicFreq);

    yData       = yData{1};
    yData_error = yData_error{1}; 

    [yDataZoom,yDataZoom_error, xDataZoom] = deal(cell(1,size(cutZoom,1)));    
    for cutIndex =  1:size(cutZoom,1)
        xDataZoom{cutIndex}       = xData(cutZoom{cutIndex,1});
%         if cutIndex ~= 1
%             yDataZoom{cutIndex}       = offset_scale*cutZoom{cutIndex,2}*(yData(cutZoom{cutIndex,1})-yAtomic(cutZoom{cutIndex,1}));
%         else
            yDataZoom{cutIndex}       = offset_scale*cutZoom{cutIndex,2}*(yData(cutZoom{cutIndex,1}));            
%         end
        yDataZoom_error{cutIndex} = offset_scale*cutZoom{cutIndex,2}*yData_error(cutZoom{cutIndex,1});
    end    
    
%% Plot    

figHan = figure('Units', 'pixels', ...
    'Position', [100 100 315 200]);

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

    
    vertLineHan = cell(1,length(FeaturePos));
    mycolors = FrancyColors(length(FeaturePos));
    for FeatureTypeIndex = 2
        for FeatureIndex = 1:length(FeaturePos{FeatureTypeIndex})
            x1 = FeaturePos{FeatureTypeIndex}(FeatureIndex);
            y1 = [0 4.2183*FeatureRelativeProb{FeatureTypeIndex}(FeatureIndex)];
            vertLineHan{FeatureTypeIndex} = plot([x1 x1],y1,'-', 'Color', analyVar.COLORS(FeatureTypeIndex+2,:), 'LineWidth', 2);
        end
    end   

    [DataPlotHan, DataPlotHanZoom] = deal(cell(1,NumDensities));
    for cutIndex = 1:size(cutZoom,1)
               
%         DataPlotHan{DensityIndex} = plot(xData, offset_scale*yData{DensityIndex});
% 
%         set(DataPlotHan{DensityIndex}, ...
%             'Marker'          , 'o',...
%             'LineStyle'       , 'none' , ...
%             'LineWidth'       , 0.5,...
%             'Color'           , analyVar.COLORS(1,:),...
%             'markerfacecolor' , analyVar.COLORS(1,:),...
%             'MarkerSize'      , 4 ...
%             ); 
%         removeErrorBarEnds(DataPlotHan{DensityIndex})

        DataPlotHanZoom{cutIndex} = errorbar(xDataZoom{cutIndex}, yDataZoom{cutIndex}, yDataZoom_error{cutIndex});
        set(DataPlotHanZoom{cutIndex}, ...
            'Marker'          , 'o',...
            'LineStyle'       , 'none' , ...
            'LineWidth'       , 0.5,...
            'Color'           , analyVar.COLORS(cutIndex,:),...
            'markerfacecolor' , analyVar.COLORS(cutIndex,:),...
            'MarkerSize'      , 4 ...
            ); 
        removeErrorBarEnds(DataPlotHanZoom{cutIndex})
    end
    FontSize = 8;
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
%     set(get(hLegend,'title'),'string','Density (10^{13} cm^{-3})')

hLegend = legend([DataPlotHanZoom{1} DataPlotHanZoom{2} DataPlotHanZoom{3} DataPlotHanZoom{4}], '\times 10^0' , '\times 10^1', '\times 10^2', '\times 10^3');
%     hLegend = legend([DataPlotHan{1}, DataPlotHanZoom{1}, vertLineHan{2}], 'Data', 'Data (x10)', 'Dimer Calc.');
    
    set(hLegend,...
    'FontSize', FontSize,...
    'Units', 'Pixels',...
    'Box', 'off',...
    'Position', [60 115 30 60])    
%% Make it Pretty    

%     grid on
    hXLabel = xlabel('UV Detuning (MHz)');
%     hYLabel = ylabel('Count Rate $\mu$','Interpreter','LaTex');

% hYLabel = ylabel(texlabel('Count Rate $\mu s^{-1}$'));
    hYLabel = ylabel('Signal (Arb. Units)');

    set([hXLabel, hYLabel, axHan] , 'FontSize', FontSize);
% set(axHan,'YScale','log')
    set(axHan, ...
      'Box'         , 'on'      , ...
      'TickLength'  , [.02 .02] , ...        
      'XMinorTick'  , 'off'      , ...
      'XColor'      , [0 0 0], ...
      'YColor'      , [0 0 0], ...
      'YMinorTick'  , 'off'      , ...
      'YMinorGrid'  , 'off'      ,...
      'YLim'        , [0, 5],...
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