function funcOut = bec_rydberg_lifetime(analyVar, indivDataset, avgDataset)
    
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
    
    form = @(coeffs, x) coeffs(1) * ...
        (exp(-(coeffs(2)+coeffs(3)+coeffs(4))*x) + ...
        coeffs(3)/(coeffs(2)+coeffs(3)) * exp(-coeffs(4)*x).*(1-exp(-(coeffs(2)+coeffs(3))*x)));
    
    indVarField = 'imagevcoAtom'; % independent variable
    depVarField = 'sfiIntegral'; % dependent variable
    
    %% initial guess code
    % fill in this function to estimate the values of the fit parameters,
    % alternatively you can just have thist function return a constant
    % vector if you don't have a simple way of obtaining an initial guess
    function initialguess = x0(xdata, ydata)
        initialguess(1) = max(ydata);
        initialguess(2) = 1/(0.1 * (max(xdata)-min(xdata)));
        initialguess(3) = 1/(0.1 * (max(xdata)-min(xdata)));
        initialguess(4) = 1/(max(xdata)-min(xdata));
    end


    %% options
    % the base_fit function is designed to be flexible, and can accept a
    % lot of different parameters to adjust 
    %%%%% Default Options %%%%%
    %options = struct(...
        %'DataPlotFunction', @defaultDataPlot,...
        %'AvgDataPlotFunction', @defaultAvgDataPlot,...
        %'FitLinePlotFunction', @defaultFitLinePlot,...
        %'AnnotateFunction', @defautAnnotate,...
        %'IndivFitPlotFunction', @defaultIndivFitPlot,...
        %'PlotIndivFits' , true,...
        %'PlotAvgFits', true,...
        %'XAxisLabel', indVarField ,...
        %'YAxisLabel', depVarField,...
        %'FitLB', [],...
        %'FitUB', [],...
        %'FitOptions', struct('Display','off') );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    options = struct( 'XAxisLabel', 'Time (s)', ...
                        'YAxisLabel', 'MCP Counts',...
                        'FitLB', [0,0,0,0],...
                        'PlotAll', false,...
                        'PlotIndivFits',false,...
                        'PlotAllAvgs', true,...
                        'CoeffNames', {{'N_0','\Gamma_{AI}','\Gamma_L','\tau_R'}},...
                        'CoeffUnits', {{'','\mus^{-1}','\mus^{-1}','\mus'}},...
                        'AnnotateFunction', @myAnnotate,...
                        'YAxisScale', 'log');
    
    base_fit(analyVar, indivDataset, avgDataset, form, indVarField, depVarField, @x0, options)

    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end

function an = myAnnotate(coeffs, err, coeffNames, coeffUnits)
    
    coeffs(2:3) = coeffs(2:3) * 1e-6;
    err(2:3) = err(2:3) * 1e-6;
    coeffs(4) = 1/coeffs(4)*1e6;
    err(4) = abs(0.5e6*(1/(coeffs(4)+err(4))-1/(coeffs(4)-err(4))));

    dim = [.25 .6 .3 .3];
    
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
    for i = 1:numel(coeffs)
        if i < numel(coeffs)
            strs{i} = [coeffNames{i}, ': ', unc_string(coeffs(i),err(i)),...
                ' ', coeffUnits{i}, newline];
        else
            strs{i} = [coeffNames{i}, ': ', unc_string(coeffs(i),err(i)),...
                ' ', coeffUnits{i}];
        end
    end
    
    an = annotation('textbox', dim, 'String', strjoin(strs),...
        'FitBoxToText', 'on', 'BackgroundColor', 'white');
end

