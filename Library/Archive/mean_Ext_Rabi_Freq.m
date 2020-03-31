function [rabiFreq, lineCenter, fullWidth] = Ext_Rabi_Freq(analyVar,avgDataset,scaleFuncs)
% Fits the average number spectrum and extracts Rabi frequency based on the lineshape
% Very similar to Ext_Rab_Freq but expecting the averaged dataset instead
% of individual scans.
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   avgDataset   - Cell of structures containing grouped data for averaging
%
% OUTPUTS:
%   rabiFreq   - Vector the length of numBasenamesAtom containing the fit
%                Rabi frequencies (Hz) and standard error
%   lineCenter - Vector the length of numBasenamesAtom containing the fit
%                line center positions (Hz) and standard error
%   fullWidth  - Vector the length of numBasenamesAtom containing the fit
%                full widths of the spectra (Hz) and standard error
%

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
[subPlotRows,subPlotCols] = optiSubPlotNum(length(analyVar.uniqScanList));

%% Loop through all unique values used for averaging
for uniqScanIter = 1:length(analyVar.uniqScanList);
    % Assign basenameNum that matches current for indexing into analyVar
    basenameNum = analyVar.posOccurUniqVar{uniqScanIter}(1);
    
    % Reference variables in structure by shorter names for convenience
    indVar    = scaleFuncs.IndVar(avgDataset{uniqScanIter}.simScanIndVar);
    winTotNum = avgDataset{uniqScanIter}.avgTotNum;
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
    rabiFreq(uniqScanIter,1)   = rabiFreqFunc(double(specFitModel.Coefficients({'Amplitude','Halfwidth','Number Offset'},'Estimate')),expTime);
    rabiFreq(uniqScanIter,2)   = rabiFreqErr(double(specFitModel.Coefficients({'Amplitude','Halfwidth','Number Offset'},{'Estimate','SE'})));
    
    lineCenter(uniqScanIter,:) = double(specFitModel.Coefficients('Line Center',{'Estimate', 'SE'}));
    
    fullWidth(uniqScanIter,1)  = fullwidthFunc(double(specFitModel.Coefficients('Halfwidth','Estimate')));
    fullWidth(uniqScanIter,2)  = fullwidthFunc(double(specFitModel.Coefficients('Halfwidth','SE')));
    
    % Plot number vs. fit for inspection
    figure(rabiFitFig); subplot(subPlotRows,subPlotCols,uniqScanIter);
    fitIndVar = linspace(min(indVar),max(indVar),1e4)';
    dataHan   = plot(indVar*1e-6,winTotNum,fitIndVar*1e-6,specFitModel.predict(fitIndVar));
    %%% Plot axis details
    title(num2str(analyVar.uniqScanList(uniqScanIter)));
    xlabel('MHz'); grid on; axis tight
    set(dataHan(1),'LineStyle','none','Marker','*'); set(dataHan(2),'LineWidth',2)
    if uniqScanIter == length(analyVar.uniqScanList);
        set(gcf,'Name','Rabi Frequency Fits');
    end
end

