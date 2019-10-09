function funcOut = Dirty_Fit(analyVar, indivDataset, avgDataset)
    %%% Dirty_Fit.m - Joe Whalen 2017.10.18
    %%% Boilerplate code for fitting arbitrary fields of indivDataset, can
    %%% be used to create fitting plugins.
    
    % put your form and the fields you want to fit here,
    % form is an anonymous function of form @(coeffs,x)
    % for example @(coeffs,x) = coeffs(1) * exp(-coeffs(2)*x)
    % coeffs can have any number of elements
    form = @(coeffs,x) coeffs(3)*sin(2*pi*coeffs(1)/1000*x+coeffs(6))+sin(2*pi*coeffs(2)/1000*x+coeffs(7))*coeffs(4)+coeffs(5);

    %form = @(coeffs,x) coeffs(2)*sin(2*pi*coeffs(1)*x+coeffs(4))+coeffs(3);
    indVarField = 'imagevcoAtom'; % The Field of an IndivDataset that is to be plotted on the X axis
    depVarField = 'cntrX'; % The field of an indivdataset that is to be plotted on the y axis
    
    xaxis_label = 'recapture time[ms]';
    yaxis_label = 'X-center';
    
    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    coeffs = cell(analyVar.numBasenamesAtom,1);
    
    % put code for generating initial guesses here, needs to provide a
    % vector x0 with the same number of elements as the number of fitting
    % parameters
    x0 = [70,70,1,1,100,0,0];
    %x0 = [28,10,134,0];
    
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
        plot(xdata{i},ydata{i}, 'o','MarkerEdgeColor','b','MarkerFaceColor','b')
        plot(fitx,form(coeffs{i},fitx),'r-','Linewidth',2)
        plot(fitx,form(x0,fitx),'b--')
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
    
    if length(analyVar.timevectorAtom) > 1
        
        [xdata, ydata, yerr] = get_averages(analyVar, indivDataset, avgDataset, indVarField, depVarField);
        scanIDs = analyVar.uniqScanList;
        
        for i = 1:length(scanIDs)
            
            if size(xdata{i}) ~= size(ydata{i})
                warning(['Dimensions of xdata, ydata not the same. ' ...
                    'Trying to fix, but may lead to unpredictable results.'])
                ydata{i} = ydata{i}';
            end
            
            avg_coeffs{i} = lsqcurvefit(form,x0,xdata{i},ydata{i},[],[],struct('Display','off'));
            
            fitx = linspace(min(xdata{i}),max(xdata{i}),1000);
            
            figure
            hold on
            myerrorbar(xdata{i},ydata{i},yerr{i},analyVar,i);
            myfitplot(fitx,form(avg_coeffs{i},fitx),analyVar,i);
            xlabel(xaxis_label);
            ylabel(yaxis_label);
            myAnnotation(avg_coeffs{i});
            legend(num2str(scanIDs(i)));
            hold off
        end
    end
            
    
    disp('Fit coefficients - make sure to check units')
    disp(form)
    cellfun(@(x) fprintf('%.5e\n',x), coeffs)
    funcOut.indivDataset = indivDataset;
    funcOut.analyVar = analyVar;
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

function an = myAnnotation(coeffs)
    dim = [.7 .5 .3 .3];
    fmt = '%0.2f';
    str_mean = strcat('F1: ',num2str(coeffs(1),fmt), ' Hz');
    str_std = strcat('F2: ',num2str(coeffs(2),fmt), ' Hz');
    str = [str_mean, char(10), str_std];
    an = annotation('textbox',dim,'String',str,'FitBoxToText','on','BackgroundColor','white');
end