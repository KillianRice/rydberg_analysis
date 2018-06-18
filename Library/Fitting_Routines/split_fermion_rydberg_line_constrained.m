function funcOut = split_fermion_rydberg_line_constrained(analyVar, indivDataset, avgDataset)
    
    indVarField = 'imagevcoAtom'; % The Field of an IndivDataset that is to be plotted on the X axis
    depVarField = 'sfiIntegral'; % The field of an indivdataset that is to be plotted on the y axis
    
    xaxis_label = 'Detuning (MHz)';
    yaxis_label = 'MCP Counts';
    
    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    coeffs = cell(analyVar.numBasenamesAtom,1);   
    
    fixed_params = [0.3055,2078.918];
    form = @(coeffs, x) fitform(coeffs,x,fixed_params);
    lb = zeros(13,1);
    
    mF = -7/2:11/2;
    
    for i = 1:analyVar.numBasenamesAtom
        
        % try to correct for data that are not the same size
        if size(xdata{i}) ~= size(ydata{i})
            warning(['Dimensions of xdata, ydata not the same. ' ...
                'Trying to fix, but may lead to unpredictable results.'])
            ydata{i} = ydata{i}';
        end
        x0 = initial_guess(xdata{i},ydata{i});
        % fit the data
        coeffs{i} = lsqcurvefit(form,x0,xdata{i},ydata{i},lb,[],struct('Display','off'));

        %plotting stuff
        fitx = linspace(min(xdata{i}),max(xdata{i}),1000);
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
        bar(mF, coeffs{i}(4:end))
        xlabel('m_F');
        ylabel('Amplitude');
        hold off
        
        
        disp(strcat('Fit coefficients - ',' ',analyVar.basenamevectorAtom{i}))
        fprintf('Splitting fixed to %0.3e MHz.\n',fixed_params(1))
        fprintf('Line Center - %0.3f\n',coeffs{i}(3))
        fprintf('Sigma (MHz) - %0.3e\n',coeffs{i}(1))
        fprintf('Offset - %0.3e\n',coeffs{i}(2))
        for j = 1:10
            fprintf(strcat('Amplitude mF=',num2str(mF(j)*2), '/2 - %0.3e\n'),coeffs{i}(j+3))
        end
        fprintf('Signal Integral = %0.5e\n',abs(trapz(fitx,form(coeffs{i},fitx)-coeffs{i}(2))))
        
        fprintf('\n\n\n\n')
        
        
        
    end
    
    [xdata,ydata,yerr] = get_averages(analyVar, indivDataset, avgDataset, indVarField, depVarField);
    scanIDs = analyVar.uniqScanList;
    
    avg_coeffs = cell(size(scanIDs));
    
    for i = 1:length(scanIDs)
        
        if size(xdata{i}) ~= size(ydata{i})
            warning(['Dimensions of xdata, ydata not the same. ' ...
                'Trying to fix, but may lead to unpredictable results.'])
            ydata{i} = ydata{i}';
        end
        x0 = initial_guess(xdata{i},ydata{i});
        % fit the data
        avg_coeffs{i} = lsqcurvefit(form,x0,xdata{i},ydata{i},lb,[],struct('Display','off'));

        %plotting stuff
        fitx = linspace(min(xdata{i}),max(xdata{i}),1000);
        figure
        hold on
        subplot(2,1,1);
        hold on
        errorbar(xdata{i},ydata{i},yerr{i},...
            'LineStyle', 'none',...
            'Marker', 'o')
        plot(fitx,form(avg_coeffs{i},fitx),'r-')
        plot(fitx, form(x0,fitx), 'b--')
        xlabel(xaxis_label);
        ylabel(yaxis_label);
        hold off
        subplot(2,1,2)
        hold on
        bar(mF, avg_coeffs{i}(4:end))
        xlabel('m_F');
        ylabel('Amplitude');
        hold off
        
        disp(strcat('Fit coefficients - ',' ',num2str(scanIDs(i))))
        fprintf('Splitting Fixed to %0.3e MHz.\n',fixed_params(1))
        fprintf('Line Center %0.3f MHz\n',avg_coeffs{i}(3))
        fprintf('Sigma (MHz) - %0.3e\n',avg_coeffs{i}(1))
        fprintf('Offset - %0.3e\n',avg_coeffs{i}(2))
        for j = 1:10
            fprintf(strcat('Amplitude mF=',num2str(mF(j)*2), '/2 - %0.3e\n'),avg_coeffs{i}(j+3))
        end
        fprintf('Signal Integral = %0.5e\n',abs(trapz(fitx,form(avg_coeffs{i},fitx)-avg_coeffs{i}(2))))
        
        
        fprintf('\n\n\n\n')
        
    end
    
    
    funcOut.indivDataset = indivDataset;
end

function x0 = initial_guess(x,y)

    CGcoeffs = [0.00623013, 0.00953592, 0.00686586, 0.00127146, 0.00190718, 0.0240305,...
          0.0890019, 0.224285, 0.463446, 0.846154];
    CGcoeffs = CGcoeffs / max(CGcoeffs);
    
    x0 = zeros(13,1);
    x0(1) = 0.05;
    x0(2) = 0;
    x0(3) = min(x) + (max(x)-min(x))*0.4;
    x0(4:end-1) = 0;
    x0(end) = max(y);
end

function y = fitform(coeffs, x, fixed_params)
    %%%%  F=11/2 3S1 split lineshape
    %%%% we are exciting with RH circular + linear light, so the
    %%%% accessible mF levels are -7/2 -> 11/2, we fix the center of the
    %%%% lineshape (x0), the splitting between mF levels (delta) and the width of each line (sigma) to be the
    %%%% same, the amplitudes are allowed to vary.
    
    %%%% coeffs = [x0, delta, sigma, c, A1, ..., A10,]

    mF = -7/2:11/2;
    y = zeros(size(x));
    delta = fixed_params(1);
    sigma = coeffs(1);
    c = coeffs(2);
    x0 = coeffs(3);
    for i = 1:length(mF)
        y = y + coeffs(i+3)*exp(-(x-x0-delta*mF(i)).^2/(2*sigma^2));
    end
    
    y = y+c;
    
    
end





























