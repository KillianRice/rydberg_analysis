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
                histogram(groupvectors{i}{id});
                myAnnotation(fields{i}, mean(groupvectors{i}{id}), std(groupvectors{i}{id}),id);
            end
            xlabel(fields{i});
            ylabel('Occurances');
            legend(num2str(scanIDs));
            

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
            myAnnotation(fields{i}, mean(allvectors{i}), std(allvectors{i}),1);
        end
        
    end
    
    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end

function an = myAnnotation(field,mean,std,iter)
    dim = [.1 + (iter-1)*0.3 .5 .3 .3];
    fmt = '%0.5e';
    str_label = strcat(field);
    str_mean = strcat('Mean: ',num2str(mean,fmt));
    str_std = strcat('Std Dev: ',num2str(std,fmt));
    str = [str_label, char(10),str_mean, char(10), str_std];
    COLORS  = [    0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];
    an = annotation('textbox',dim,'String',str,'FitBoxToText','on','BackgroundColor','white','Color',COLORS(iter,:));
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
