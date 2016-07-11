function [ output_args ] = plot_SFI_Integral(analyVar,indivDataset)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    Array_error = indivDataset{1}.SFI_Integral_error;    
    Array = indivDataset{1}.SFI_Integral;              
    
    for Synth_or_UV = 1:2
        figHan = figure();
        set(figHan, 'Color', [1,1,1]);
        set(figHan, 'Units', 'Normalized');
        set(figHan, 'OuterPosition', [.1 .1 .4 .5]);
        
        switch Synth_or_UV
            case 1
                xData = indivDataset{1}.imagevcoAtom;
            case 2
                FreqConversion = 8; %unitless, unit of UV freq per unit of Synth Freq.
                xData = indivDataset{1}.imagevcoAtom(2)-indivDataset{1}.imagevcoAtom(1);
                xData = FreqConversion*xData;
                xData = xData*[1:length(indivDataset{1}.imagevcoAtom)]-xData;
                xData = -xData;
                AtomicFreq = -1.6;
                xData = (xData - AtomicFreq);
        end

    errorbar(xData, Array, Array_error, 'o','MarkerSize', 4);
    grid on
    switch Synth_or_UV
        case 1
            xlabel('Synth. Frequency (MHz)')
        case 2
            xlabel('UV Frequency (MHz)')
    end
    ylabel('Normalized Amplitude')

    end
    
    output_args = nan;
end

