function [rabiFreq, lineCenter, fullWidth] = Ext_Rabi_Freq(analyVar,indivDataset,scaleFuncs)
% Fits the number spectrum and extracts Rabi frequency based on the lineshape
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   rabiFreq   - Vector the length of numBasenamesAtom containing the fit
%                Rabi frequencies (Hz) and standard error
%   lineCenter - Vector the length of numBasenamesAtom containing the fit
%                line center positions (Hz) and standard error
%   fullWidth  - Vector the length of numBasenamesAtom containing the fit
%                full widths of the spectra (Hz) and standard error

%% Define Physical Functions Used in Calculations
% Lineshape function - gaussian
% coeffs has elements coeffs = [amplitude, line center, halfwidth, num. offset]
specFit = @(coeffs,x) (coeffs(4) - coeffs(1)*exp(-(x-coeffs(2)).^2/(2*coeffs(3)^2)));

% Rabi Frequency 
% Derivation included in folder
rabiFreqFunc = @(specCoeffs,expTime) (2*pi).^(5/4).*sqrt(specCoeffs(2)*specCoeffs(1)/(specCoeffs(3)*expTime));
rabiFreqErr  = @(specCoeffs,expTime) sqrt(1/4*specCoeffs(2,2)^2/specCoeffs(2) ... 
                                        + 1/4*specCoeffs(1,2)^2/specCoeffs(1) ...
                                        - 1/4*specCoeffs(3,2)^2/specCoeffs(3)^3);
% Full Width Half Max
fullwidthFunc = @(halfwidth) halfwidth*2;

%% Initialize loop variables
[rabiFreq, lineCenter, fullWidth] = deal(zeros(length(analyVar.numBasenamesAtom),2));

%% Define Plot parameters
rabiFitFig = figure;
[subPlotRows,subPlotCols] = optiSubPlotNum(analyVar.numBasenamesAtom);

%% Loop through each batch file listed in basenamevectorAtom
for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    indVar    = scaleFuncs.IndVar(indivDataset{basenameNum}.imagevcoAtom);
    winTotNum = indivDataset{basenameNum}.winTotNum;
    expTime   = scaleFuncs.ExpTime(analyVar.expTime(basenameNum));
    
    % Initial Guesses
    smoothNum = smooth(winTotNum,'sgolay',1); % smooth for helping make guesses
    [minVal, minLoc] = min(smoothNum); % find location of minimum
    
    initOffset = mean(winTotNum([1:5 end-5 end])); % Mean of first 5 and last 5 points
    initCenter = indVar(minLoc);                   % Location of minimum in smoothed data
    initAmp    = initOffset - minVal;              % Value below guessed offset
    initWidth  = 0.5*1e6;                          % Fixed since guess is not sensitive
    
    % Fitting routine
    specFitModel = NonLinearModel.fit(indVar',winTotNum,specFit,[initAmp initCenter  initWidth initOffset],...
        'CoefficientNames',{'Amplitude','Line Center','Halfwidth','Number Offset'});

    % Calculate output quantities
    rabiFreq(basenameNum,1)   = rabiFreqFunc(double(specFitModel.Coefficients({'Amplitude','Halfwidth','Number Offset'},'Estimate')),expTime);
    rabiFreq(basenameNum,2)   = rabiFreqErr(double(specFitModel.Coefficients({'Amplitude','Halfwidth','Number Offset'},{'Estimate','SE'})));
    
    lineCenter(basenameNum,:) = double(specFitModel.Coefficients('Line Center',{'Estimate', 'SE'}));
    
    fullWidth(basenameNum,1)  = fullwidthFunc(double(specFitModel.Coefficients('Halfwidth','Estimate')));
    fullWidth(basenameNum,2)  = fullwidthFunc(double(specFitModel.Coefficients('Halfwidth','SE')));
    
    % Plot number vs. fit for inspection
    figure(rabiFitFig); subplot(subPlotRows,subPlotCols,basenameNum);
    fitIndVar = linspace(min(indVar),max(indVar),1e4)';
    dataHan   = plot(indVar*1e-6,winTotNum,fitIndVar*1e-6,specFitModel.predict(fitIndVar));
    %%% Plot axis details
    title(num2str(analyVar.timevectorAtom(basenameNum)));
    xlabel('MHz'); grid on; axis tight
    set(dataHan(1),'LineStyle','none','Marker','*'); set(dataHan(2),'LineWidth',2)
    if basenameNum == analyVar.numBasenamesAtom;
        set(gcf,'Name','Rabi Frequency Fits');
    end
end

