close all
files = 1:9;
numfiles = length(files);
[data, xData, yData, legcell] = deal(cell(size(files)));
for qq = 1:numfiles 
    kk = files(qq);
    data{qq} = dlmread(['n60ThermalSpectrum_10usExposure_0' mat2str(kk) 'VUV_2016_06_19.csv']);
    xData{qq} = data{qq}(:,1);
    yData{qq} = data{qq}(:,2);
end

powerinmW = {6 21 44 72 102 130 153 170 183 190};

figure
hold on
 
for qq = 1:numfiles 
    kk = files(qq);
    plot(xData{qq}, yData{qq}/powerinmW{kk}, 'Color', FrancyColors3(numfiles, qq))
    legstr = mat2str(powerinmW{qq});
    legcell{qq} = legstr;
end
set(gca, 'Color', [.8 .8 .8])
h =legend(legcell);
v = get(h,'title');
set(v,'string','UV Power (mW)');
set(h, 'Location', 'Best')
xlabel('UV Detuning (MHz)')
ylabel('Signal (Counts/us/mW)')


% files2 = [5];
% numfiles2 = length(files2);
% for qq = 1:numfiles2 
%     kk = files2(qq);
%     data2{qq} = dlmread(['n60ThermalSpectrum_02usExposure_03VUV_0' mat2str(kk) 'Vred_2016_06_19.csv']);
%     xData2{qq} = data2{qq}(:,1);
%     yData2{qq} = data2{qq}(:,2);
% end

% norm = [1.6 1.15 1];
% norm = [1/7];
% 
% for qq = 1:numfiles2
%     kk = files2(qq);
%     plot(xData2{qq}, norm(qq)*yData2{qq}/powerinmW{3}, 'o','Color', FrancyColors3(numfiles, qq))
% %     legstr = mat2str(powerinmW{qq});
% %     legcell{qq} = legstr;
% end
% legend('3V red', '4V red', '5V red')
