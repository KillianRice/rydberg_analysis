function funcOut = average_plot_sfi_roi(analyVar, indivDataset, avgDataset)
    %%% average_plot_sfi_roi.m - Soumya Kanungo 2019.02.20
    %%% Make a plot of the average of any quantity in indivDataset grouped
    %%% by the flags in the master batch file.
    
    indVarField = 'imagevcoAtom'; % The Field of an IndivDataset that is to be plotted on the X axis
    depVarField1 = 'sfiIntegral_roi1'; % The field of an indivdataset that is to be plotted on the y axis
    depVarField2 = 'sfiIntegral_roi2'; % The field of an indivdataset that is to be plotted on the y axis
    
    [xdata, ydata1] = getxy(indVarField, depVarField1, analyVar, indivDataset, avgDataset);
    [xdata, ydata2] = getxy(indVarField, depVarField2, analyVar, indivDataset, avgDataset);
    
    scanIDs = analyVar.uniqScanList;
    x = cell(length(scanIDs));
    y1 = cell(length(scanIDs));
    yerr1 = cell(length(scanIDs));
    y2 = cell(length(scanIDs));
    yerr2 = cell(length(scanIDs));
    for id = 1:length(scanIDs)
        x{id} = [];
        
        for basename = 1:analyVar.numBasenamesAtom
            if scanIDs(id) == analyVar.meanListVar(basename)
               x{id} = union(x{id},xdata{basename});
            end
        end

        y1{id} = zeros(size(x{id}));
        yerr1{id} = zeros(size(x{id}));
        y2{id} = zeros(size(x{id}));
        yerr2{id} = zeros(size(x{id}));
        ratio1{id} = zeros(size(x{id}));
        ratio2{id} = zeros(size(x{id}));
        ratio_err1{id} = zeros(size(x{id}));
        ratio_err2{id} = zeros(size(x{id}));
        
        tempy1 = zeros(size(analyVar.meanListVar));
        tempy2 = zeros(size(analyVar.meanListVar));
        ratiotemp1 = zeros(size(analyVar.meanListVar));
        ratiotemp2 = zeros(size(analyVar.meanListVar));
        for i = 1:length(x{id})
            num=0;
            for basename = 1:analyVar.numBasenamesAtom
                if scanIDs(id) == analyVar.meanListVar(basename)
                    for j = 1:indivDataset{basename}.CounterAtom
                        if xdata{basename}(j) == x{id}(i)
                            num = num + 1;
                            tempy1(num) = ydata1{basename}(j);
                            tempy2(num) = ydata2{basename}(j);
                            ratiotemp1(num) = tempy1(num)/(tempy2(num)+tempy1(num));
                            ratiotemp2(num) = tempy2(num)/(tempy2(num)+tempy1(num));
                        end
                    end
                end
            end
            y1{id}(i) = mean(tempy1(1:num));
            yerr1{id}(i) = std(tempy1(1:num));
            y2{id}(i) = mean(tempy2(1:num));
            yerr2{id}(i) = std(tempy2(1:num));
            ratio1{id}(i)= mean(ratiotemp1(1:num));
            ratio2{id}(i)= mean(ratiotemp2(1:num));
            ratio_err1{id}(i) = std(ratiotemp1(1:num));
            ratio_err2{id}(i) = std(ratiotemp2(1:num));
            
%             meany1 = mean(tempy1(1:num));
%             stdy1 = std(tempy1(1:num));
%             meany2 = mean(tempy2(1:num));
%             stdy2 = std(tempy2(1:num));
%             y1{id}(i) = meany1/(meany1+meany2);
%             yerr1{id}(i) = (2*stdy1/meany1+stdy2/meany2)*y1{id}(i);
%             y2{id}(i) = meany2/(meany1+meany2);
%             yerr2{id}(i) = (2*stdy2/meany2+stdy1/meany1)*y2{id}(i);
        end
    end
    
    avgDataset.(depVarField1) = y1;
    avgDataset.(depVarField2) = y2;
    avgDataset.(strcat(depVarField1,'_unc')) = yerr1;
    avgDataset.(strcat(depVarField2,'_unc')) = yerr2;
    avgDataset.(strcat(depVarField1,'_ratio')) = ratio1;
    avgDataset.(strcat(depVarField2,'_ratio')) = ratio2;
    avgDataset.(strcat(depVarField1,'_x')) = x;
    
    figure;
    hold on;
    for id = 1:length(scanIDs)
        errorbar(x{id}, y1{id}, yerr1{id},...
            'LineStyle','-',...
            'Marker', 'o',...
            'MarkerSize', analyVar.markerSize,...
            'MarkerFaceColor', analyVar.COLORS(2*id-1,:),...
            'MarkerEdgeColor', 'none',...
            'Color', analyVar.COLORS(2*id-1,:));
        errorbar(x{id}, y2{id}, yerr2{id},...
            'LineStyle','-',...
            'Marker', 'o',...
            'MarkerSize', analyVar.markerSize,...
            'MarkerFaceColor', analyVar.COLORS(2*id,:),...
            'MarkerEdgeColor', 'none',...
            'Color', analyVar.COLORS(2*id,:));
    end
    legend(num2str(scanIDs))
    hold off
    
    figure;
    hold on;
    for id = 1:length(scanIDs)
        errorbar(x{id}, ratio1{id}, ratio_err1{id},...
            'LineStyle','-',...
            'Marker', 'o',...
            'MarkerSize', analyVar.markerSize,...
            'MarkerFaceColor', analyVar.COLORS(2*id-1,:),...
            'MarkerEdgeColor', 'none',...
            'Color', analyVar.COLORS(2*id-1,:));
        errorbar(x{id}, ratio2{id}, ratio_err2{id},...
            'LineStyle','-',...
            'Marker', 'o',...
            'MarkerSize', analyVar.markerSize,...
            'MarkerFaceColor', analyVar.COLORS(2*id,:),...
            'MarkerEdgeColor', 'none',...
            'Color', analyVar.COLORS(2*id,:));
    end
    legend(num2str(scanIDs))
    hold off
    
    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;
end 