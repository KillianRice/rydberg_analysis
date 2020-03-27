function funcOut = voigt(analyVar, indivDataset, avgDataset)
    
    %% voight - Joe Whalen 2020.03.26
    % Fits MCS data to a voigt profile given by
    % Re(w(z-z0))/(sigma*sqrt(2pi)) where z = (x+i*gamma)/(sigma*sqrt(2))
    % and Re(w) is the real part of the Faddeeva function
    % Exp[-z^2]Erfc(i*z). We obtain the FWHM by the estimation 
    % fv = 0.5346 * fL + sqrt(0.2166 fL^2 + fG^2) where fL and fG are the
    % FWHM of the gaussian and lorentzian contributions.

    
    function v = form(coeffs,x) 
        a = coeffs(1); % amplitude
        mu = coeffs(2); % line center
        sigma = abs(coeffs(3)); % gaussian sigma
        gamma = abs(coeffs(4)); % lorentzian half width
        offset = coeffs(5); % offset
        
        z = ((x-mu)+1j*gamma)/sigma/sqrt(2);
        
        v = a * real(exp(-z.^2).*(1+1j*erfi(z))) + offset;
    end
    
    indVarField = 'imagevcoAtom'; % independent variable
    depVarField = 'sfiIntegral'; % dependent variable
    
    %% initial guess code
    function initialguess = x0(xdata, ydata)
        initialguess = [1,1,1,1,1];
        initialguess(2) = sum(xdata.*ydata)/sum(ydata);
        initialguess(3) = sqrt(sum((xdata-initialguess(2)).^2))/length(xdata);
        initialguess(4) = initialguess(3);
        initialguess(5) = min(ydata);
        initialguess(1) = max(ydata);% * sqrt(2*pi) * initialguess(3);
    end


    %% options
    % the base_fit function is designed to be flexible, and can accept a
    % lot of different parameters to adjust 
    %%%%% Default Options %%%%%
%         options = struct(...
%         'DataPlotFunction', @defaultDataPlot,...
%         'AvgDataPlotFunction', @defaultAvgDataPlot,...
%         'FitLinePlotFunction', @defaultFitLinePlot,...
%         'AnnotateFunction', @defaultAnnotate,...
%         'IndivFitPlotFunction', @defaultIndivFitPlot,...
%         'PlotIndivFits' , true,...
%         'PlotAvgFits', true,...
%         'XAxisLabel', indVarField ,...
%         'YAxisLabel', depVarField,...
%         'FitLB', [],...
%         'FitUB', [],...
%         'FitOptions', struct('Display','off'),...
%         'PlotInitialGuess', true, ...
%         'InitialGuessPlotFunction', @defaultInitialGuessPlot,...
%         'PlotAll', true,...
%         'PlotAllAvgs', true, ...
%         'CoeffNames', {{}},...
%         'CoeffUnits', {{}},...
%         'YAxisScale', 'linear',...
%         'XAxisScale', 'linear');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    options = struct(...
        'PlotIndivFits', false,...
        'PlotAll', false,...
        'PlotAllAvgs', false,...
        'CoeffNames', {{'Amplitude', 'Line Center', 'Gaussian FWHM', 'Lorentzian FWHM', 'Offset'}},...
        'CoeffUnits', {{'','MHz','MHz','MHz',''}},...
        'AnnotateFunction', @myAnnotate,...
        'PlotInitialGuess', false);
    
    base_fit(analyVar, indivDataset, avgDataset, @form, indVarField, depVarField, @x0, options)

    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end

function an = myAnnotate(coeffs, err, coeffNames, coeffUnits)
    
    dim = [.7 .5 .3 .3];
    
    % convert to relevant parameters
    coeffs(3) = coeffs(3) * 2*sqrt(2*log(2));
    err(3) = err(3) * 2*sqrt(2*log(2));
    
    coeffs(4) = coeffs(4) * 2;
    err(4) = err(4) * 2;
    
    a = 0.5346;
    b = 0.2166;
    
    voigt_fwhm = a * coeffs(4) + sqrt(b*coeffs(4)^2 + coeffs(3)^2);
    voigt_fwhm_err = sqrt(...
        ((a + b * coeffs(4)/(sqrt(coeffs(3)^2+b*coeffs(4)^2))) * err(4))^2 +...
        (coeffs(3)/(sqrt(coeffs(3)^2+b*coeffs(4)^2))*err(3))^2);
    
    if isempty(coeffNames)
        for i = 1:numel(coeffs)
            coeffNames{i} = ['Coeff ', num2str(i)];
        end
    end
    
    if isempty(coeffUnits)
        for i = 1:numel(coeffs)
            coeffUnits{i} = '';
        end
    end
    
    strs = cell(numel(coeffs),1);
    for i = 1:(numel(coeffs)+1)
        if i <= numel(coeffs)
            strs{i} = [coeffNames{i}, ': ', unc_string(coeffs(i),err(i)),...
                ' ', coeffUnits{i}, newline];
        else
            strs{i} = ['Voigt FWHM', ': ', unc_string(voigt_fwhm,voigt_fwhm_err),...
                ' ', 'MHz'];
        end
    end
    
    an = annotation('textbox', dim, 'String', strjoin(strs),...
        'FitBoxToText', 'on', 'BackgroundColor', 'white');
end
