function funcOut = sfi_gaussian(analyVar, indivDataset, avgDataset)

    form = @(coeffs,x) coeffs(1) * exp(-(x-coeffs(2)).^2 ./ (2*coeffs(3)^2)) + coeffs(4);

    indVarField = 'imagevcoAtom';
    depVarField = 'sfiIntegral';
    
    xaxis_label = analyVar.xDataLabel;
    yaxis_label = 'MCP Counts';
    
    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    coeffs = cell(analyVar.numBasenamesAtom,1);   
    
    for i = 1:analyVar.numBasenamesAtom
        
        if size(xdata{i}) ~= size(ydata{i})
            warning(['Dimensions of xdata, ydata not the same. ' ...
                'Trying to fix, but may lead to unpredictable results.'])
            ydata{i} = ydata{i}';
        end
        
        x0 = initial_guess(xdata{i},ydata{i});
        coeffs{i} = lsqcurvefit(form, x0, xdata{i}, ydata{i},[],[],struct('Display','off'));
        fitx = linspace(min(xdata{i}),max(xdata{i}),1000);
        
        figure
        
        hold on
        myplot(xdata{i},ydata{i},analyVar,i);
        myfitplot(fitx,form(coeffs{i},fitx),analyVar,i);
        xlabel(xaxis_label);
        ylabel(yaxis_label);
        myAnnotation(coeffs{i});
        legend(num2str(analyVar.timevectorAtom(i)));
        hold off
        
    end
    
    if length(analyVar.timevectorAtom) > 1
    
        [xdata,ydata,yerr] = get_averages(analyVar, indivDataset, avgDataset, indVarField, depVarField);
        scanIDs = analyVar.uniqScanList;

        for i = 1:length(scanIDs)

             if size(xdata{i}) ~= size(ydata{i})
                warning(['Dimensions of xdata, ydata not the same. ' ...
                    'Trying to fix, but may lead to unpredictable results.'])
                ydata{i} = ydata{i}';
            end
            x0 = initial_guess(xdata{i},ydata{i});
            % fit the data
            avg_coeffs{i} = lsqcurvefit(form,x0,xdata{i},ydata{i},[],[],struct('Display','off'));

            %plotting stuff
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
    
    
    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end

function x0 = initial_guess(x, y)

    x0 = zeros(4,1);
    x0(1) = max(y);
    x0(2) = sum(x.*y)/sum(y);
    x0(3) = sqrt(sum((x-x0(2)).^2.*y)/sum(y));
    x0(4) = min(y);

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
    fmt = '%0.5e';
    str_mean = strcat('Center: ',num2str(coeffs(2),fmt));
    str_std = strcat('FWHM: ',num2str(2*sqrt(2*log(2))*coeffs(3),fmt));
    str_offset = strcat('offset: ',num2str(coeffs(4),fmt));
    str_int = strcat('Integral: ',num2str(coeffs(1)*sqrt(2*pi)*coeffs(3),'%.2f'));
    str = [str_mean, char(10), str_std,...
        char(10), str_offset,...
        char(10), str_int];
    an = annotation('textbox',dim,'String',str,'FitBoxToText','on','BackgroundColor','white');
end