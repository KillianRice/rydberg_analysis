function funcOut = beating_horizontal_trap_frequencies(analyVar, indivDataset, avgDataset)
    
    %% Fit_Template - Joe Whalen 2019.10.02
    % Fit the vertical trap oscillation frequency using the dipole
    % (sloshing) mode.
    % Form: A * sin(2pi * f * t + phi) * exp(-Gamma * t) + c
    % coeffs(1): Amplitude
    % coeffs(2): Frequency 1 (hz)
    % coeffs(3): Phase (rad)
    % coeffs(4): Decay rate (s^-1)
    % coeffs(5): Offset
    % x: time (ms)
    
    form = @(coeffs, x) coeffs(1)*sin(2*pi*coeffs(2)*x/1000+coeffs(3)) + ...
                        coeffs(4)*sin(2*pi*coeffs(5)*x/1000+coeffs(6)) + coeffs(7);
    
    indVarField = 'imagevcoAtom'; % independent variable
    depVarField = 'cntrX'; % dependent variable
    
    %% initial guess code
    % fill in this function to estimate the values of the fit parameters,
    % alternatively you can just have thist function return a constant
    % vector if you don't have a simple way of obtaining an initial guess
    function initialguess = x0(xdata, ydata)
        initialguess = zeros(7,1);
        initialguess(1) = (max(ydata)-min(ydata))/4;
        initialguess(2) = 66;
        initialguess(3) = 0;
        initialguess(4) = (max(ydata)-min(ydata))/4;
        initialguess(5) = 70;
        initialguess(6) = -pi;
        initialguess(7) = mean(ydata);
        

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
        %'FitOptions', struct('Display','off'),...
        %'PlotInitialGuess', false, ...
        %'InitialGuessPlotFunction', @defaultInitialGuessPlot);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    options = struct('PlotInitialGuess', false);
    
    base_fit(analyVar, indivDataset, avgDataset, form, indVarField, depVarField, @x0, options)

    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end



