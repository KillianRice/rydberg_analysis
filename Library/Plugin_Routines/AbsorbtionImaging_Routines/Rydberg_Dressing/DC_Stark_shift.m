function DC_Stark_shift(analyVar, lineCenter)
%DC_STARK_SHIFT - Takes the line centers from the spectrum fitting and fits to parabola
%   This function will fit the DC stark shift measured by applying a static electric field to Rydberg atoms
%
% INPUTS:
%   avgDataset - Cell of structures containing data about the average of several scans
%   lineCenter - Vector of line centers from spectrum fitting
%
% OUTPUTS:
%   none
%
% PLOTS:
%   Figure (# not assigned) - Plot the line centers and the fit curve

%% Initialize Variables
quadModel  = fittype('a*(x - x0)^2 + c','coefficients',{'a','x0','c'});
scalModel  = @(coeffs,x) (coeffs(1)/2.*(x - coeffs(2)).^2);
indModel   = @(x) linspace(min(x) - abs(mean(x)/2), max(x) + abs(mean(x)/2), 1e3);
fieldModel = @(x,offset) .11148*(x - offset) - .62417; %V/cm

%% Voltage on Plate
% First fit data with voltage on plate. This finds the voltage needed to zero the field
% Save structure variables into convenient local variables
indVolt = analyVar.uniqScanList;
depVar  = lineCenter(:,1)*1e-6; % Change to MHz
errBar  = lineCenter(:,2)*1e-6;

%% Initial Guesses for fit - Voltage
aInit  = 1;
x0Init = mean(indVolt);
cInit  = min(depVar);

%% Apply Fit model - Voltage
quadFit   = fit(indVolt,depVar,quadModel,'StartPoint',[aInit x0Init cInit]);
coeffVolt = coeffvalues(quadFit);

%% Electric field applied
% Using the zero field point, turn voltage into Electric field and refit for polarizability
% Scale independent variable by electric field estimate
indElec = fieldModel(indVolt,(coeffVolt(2) - 5.6));
depElec = lineCenter(:,1)*1e-6 - coeffVolt(3); % Change to MHz

%% Initial Guesses for fit - Electric Field
x0Init = mean(indElec);

%% Apply Fit model - Electric Field
elecFit   = NonLinearModel.fit(indElec,depElec,scalModel,[aInit, x0Init],...
    'CoefficientNames',{'Polarizability','x0'});
coeffsElec = double(elecFit.Coefficients);

%% Plot the line centers and model - Voltage Plot
figVolt = figure;
hanVolt = plot(indModel(indVolt),quadFit(indModel(indVolt)),'r-',indVolt,depVar,'bo');
grid on; hold on
hanErr = errorbar(indVolt,depVar,errBar); 
xlabel('Voltage Applied to Plate [V]','FontSize',24,'FontWeight','Bold')
ylabel('Line Center [MHz]','FontSize',24,'FontWeight','Bold');
set(gca,'FontSize',16)
set(hanErr,'LineStyle','none')
set(hanVolt(1),'LineWidth',3)
set(hanVolt(2),'MarkerSize',8,'MarkerFaceColor','b')
set(gcf,'Name','DC Stark Shift - Applied Voltage');

% Create textbox
strTextbox = {'y = a*(x - x_0)^2 + c','',sprintf('a = %g [MHz/V^2]',coeffVolt(1)),sprintf('c = %g [MHz]',coeffVolt(3)),sprintf('x_0 = %g [V]',coeffVolt(2))};
annotation(figVolt,'textbox',[0.2931875 0.677601809954751 0.177125 0.180327705463753],...
    'String',strTextbox,...
    'FontWeight','bold',...
    'FontSize',16,...
    'FitBoxToText','on',...
    'BackgroundColor',[1 0.949019610881805 0.866666674613953]);

%% Plot the line centers and model - Electric Field Plot
figElec = figure;
hanElec = plot(indModel(indElec),elecFit.predict(indModel(indElec)'),'r-',indElec,depElec,'bo');
grid on; hold on
hanErr = errorbar(indElec,depElec,errBar); 
xlabel('Scaled Electric Field [V/cm]','FontSize',24,'FontWeight','Bold')
ylabel('Line Center Shift [MHz]','FontSize',24,'FontWeight','Bold');
set(gca,'FontSize',16)
set(hanErr,'LineStyle','none')
set(hanElec(1),'LineWidth',3)
set(hanElec(2),'MarkerSize',8,'MarkerFaceColor','b')
set(gcf,'Name','DC Stark Shift - Electric Field');

% Create textbox
 strTextbox = {'y = a/2*(x - x_0)^2','',sprintf('a = %g +/- %g [MHz/(V/cm)^2]',coeffsElec(1,1:2)),...
    sprintf('x_0 = %g [(V/cm)]',coeffsElec(2,1)),'', sprintf('E-Field Scaling: .111*x - %g',floor(.11148*coeffVolt(2)*1e3)*1e-3)};
annotation(figElec,'textbox',[0.2931875 0.677601809954751 0.177125 0.180327705463753],...
    'String',strTextbox,...
    'FontWeight','bold',...
    'FontSize',16,...
    'FitBoxToText','on',...
    'BackgroundColor',[1 0.949019610881805 0.866666674613953]);
end

