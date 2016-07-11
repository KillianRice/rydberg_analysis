function [rabi_freq, lineCenter] = fit_bragg_spectra(indVarCell,partNumCell,labelVec,expTime,figSpec)
% Fits the number spectrum to a one body loss equation
% Derivation included in folder
% Lineshape function - Lorentzian with broadening term
%
% INPUTS:
%   indVarCell  - Cell of vectors containing the independent variables
%   partNumCell - Cell of vectors containing the particle number that is
%                 the specctrum to be analyzed
%   labelVec    - Vector of identifying labels for each scan that is analyzed
%   expTime     - Vector of exposure times for each dataset
%
% OUTPUTS:
%   amplitude   - Vector the length of numBasenamesAtom containing the fit
%                 amplitudes and standard error
%   lineCenter  - Vector the length of numBasenamesAtom containing the fit
%                 line center positions (Hz) and standard error

%% Initialize loop variables
[rabi_freq, lineCenter] = deal(zeros(length(indVarCell),2));

%% Define Plot parameters
specFitFig = figure;
[subPlotRows,subPlotCols] = optiSubPlotNum(length(indVarCell));

%% Loop through each batch file or average scan value
for iterVar = 1:length(indVarCell)
    % Reference variables in structure by shorter names for convenience
    indVar = indVarCell{iterVar};
    totNum = partNumCell{iterVar};
    time   = expTime(iterVar);
    
    %% Define Physical Functions Used in Calculations
    % coeffs has elements coeffs = [rabi_freq, line center, offset]
    % Eq. 7.27 from Foot
    specFit = @(coeffs,x) coeffs(1)^2./(coeffs(1)^2+((2*pi)*(x-coeffs(2))).^2).*(sin(sqrt(coeffs(1)^2+((2*pi)*(x-coeffs(2))).^2)*time/2)).^2;

    %% Initial Guesses
    smoothNum = smooth(totNum,'sgolay',1); % smooth for helping make guesses
    [maxVal, minLoc] = max(smoothNum); % find location of minimum
    
    %initOffset = mean(totNum([1:5 end-5 end])); % Mean of first 5 and last 5 points
    initCenter = indVar(minLoc)*1e6; % Location of minimum in smoothed data
    peakLoss   = maxVal;             % Value below guessed offset
    
    % Function to estimate rabi frequency based on peak loss
    initRabi = 2*asin(sqrt(peakLoss))/time;
    
    %% Fitting routine
    specFitModel = NonLinearModel.fit(indVar'*1e6,totNum,specFit,[initRabi initCenter],...
        'CoefficientNames',{'Rabi Frequency','Line Center'});

    % Calculate output quantities
    rabi_freq(iterVar,:)  = double(specFitModel.Coefficients('Rabi Frequency',{'Estimate', 'SE'}));
    
    lineCenter(iterVar,:) = double(specFitModel.Coefficients('Line Center',{'Estimate', 'SE'}));
    
    % Plot number vs. fit for inspection
    figure(specFitFig); subplot(subPlotRows,subPlotCols,iterVar);
    fitIndVar = linspace(min(indVar),max(indVar),1e4)';
    dataHan   = plot(indVar,totNum,fitIndVar,specFitModel.predict(fitIndVar*1e6));
    %%% Plot axis details
    title(num2str(labelVec(iterVar)));
    xlabel('MHz'); grid on; axis tight
    set(dataHan(1),'LineStyle','none','Marker','*'); set(dataHan(2),'LineWidth',2)
    if iterVar == length(indVarCell);
        set(gcf,'Name','Bragg Spectra Fits');
    end
end

%% Plot mean fit values on the original plot
figure(figSpec); 
figChld = get(figSpec,'Children'); set(figSpec,'CurrentAxes',figChld(3)); hold on
fitHan = plot(fitIndVar,specFit([mean(rabi_freq(:,1)) mean(lineCenter(:,1))],fitIndVar*1e6));
set(fitHan,'LineWidth',3,'LineStyle',':'); axis tight
end