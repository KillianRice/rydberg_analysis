% Script to get data from current 1D figure and write to an XLS file.
% Data will be written to the sheet specified by the legend entry for that data
% Written by Jim - 2015.01.29

% May mess up if there are multiple axes on a single figure

%% Initialize variables
filename = 'dataOut.xls';

% Get data from figure
figData = get(get(get(gcf,'CurrentAxes'),'Children'));

%% Loop through data on current axes and save
for i = 1:length(figData)
    sheetName = char(figData(i).DisplayName);
    xlswrite(filename,[figData(i).XData' figData(i).YData'],sheetName)
end