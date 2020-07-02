function funcOut = vertical_trap_frequency(analyVar, indivDataset, avgDataset)
    
    %% Fit_Template - Joe Whalen 2019.10.02
    % Fit the vertical trap oscillation frequency using the dipole
    % (sloshing) mode.
    % Form: A * sin(2pi * f * t + phi) * exp(-Gamma * t) + c
    % coeffs(1): Amplitude
    % coeffs(2): Frequency (hz)
    % coeffs(3): Phase (rad)
    % coeffs(4): Decay rate (s^-1)
    % coeffs(5): Offset
    % x: time (ms)
    
    form = @(coeffs, x) coeffs(1) * sin(2*pi*coeffs(2)* x / 1000 + coeffs(3)) .* exp(-coeffs(4)*x / 1000) + coeffs(5); % your fit function here 
    
    indVarField = 'imagevcoAtom'; % independent variable
    depVarField = 'cntrY'; % dependent variable
    
    %% initial guess code
    % fill in this function to estimate the values of the fit parameters,
    % alternatively you can just have thist function return a constant
    % vector if you don't have a simple way of obtaining an initial guess
    function initialguess = x0(xdata, ydata)
        initialguess = zeros(5,1);
        initialguess(1) = (max(ydata)-min(ydata))/2;
        initialguess(2) = 82;
        initialguess(3) = 0;
        initialguess(4) = 0;
        initialguess(5) = mean(ydata);
        
        disp(initialguess)
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
    
    options = struct('PlotInitialGuess', false,...
                        'DataPlotFunction', @myDataPlot,...
                        'AnnotateFunction', @myAnnotate,...
                        'XAxisLabel' , 'Time (ms)',...
                        'YAxisLabel', 'Vertical Displacement (px)');
    
    base_fit(analyVar, indivDataset, avgDataset, form, indVarField, depVarField, @x0, options)

    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end

function h = myDataPlot(x,y,i,analyVar)
    h = plot(x,y,...
    'LineStyle','none',...
    'Marker', 'o',...
    'MarkerSize', analyVar.markerSize,...
    'MarkerFaceColor', analyVar.COLORS(i,:),...
    'MarkerEdgeColor', 'k',...
    'Color', analyVar.COLORS(i,:));
end

function an = myAnnotate(coeffs,uncs,coeffNames,coeffUnits)
    dim = [0.2, 0.2, 0.3, 0.3];
    str = strcat('Trap Frequency: ', num2str(coeffs(2),'%0.2f Hz'));
    an = annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on',...
        'BackgroundColor','w');
end


