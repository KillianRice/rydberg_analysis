function [yData, yData_error] = Moving_Ave(yData, yData_error, movingwindow)
% calculate a moving average on yData of window movingwindow. Do the same
% for yData_error
yData        = tsmovavg(yData, 's', movingwindow, 1);
yData_error  = tsmovavg(yData_error, 's', movingwindow, 1);
yData        = yData(~isnan(yData));        
yData_error  = yData_error(~isnan(yData));
end

