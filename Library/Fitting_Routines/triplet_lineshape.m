function funcOut = triplet_lineshape(analyVar, indivDataset, avgDataset)
    %%% Dirty_Fit.m - Joe Whalen 2017.10.18
    %%% Boilerplate code for fitting arbitrary fields of indivDataset, can
    %%% be used to create fitting plugins.
    
    % put your form and the fields you want to fit here,
    % form is an anonymous function of form @(coeffs,x)
    % for example @(coeffs,x) = coeffs(1) * exp(-coeffs(2)*x)
    % coeffs can have any number of elements
    form = @(coeffs, x) coeffs(1)*exp(-(x-(coeffs(2)+abs(coeffs(4))/2)).^2./(2*coeffs(3))^2) + ...
        coeffs(5)*exp(-(x-(coeffs(2)-abs(coeffs(4))/2)).^2./(2*coeffs(6)^2)) + ...
        coeffs(7)*exp(-(x-coeffs(2)).^2/(2*coeffs(8)^2));
    
    indVarField = 'imagevcoAtom'; % The Field of an IndivDataset that is to be plotted on the X axis
    depVarField = 'sfiIntegral'; % The field of an indivdataset that is to be plotted on the y axis
    
    xaxis_label = 'Detuning (MHz)';
    yaxis_label = 'MCP Counts';
    
    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    coeffs = cell(analyVar.numBasenamesAtom,1);
    
    % put code for generating initial guesses here, needs to provide a
    % vector x0 with the same number of elements as the number of fitting
    % parameters
    x0 = [1000, 1607.625, 0.05, 0.5, 1000, 0.05];
    
    
    for i = 1:analyVar.numBasenamesAtom
        
        % try to correct for data that are not the same size
        if size(xdata{i}) ~= size(ydata{i})
            warning(['Dimensions of xdata, ydata not the same. ' ...
                'Trying to fix, but may lead to unpredictable results.'])
            ydata{i} = ydata{i}';
        end
        x0 = initial_guess(xdata{i},ydata{i});
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
        plot(fitx, form(x0,fitx), 'b--')
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
        
        disp(strcat('Fit coefficients - ',' ',analyVar.basenamevectorAtom{i}))
        disp(form)
        fprintf('Amplitude 1 - %0.3e\n',coeffs{i}(1))
        fprintf('Sigma 1 - %0.3e\n',coeffs{i}(3))
        fprintf('Amplitude 2 - %0.3e\n',coeffs{i}(5))
        fprintf('Sigma 2 - %0.3e\n',coeffs{i}(6))
        fprintf('Amplitude 3 - %0.3e\n',coeffs{i}(7))
        fprintf('Sigma 3 - %0.3e\n',coeffs{i}(8))
        fprintf('Line Splitting (MHz) - %0.3e\n',coeffs{i}(4))
        fprintf('Line Center (MHz) - %0.3e\n',coeffs{i}(2))
        fprintf('\n\n\n\n')
        
        
        
    end
    funcOut.indivDataset = indivDataset;
end

function x0 = initial_guess(x,y)

    x0 = zeros(6,1);
    x0(1) = max(y);
    x0(5) = max(y);
    x0(2) = sum(x.*y)/sum(y);
    x0(3) = 0.05;
    x0(6) = 0.05;
    x0(8) = 0.05;
    x0(4) = 5*sum((x-x0(2)).^2.*y)/sum(y);
    x0(7) = mean(y);

end


