function funcOut = average_plot(analyVar, indivDataset, avgDataset)
    %%% average_plot.m - Joe Whalen 2017.12.15
    %%% Make a plot of the average of any quantity in indivDataset grouped
    %%% by the flags in the master batch file.
    
    indVarField = 'imagevcoAtom'; % The Field of an IndivDataset that is to be plotted on the X axis
    depVarField = 'sfiIntegral'; % The field of an indivdataset that is to be plotted on the y axis
    
    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    
    scanIDs = analyVar.uniqScanList;
    x = cell(length(scanIDs));
    y = cell(length(scanIDs));
    yerr = cell(length(scanIDs));
    for id = 1:length(scanIDs)
        x{id} = [];
        
        for basename = 1:analyVar.numBasenamesAtom
            if scanIDs(id) == analyVar.meanListVar(basename)
               x{id} = union(x{id},xdata{basename});
            end
        end

        y{id} = zeros(size(x{id}));
        yerr{id} = zeros(size(x{id}));
        
        tempy = zeros(size(analyVar.meanListVar));
        for i = 1:length(x{id})
            num=0;
            for basename = 1:analyVar.numBasenamesAtom
                if scanIDs(id) == analyVar.meanListVar(basename)
                    for j = 1:indivDataset{basename}.CounterAtom
                        if xdata{basename}(j) == x{id}(i)
                            num = num + 1;
                            tempy(num) = ydata{basename}(j);
                        end
                    end
                end
            end
            y{id}(i) = mean(tempy(1:num));
            yerr{id}(i) = std(tempy(1:num));
        end
    end
    
    avgDataset.(depVarField) = y;
    avgDataset.(strcat(depVarField,'_unc')) = yerr;
    avgDataset.(strcat(depVarField,'_x')) = x;
    figure;
    hold on;
    
    for id = 1:length(scanIDs)
        errorbar(x{id}, y{id}, yerr{id},...
            'LineStyle','-',...
            'Marker', 'o',...
            'MarkerSize', analyVar.markerSize,...
            'MarkerFaceColor', analyVar.COLORS(id,:),...
            'MarkerEdgeColor', 'none',...
            'Color', analyVar.COLORS(id,:));
    end
    legend(num2str(scanIDs))
    hold off
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;
end

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    