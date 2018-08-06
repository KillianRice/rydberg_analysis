function funcOut = avg_num_and_temp(analyVar, indivDataset, avgDataset)

    if analyVar.UseImages==1
        numfield = 'winTotNum';
        tempXfield = 'atomTempX';
        tempYfield = 'atomTempY';
    else
        numfield = 'numberAtom';
        tempXfield = 'tempXAtom';
        tempYfield = 'tempYAtom';
    end
    
    allnum = [];
    alltempx = [];
    alltempy = [];
    
    scanIDs = analyVar.uniqScanList;
    
    fields = {tempYfield, tempXfield, numfield};
    allvectors = {alltempy, alltempx, allnum};
    
    
    if length(scanIDs) > 1
        groupnums = cell(length(scanIDs),1);
        grouptempX = cell(length(scanIDs),1);
        grouptempY = cell(length(scanIDs),1);
        groupvectors = {grouptempY, grouptempX, groupnums};
        for id=1:length(scanIDs)
            for i = 1:analyVar.numBasenamesAtom
                if scanIDs(id) == analyVar.meanListVar(i)
                    for j = 1:length(fields)
                        [m,catdim] = max(size(indivDataset{i}.(fields{j})));
                        groupvectors{j}{id} = cat(catdim,groupvectors{j}{id},...
                            indivDataset{i}.(fields{j}));
                    end
                end
            end
        end
        
        for i = 1:length(fields)
            figure;
            hold on;
            for id = 1:length(scanIDs)
                histogram(groupvectors{i}{id})
            end
            xlabel(fields{i});
            ylabel('Occurances');
            legend(num2str(analyVar.meanListVar))

        end
        
    else
    
        for i = 1:analyVar.numBasenamesAtom

            for j = 1:length(fields)

                [m,catdim] = max(size(indivDataset{i}.(fields{j})));

                allvectors{j} = cat(catdim,allvectors{j},indivDataset{i}.(fields{j}));

            end

        end



        for i = 1:length(fields)
            figure;
            hold on;
            histogram(allvectors{i})
            xlabel(fields{i});
            ylabel('Occurances');
            myAnnotation(fields{i}, mean(allvectors{i}), std(allvectors{i}));
        end
        
    end
    
    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end

function an = myAnnotation(field,mean,std)
    dim = [.2 .5 .3 .3];
    fmt = '%0.5e';
    str_label = strcat(field);
    str_mean = strcat('Mean: ',num2str(mean,fmt));
    str_std = strcat('Std Dev: ',num2str(std,fmt));
    str = [str_label, char(10),str_mean, char(10), str_std];
    an = annotation('textbox',dim,'String',str,'FitBoxToText','on','BackgroundColor','white');
end

function h = myplot(x,y,analyVar,i)
    h = plot(x,y,...
                'LineStyle','-',...
                'Marker', 'o',...
                'MarkerSize', analyVar.markerSize,...
                'MarkerFaceColor', analyVar.COLORS(i,:),...
                'MarkerEdgeColor', 'none',...
                'Color', analyVar.COLORS(i,:));
end