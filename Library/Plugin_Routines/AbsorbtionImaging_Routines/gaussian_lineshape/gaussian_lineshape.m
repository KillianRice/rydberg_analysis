function [output_args] = gaussian_lineshape(analyVar,indivDataset,avgDataset)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if analyVar.UseMCS == 1
    indivDataset = param_extract_sfi_integral(analyVar, indivDataset);
end

NumStates = analyVar.numBasenamesAtom;

%% Frequency
Frequencies = [];
for mbIndex = 1:NumStates
    Frequencies = cat(1, Frequencies, indivDataset{mbIndex}.imagevcoAtom);
end
unique_Freq = unique(Frequencies,'sorted');

NumUniqueFreq = length(unique_Freq);
% FreqStruct = cell(1, NumUniqueFreq);
% for uniqueFreqIndex = 1:NumUniqueFreq 
%     FreqStruct{uniqueFreqIndex} = unique_Freq(uniqueFreqIndex);
% end

UniqueFreqIndex = cell(1,NumStates);
for mbIndex = 1:NumStates
    UniqueFreqIndex{mbIndex} = arrayfun(@(x) find(unique_Freq == x),...
        indivDataset{mbIndex}.imagevcoAtom,'UniformOutput',0);
end

%% Aggregate
[yData]  = deal(cell(NumUniqueFreq, 1));
[yData_Average, yData_error]  = deal(nan(NumUniqueFreq, 1));
% % % for uniqueFreqIndex = 1:NumUniqueFreq
% % %     [yData{uniqueFreqIndex} , yData_Average{uniqueFreqIndex} , yData_error{uniqueFreqIndex} ]= deal(cell(NumUniqueDensity, 1));
% % % end

for mbIndex = 1:NumStates
    NumFreq = indivDataset{mbIndex}.CounterAtom;
    for bIndex = 1:NumFreq
        if analyVar.UseMCS == 1
            Signal = indivDataset{mbIndex}.sfiIntegral(bIndex);
    %         Signal = nansum(Signal,1);
    %         Signal = squeeze(Signal);
        else
            Signal = indivDataset{mbIndex}.winTotNum(bIndex);
        end
        yData{UniqueFreqIndex{mbIndex}{bIndex}} = cat(1, yData{UniqueFreqIndex{mbIndex}{bIndex}}, Signal);

    end
end

for uniqueFreqIndex = 1:NumUniqueFreq
        yData_Average(uniqueFreqIndex) = mean(yData{uniqueFreqIndex});
%         yData_error(uniqueFreqIndex)= std(yData{uniqueFreqIndex})/(length(yData{uniqueFreqIndex}))^0.5;
        yData_error(uniqueFreqIndex)= std(yData{uniqueFreqIndex});
end

xData = unique_Freq;

[amplitude_gaussian, center_gaussian, sigma_gaussian, offset_gaussian] = gaussian_fit2(xData, yData_Average, 1, 1);
integral = trapz(xData,yData_Average-offset_gaussian(1));
fitted_integral = amplitude_gaussian(1) * sigma_gaussian(1) * sqrt(2*pi);

guassian_FWHM = 2*sigma_gaussian(1)*(2*log(2))^0.5;
guassian_FWHM_error = 2*sigma_gaussian(2)*(2*log(2))^0.5;
center_gaussian
guassian_FWHM
guassian_FWHM_error
integral
fitted_integral

xDataGaussian = linspace(min(xData), max(xData), 1e3);

figure;
hold on;
errorbar(unique_Freq,yData_Average,yData_error,'ored');
plot(xDataGaussian,offset_gaussian(1)+amplitude_gaussian(1)*gaussmf(xDataGaussian, [sigma_gaussian(1), center_gaussian(1)] ), 'blue','LineWidth',2);
dim = [.2 .5 .3 .3];
str_cntr = strcat('Gaussian center: ',num2str(center_gaussian(1)));
str_sigma = strcat('Gaussian FWHM: ',num2str(guassian_FWHM));
str = [str_cntr, char(10),str_sigma];
annotation('textbox',dim,'String',str,'FitBoxToText','on','BackgroundColor','white');
grid on;
xlabel(analyVar.xDataLabel);
ylabel('Atom Number');
hold off;

output_args = [unique_Freq, yData_Average];

end

