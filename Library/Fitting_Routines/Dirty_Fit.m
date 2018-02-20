function funcOut = Dirty_Fit(analyVar, indivDataset, avgDataset)
    %%% Dirty_Fit.m - Joe Whalen 2017.10.18
    %%% Boilerplate code for fitting arbitrary fields of indivDataset, can
    %%% be used to create fitting plugins.
    
    % put your form and the fields you want to fit here,
    % form is an anonymous function of form @(coeffs,x)
    % for example @(coeffs,x) = coeffs(1) * exp(-coeffs(2)*x)
    % coeffs can have any number of elements
    form = @(coeffs,x) coeffs(1)*exp(-coeffs(2)*x);
    indVarField = 'imagevcoAtom'; % The Field of an IndivDataset that is to be plotted on the X axis
    depVarField = 'winTotNum'; % The field of an indivdataset that is to be plotted on the y axis
    
    xaxis_label = 'Exposure Time (ms)';
    yaxis_label = 'Shelved Atom Number';
    
    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    coeffs = cell(analyVar.numBasenamesAtom,1);
    
    % put code for generating initial guesses here, needs to provide a
    % vector x0 with the same number of elements as the number of fitting
    % parameters
    x0 = [1e5 0.01];
    
    for i = 1:analyVar.numBasenamesAtom
        
        % try to correct for data that are not the same size
        if size(xdata{i}) ~= size(ydata{i})
            warning(['Dimensions of xdata, ydata not the same. ' ...
                'Trying to fix, but may lead to unpredictable results.'])
            ydata{i} = ydata{i}';
        end
        
        % fit the data
        coeffs{i} = lsqcurvefit(form,x0,xdata{i},ydata{i},[],[],struct('Display','off'));

        %plotting stuff
        fitx = linspace(min(xdata{i}),max(xdata{i}));
        figure
        hold on
        subplot(2,1,1);
        hold on
        plot(xdata{i},ydata{i}, 'o')
        plot(fitx,form(coeffs{i},fitx),'r-')
        xlabel(xaxis_label);
        ylabel(yaxis_label);
        hold off
        subplot(2,1,2)
        hold on
        stem(xdata{i},ydata{i}-form(coeffs{i},xdata{i}),'o')
        xlabel(indVarField);
        ylabel('Residuals');
        hold off
        hold off
        
    end
    disp('Fit coefficients - make sure to check units')
    disp(form)
    cellfun(@(x) fprintf('%.5e\n',x), coeffs)
    funcOut.indivDataset = indivDataset;
end