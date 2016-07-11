function [Amplitude, center_gaussian, Width] = AtomicLineShapeFit2(unique_Freq, unique_Density, AveUVSpectrum)
% Going to start by only fitting to the highset density in the data set; this should coincide with the first element in the cells    

%% Load Data
cutRegions{1} = 8:13;
% cutRegions{2} = 23:28;
% % cutRegions{1} = 106:115;
% cutRegions{3} = 340:365;
% cutRegions{4} = 400:415;
[xData, yData, vec2] = deal([]) ;
for cutIndex = 1:length(cutRegions)
    vec = cutRegions{cutIndex}';
    vec2 = cat(1, vec2, cutRegions{cutIndex}');
    xData = cat(1, xData, unique_Freq(vec));
    yData = cat(1, yData, AveUVSpectrum{1}(vec)); 
end

%% Find Center
fitOffsetLogic = 0;
gauss_vec = 13:23;
gauss_x = linspace(unique_Freq(gauss_vec(1)), unique_Freq(gauss_vec(end)), 1e3);
[amplitude_gaussian, center_gaussian, sigma_gaussian, ~] = gaussian_fit(unique_Freq(gauss_vec), AveUVSpectrum{1}(gauss_vec), 0);

% center_gaussian = 103.925;

%% Fit Data
[Amplitude, Width, ~] = Lorentzian_Fit(xData-center_gaussian(1), yData, fitOffsetLogic);

% Amplitude = 1;
% Width = 1;
%% Mirror Data
% xMirror = (center_gaussian(1)-unique_Freq(cutRegions{1}))+center_gaussian(1);
% xMirror = cat(1, xMirror, unique_Freq(cutRegions{1}));
% yMirror = cat(1, AveUVSpectrum{1}(cutRegions{1}), AveUVSpectrum{1}(cutRegions{1}));

%% Fit Mirror Data
% [AmplitudeMirror, WidthMirror, ~] = Lorentzian_Fit(xMirror-center_gaussian(1), yMirror, fitOffsetLogic);

figure
hold on
plot(unique_Freq, Amplitude(1)*lorentzian(unique_Freq, center_gaussian(1), Width(1)), 'black', 'LineWidth',2)
% % plot(unique_Freq, AmplitudeMirror(1)*lorentzian(unique_Freq, center_gaussian(1), WidthMirror(1)), 'green', 'LineStyle', '-.', 'LineWidth',2)
plot(gauss_x, amplitude_gaussian(1)*gaussmf(gauss_x, [sigma_gaussian(1), center_gaussian(1)] ), 'blue','LineWidth',2);
plot(unique_Freq, AveUVSpectrum{1}, 'o', 'Color', 'red')
plot(xData, yData,'.', 'MarkerSize', 15);
hold off
grid on
axHan = gca;
set(axHan,...
    'YScale','log',...
    'YMinorGrid', 'off')
xlabel('Synth Freq. (MHz)')
ylabel('Signal')

end