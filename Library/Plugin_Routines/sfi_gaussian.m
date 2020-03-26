function funcOut = sfi_gaussian(analyVar, indivDataset, avgDataset)

    form = @(coeffs,x) coeffs(1) * exp(-(x-coeffs(2)).^2 ./ (2*coeffs(3)^2)) + coeffs(4);

    indVarField = 'imagevcoAtom';
    depVarField = 'sfiIntegral';
    
   

    function x0 = initial_guess(x, y)

        x0 = zeros(4,1);
        x0(1) = max(y);
        x0(2) = sum(x.*y)/sum(y);
        x0(3) = sqrt(sum((x-x0(2)).^2.*y)/sum(y));
        x0(4) = min(y);

    end

    %% options
    % the base_fit function is designed to be flexible, and can accept a
    % lot of different parameters to adjust 
    %%%%% Default Options %%%%%
%     options = struct(...
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
    
    options = struct(...
        'PlotIndivFits', false,...
        'PlotAll', false,...
        'PlotAllAvgs', false,...
        'CoeffNames', {{'Amplitude', 'Line Center', 'FWHM', 'Offset'}},...
        'CoeffUnits', {{'','MHz','MHz',''}},...
        'AnnotateFunction', @myAnnotate);
    
    base_fit(analyVar, indivDataset, avgDataset, form, indVarField, depVarField, @initial_guess, options)

    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end
function h = myplot(x,y,analyVar,i)
    h = plot(x,y,...
        'LineStyle','none',...
        'Marker', 'o',...
        'MarkerSize', analyVar.markerSize,...
        'MarkerFaceColor', analyVar.COLORS(i,:),...
        'MarkerEdgeColor', 'none',...
        'Color', analyVar.COLORS(i,:));
end

function h = myerrorbar(x,y,yerr,analyVar,i)
    h = errorbar(x,y,yerr,...
        'LineStyle','none',...
        'Marker', 'o',...
        'MarkerSize', analyVar.markerSize,...
        'MarkerFaceColor', analyVar.COLORS(i,:),...
        'MarkerEdgeColor', 'none',...
        'Color', analyVar.COLORS(i,:));
end

function h = myfitplot(x,y,analyVar,i)
    h = plot(x,y,...
        'LineStyle','-',...
        'Marker', 'none',...
        'MarkerSize', analyVar.markerSize,...
        'MarkerFaceColor', analyVar.COLORS(i,:),...
        'MarkerEdgeColor', 'none',...
        'Color', analyVar.COLORS(i,:));
end

function an = myAnnotate(coeffs, err, coeffNames, coeffUnits)
    
    dim = [.7 .5 .3 .3];
    
    % convert to relevant parameters
    coeffs(3) = coeffs(3) * 2*sqrt(2*log(2));
    err(3) = err(3) * 2*sqrt(2*log(2));
    
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