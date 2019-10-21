function funcOut = bec_decay_lifetime_roi( analyVar, indivDataset, avgDataset )
     x = 100;
     rois = {[15 x], [x -1]};
     indivDataset = get_roi_a_b(analyVar, indivDataset, rois);
     indVarField = 'imagevcoAtom';
     
     [xavg, yavgA, yerrA] = get_averages(analyVar, indivDataset, avgDataset, indVarField, 'SFI_roi_A');
     [~, yavgB, yerrB] = get_averages(analyVar, indivDataset, avgDataset, indVarField, 'SFI_roi_B');

     scanIDs = analyVar.uniqScanList;
     avg_coeffs = cell(length(scanIDs),1);
     avg_err = cell(length(scanIDs),1);
     
     for i = 1:length(scanIDs)
         
        initialguess = [30, 1e5, 1e5, 1e4, 0.1];
         [avg_coeffs{i},~,residual,~,~,~,J] = lsqcurvefit(@mywrapper,...
             initialguess,xavg{i},[yavgA{i},yavgB{i}],[],[],struct('Display', 'off'));
        conf = nlparci(avg_coeffs{i},residual,'jacobian',J); % returns 95% CI bounds
        avg_err{i} = (conf(:,2) - conf(:,1)) / 4; % computes 1 sigma uncertainty from 95% CI
        % plot the data
        fitx = linspace(min(xavg{i}),max(xavg{i}),1000);
        [na, nb] = myform(avg_coeffs{i},fitx);
        figure
        hold on
            myerrorbar(xavg{i}, yavgA{i}, yerrA{i}, i, analyVar);
            myFitLinePlot(fitx, na, i, analyVar);
            myerrorbar(xavg{i}, yavgB{i}, yerrB{i}, i+1, analyVar);
            myFitLinePlot(fitx, nb, i+1, analyVar);
            legend(strcat('N_A ', num2str(scanIDs(i))),...
                'N_A Fit',...
                strcat('N_B ', num2str(scanIDs(i))),...
                'N_B Fit');
            xlabel('Delay Time (s)');
            ylabel('Population');
            myAnnotate(avg_coeffs{i}, avg_err{i});
        hold off
         
     end

    funcOut.indivDataset = indivDataset;
    funcOut.analyVar = analyVar;
    funcOut.avgDataset = avgDataset;
     
end

function [na, nb] = myform(coeffs, x)
    
    % coeffs(1) = N0;
    % coeffs(2) = AI rate
    % coeffs(3) = L Change rage
    % coeffs(4) = Radiative decay Rate
    % coeffs(5) = eps, percentage of L change in region A

    np = coeffs(1) * exp(-(coeffs(2)+coeffs(3)+coeffs(4))*x);
    nL = coeffs(1) * coeffs(3)/(coeffs(2)+coeffs(3)) * exp(-coeffs(4)*x) .*...
        (1-exp(-(coeffs(2)+coeffs(3))*x));
    
    na = np + coeffs(5) * nL;
    nb = (1-coeffs(5)) * nL;
        
end

function out = mywrapper(coeffs, x)
    [na, nb] = myform(coeffs,x);
    out = [na,nb];
end

function indivDataset = get_roi_a_b(analyVar, indivDataset, rois)

    fields = {'SFI_roi_A', 'SFI_roi_B'};
    for i = 1:analyVar.numBasenamesAtom
       
        for f = 1:numel(fields)
            indivDataset{i}.(fields{f}) = zeros(size(indivDataset{i}.mcsSpectra));
            for j = 1:indivDataset{i}.CounterMCS
                if rois{f}(2) == -1
                    indivDataset{i}.(fields{f})(j) = sum(indivDataset{i}.mcsSpectra{j}(rois{f}(1):end,2));
                else
                    indivDataset{i}.(fields{f})(j) = sum(indivDataset{i}.mcsSpectra{j}(rois{f}(1):rois{f}(2),2));
                end
            end
        end
        
    end
end

function h = myerrorbar(x,y,yerr,i,analyVar)
    h = errorbar(x,y,yerr,...
        'LineStyle','none',...
        'Marker', 'o',...
        'MarkerSize', analyVar.markerSize,...
        'MarkerFaceColor', analyVar.COLORS(i,:),...
        'MarkerEdgeColor', 'k',...
        'Color', analyVar.COLORS(i,:));
end

function h = myFitLinePlot(x,y,i,analyVar)
    h = plot(x,y,...
        'LineStyle', '-',...
        'Marker', 'none',...
        'LineWidth', 1,...
        'Color', analyVar.COLORS(i,:));
end

function an = myAnnotate(coeffs, err)   
    coeffs(2:3) = coeffs(2:3) * 1e-6;
    err(2:3) = err(2:3) * 1e-6;
    coeffs(4) = 1/coeffs(4)*1e6;
    err(4) = abs(0.5e6*(1/(coeffs(4)+err(4))-1/(coeffs(4)-err(4))));

    dim = [.25 .6 .3 .3];
    
    coeffNames = {'N_0','\Gamma_{AI}','\Gamma_L','\tau_R','\epsilon'};
    coeffUnits = {'', '\mus^{-1}','\mus^{-1}','s',''};
    
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