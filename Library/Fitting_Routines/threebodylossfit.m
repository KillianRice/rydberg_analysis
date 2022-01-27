function funcOut = threebodylossfit(analyVar, indivDataset, avgDataset)
    
    %% Fit_Template - Joe Whalen 2019.10.02
    % This function calls the base_fit script that does all of the fitting
    % and displays all of the plots for a given fitting routine. To use
    % this template, first save it as a new script with the name you want
    % to give to your fit function. Next, fill in your fit form with an
    % anonymous function handle with argumnents coeffs and x, coeffs is the
    % vector of free fit parameters and x is the vector of x coordinates
    % over which the function will be evaluated. Declare the independent
    % and dependent variables to be fitted with indVarField and
    % depVarField. These variables are strings that are the names of a
    % field in indivDataset. Typically the indVarField is imagevcoAtom, the
    % variable that was scanned during the experiment.
    
    form = @(coeffs, x) coeffs(3).*sqrt(-coeffs(2) + exp(-2*coeffs(1)^2))./sqrt(-coeffs(2) + exp(2*coeffs(1).*(x-coeffs(1)))) % your fit function here 
    
    indVarField = 'imagevcoAtom'; % independent variable
    depVarField = 'winTotNum'; % dependent variable
    
    %% initial guess code
    % fill in this function to estimate the values of the fit parameters,
    % alternatively you can just have thist function return a constant
    % vector if you don't have a simple way of obtaining an initial guess
    function initialguess = x0(xdata, ydata)
        % code
        % that
        % guesses
        % initial
        % params
        % can also return a constant vector with length equal to the number
        % of parameters in the fit function
        initialguess(3) = max(ydata);
        initialguess(1) = (max(xdata)-min(xdata))/2;
        initialguess(2) = (max(xdata)-min(xdata))/3;
        initialguess(2) = 0.1;
        initialguess(1) = 0.0002;
        
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
%         'FitTitle', (call from dbstack),...
%         'Statistics', 'gaussian');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    options = struct(...
        'PlotIndivFits', false,...
        'PlotAll', false,...
        'PlotAllAvgs', false,...
        'CoeffNames', {{'\Gamma_1', '\Gamma_2', 'Ampl.'}},...
        'CoeffUnits', {{'ms^{-1}','ms^{-1}',''}},...
        'AnnotateFunction', @myAnnotate,...
        'PlotInitialGuess', false);
    
    base_fit(analyVar, indivDataset, avgDataset, form, indVarField, depVarField, @x0, options);
    xlabel('Hold time (ms)');
    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end

function an = myAnnotate(coeffs, err, coeffNames, coeffUnits)
    dim = [.5 .5 .3 .3];
    coeffs(2) = coeffs(2); 
    err(2) = err(2);  
    strs = cell(3,1);
    for i = 1:3
        if i <= numel(coeffs)
            strs{i} = [coeffNames{i}, ': ', unc_string(coeffs(i),err(i)),...
                ' ', coeffUnits{i},newline];
            strs{i};
        end
    end
    
    
    an = annotation('textbox', dim, 'String', strjoin(strs),...
        'FitBoxToText', 'on', 'BackgroundColor', 'white');
end