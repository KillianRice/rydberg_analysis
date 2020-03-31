function default_spectrum_plot(analyVar,figNum,data,labels,menuBar)
% Function to define default plotting values for the Spectrum_fit routine
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%
% OUTPUTS:
%

%% Save inputs into more recognizable variables
indVar    = data(:,1);
depenVar  = data(:,2);
error     = data(:,3);
xLabelStr = labels{1};
yLabelStr = labels{2};

%% Define plot
figure(figNum)
plot(indVar,depenVar,'o','Color',analyVar.COLORS(1,:),'MarkerSize',analyVar.markerSize,'LineWidth',2);
hold on; grid on; 
errHan = errorbar(indVar,depenVar,error,'.');
xlabel(xLabelStr,'FontSize',analyVar.axisfontsize,'FontWeight','bold');
ylabel(yLabelStr,'FontSize',analyVar.axisfontsize,'FontWeight','bold');
set(gca,'FontSize',analyVar.axisfontsize - 4,'FontWeight','bold');
set(gcf,'Name',menuBar);
end