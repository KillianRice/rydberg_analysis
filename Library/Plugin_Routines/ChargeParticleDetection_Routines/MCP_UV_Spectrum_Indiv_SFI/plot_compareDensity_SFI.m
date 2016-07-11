function [ output_args ] = plot_compareDensity_SFI(analyVar, xData, yData, yData_error, DensityGroupsToAverage, featurePos, UVunique_Freq, stats_counter)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

NumDensity = length(yData{1});
NumFreq = length(yData);

figScale = 2;
FontSize = 10;
FreqScale = 1000;

xtranslatefig = .9;
ytranslatefig = .775;
posoffset = 50;
xfigpos = [0 figScale*315*xtranslatefig 2*figScale*315*xtranslatefig 0 figScale*315*xtranslatefig 2*figScale*315*xtranslatefig];
xfigpos = [xfigpos xfigpos xfigpos xfigpos xfigpos xfigpos];
yfigpos = [figScale*315*ytranslatefig figScale*315*ytranslatefig figScale*315*ytranslatefig 0 0 0];
yfigpos = [yfigpos yfigpos yfigpos yfigpos yfigpos yfigpos ];
xfigpos = xfigpos + posoffset;
yfigpos = yfigpos + posoffset;

for freqIndex = 1:NumFreq
% mycolors = FrancyColors(length(yData{freqIndex}));
[TraceHan, LegendString] = deal(cell(1,NumDensity));
    figure('Color',[1 1 1], 'Units', 'pixels', ...
    'Position', [xfigpos(freqIndex) yfigpos(freqIndex) figScale*315 figScale*200],...
    'Renderer', 'Painters')
%     subplot(2,1,1)
    hold on        
    for denIndex = 1:NumDensity
%         TraceHan{denIndex} = errorbar(xData, yData{freqIndex}{denIndex}, yData_error{freqIndex}{denIndex}/stats_counter^0.5, 'Color', FC_ColorGradient(NumDensity, denIndex));
%         removeErrorBarEnds(TraceHan{denIndex})
        TraceHan{denIndex} = plot(xData, yData{freqIndex}{denIndex}, 'Color', FC_ColorGradient(NumDensity, denIndex) );
        LegendString(denIndex) = {['\rho: ' mat2str(DensityGroupsToAverage{denIndex}(1)) ':' mat2str(DensityGroupsToAverage{denIndex}(end)) ' // \nu (MHz): '...
            mat2str(round(FreqScale*UVunique_Freq(featurePos{freqIndex}(end)))/FreqScale)...
            ' to '...
            mat2str(round(FreqScale*UVunique_Freq(featurePos{freqIndex}(1)))/FreqScale)...
            ]};
    end
    hold off
    axis tight
    set(gca,...
        'Box'         , 'on'      , ...
        'TickLength'  , [.02 .02] , ...        
        'XMinorTick'  , 'off'      , ...
        'XColor'      , [0 0 0], ...
        'YColor'      , [0 0 0], ...
        'YMinorTick'  , 'off'      , ...
        'YMinorGrid'  , 'off'      ,...
        'LineWidth'   , 0.5, ...        
        'YScale', 'linear',...
        'FontSize', FontSize);
    hXLabel = xlabel('Electric Field (V cm^{-1})');
    hYLabel = ylabel('Signal (Arb. Units)');    
    set([hXLabel, hYLabel] , 'FontSize', FontSize);  

    hLegend = legend([TraceHan{:}], LegendString);    
    set(hLegend,...
        'FontSize', 10,...
        'Units', 'Normalized',...
        'Location', 'Best')       
title(analyVar.titleString, 'FontSize' , FontSize)     

tightfig;  
    
end

output_args = nan;

end

