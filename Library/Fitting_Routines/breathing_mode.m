function funcOut = breathing_mode(analyVar, indivDataset, avgDataset)
    %%% Dirty_Fit.m - Joe Whalen 2017.10.18
    %%% Boilerplate code for fitting arbitrary fields of indivDataset, can
    %%% be used to create fitting plugins.
    
    % put your form and the fields you want to fit here,
    % form is an anonymous function of form @(coeffs,x)
    % for example @(coeffs,x) = coeffs(1) * exp(-coeffs(2)*x)
    % coeffs can have any number of elements
    form = @(coeffs,x) coeffs(1)*exp(-coeffs(2)*x).*sin(2*pi*coeffs(3)*x+coeffs(4))+coeffs(5);
    indVarField = 'imagevcoAtom'; % The Field of an IndivDataset that is to be plotted on the X axis
    depVarField = 'cloudRadX'; % The field of an indivdataset that is to be plotted on the y axis
    
    xaxis_label = 'Time (ms)';
    yaxis_label = 'Cloud Radius (um)';
    
    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    coeffs = cell(analyVar.numBasenamesAtom,1);
    
    % put code for generating initial guesses here, needs to provide a
    % vector x0 with the same number of elements as the number of fitting
    % parameters
    x0 = cell(analyVar.numBasenamesAtom,1);
    for i = 1:analyVar.numBasenamesAtom
        
        guess = [0,0,0,0,0];
        guess(1) = max(ydata{i})-mean(ydata{i});
        guess(2) = 0;
        guess(3) = 0.2%2*(max(xdata{i})-min(xdata{i}))/crossings(ydata{i});
        guess(4) = 0;
        guess(5) = mean(ydata{i});
        
        x0{i} = guess;
        
    end
    
    for i = 1:analyVar.numBasenamesAtom
        
        % try to correct for data that are not the same size
        if size(xdata{i}) ~= size(ydata{i})
            warning(['Dimensions of xdata, ydata not the same. ' ...
                'Trying to fix, but may lead to unpredictable results.'])
            ydata{i} = ydata{i}';
        end
        
        % fit the data
        coeffs{i} = lsqcurvefit(form,x0{i},xdata{i},ydata{i},[],[],struct('Display','off'));

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
    
    for i = 1:analyVar.numBasenamesAtom
        
        disp(['Fit coefficients for ' num2str(i)]);
        fprintf('Amplitude (um): %0.2f\n',coeffs{i}(1));
        fprintf('Decay Rate (1/s): %0.2e\n',coeffs{i}(2)*1000);
        fprintf('Breathing Mode Frequency (Hz): %0.2f\n',coeffs{i}(3)*1000);
        fprintf('Phase (rad): %0.2f\n',coeffs{i}(4));
        fprintf('Offset (um): %0.2f\n',coeffs{i}(5));
        %cellfun(@(x) fprintf('%.5e\n',x), coeffs)
    
    end
    funcOut.indivDataset = indivDataset;
end

function num = crossings(ydata)

    num = 0;
    av = mean(ydata);
    
    sgn = sign(ydata(1)-av);
    
    for i = 1:length(ydata)
        newsgn = sign(ydata(i)-av);
        if newsgn ~= sgn
            sgn = newsgn;
            num = num + 1;
        end
    end 

end