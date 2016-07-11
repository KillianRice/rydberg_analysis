function [amplitude, lineCenter, fullWidth] = one_body_spectra(indVarCell,partNumCell,labelVec)
% Fits the number spectrum to a one body loss equation
% Derivation included in folder
% Lineshape function - Lorentzian with broadening term
%
% INPUTS:
%   indVarCell  - Cell of vectors containing the independent variables
%   partNumCell - Cell of vectors containing the particle number that is
%                 the specctrum to be analyzed
%   labelVec    - Vector of identifying labels for each scan that is analyzed
%
% OUTPUTS:
%   amplitude   - Vector the length of numBasenamesAtom containing the fit
%                 amplitudes and standard error
%   lineCenter  - Vector the length of numBasenamesAtom containing the fit
%                 line center positions (Hz) and standard error
%   fullWidth   - Vector the length of numBasenamesAtom containing the fit
%                 full widths of the spectra (Hz) and standard error

%% Define Physical Functions Used in Calculations
% coeffs has elements coeffs = [amplitude, line center, halfwidth, num. offset]
%specFit = @(coeffs,x) coeffs(4)*(1 - coeffs(1)/coeffs(3)*exp(-(x-coeffs(2)).^2/(2*coeffs(3)^2))); % Small time approx.
specFit = @(coeffs,x) coeffs(4)*exp(coeffs(1)/coeffs(3)*exp(-(x-coeffs(2)).^2/(2*coeffs(3)^2)));

% Full Width Half Max
fullwidthFunc = @(halfwidth) 2*sqrt(2*log(2))*halfwidth;

%% Initialize loop variables
[amplitude, lineCenter, fullWidth] = deal(zeros(length(indVarCell),2));

%% Define Plot parameters
specFitFig = figure;
[subPlotRows,subPlotCols] = optiSubPlotNum(length(indVarCell));

%% Loop through each batch file or average scan value
for iterVar = 1:length(indVarCell)
    % Reference variables in structure by shorter names for convenience
    indVar = indVarCell{iterVar}*24e6;
    totNum = partNumCell{iterVar};

    % Initial Guesses
    smoothNum = smooth(totNum,'sgolay',1); % smooth for helping make guesses
    [minVal, minLoc] = max(smoothNum); % find location of minimum
    
    initOffset = mean(totNum([1:5 end-5 end])); % Mean of first 5 and last 5 points
    initCenter = indVar(minLoc);                % Location of minimum in smoothed data
    initWidth  = 32e6;                       % Fixed since guess is not sensitive
    initAmp    = (initOffset + minVal);         % Value below guessed offset
    
    % Fitting routine
    specFitModel = NonLinearModel.fit(indVar',totNum,specFit,[initAmp initCenter initWidth initOffset],...
        'CoefficientNames',{'Amplitude','Line Center','Halfwidth','Number Offset'});

    % Calculate output quantities
    amplitude(iterVar,:)  = double(specFitModel.Coefficients('Amplitude',{'Estimate', 'SE'}));
    
    lineCenter(iterVar,:) = double(specFitModel.Coefficients('Line Center',{'Estimate', 'SE'}));
    
    fullWidth(iterVar,1)  = fullwidthFunc(double(specFitModel.Coefficients('Halfwidth','Estimate')));
    fullWidth(iterVar,2)  = fullwidthFunc(double(specFitModel.Coefficients('Halfwidth','SE')));
    
    % Plot number vs. fit for inspection
    figure(specFitFig); subplot(subPlotRows,subPlotCols,iterVar);
    fitIndVar = linspace(min(indVar),max(indVar),1e4)';
    dataHan   = plot(indVar*1e-6,totNum,fitIndVar*1e-6,specFitModel.predict(fitIndVar));
    %%% Plot axis details
    title(num2str(labelVec(iterVar)));
    xlabel('MHz'); grid on; axis tight
    set(dataHan(1),'LineStyle','none','Marker','*'); set(dataHan(2),'LineWidth',2)
    if iterVar == length(indVarCell);
        set(gcf,'Name','Spectra Fits');
    end
end

