function funcOut = data_vs_time(analyVar, indivDataset, avgDataset)
    %%% data_vs_time by Joe Whalen - 2018.07.26
    %%% Plot various paramters vs their timestamps in the batch file.
    
    if analyVar.UseImages==1
        numfield = 'winTotNum';
        tempXfield = 'atomTempX';
        tempYfield = 'atomTempY';
    else
        numfield = 'numberAtom';
        tempXfield = 'tempXAtom';
        tempYfield = 'tempYAtom';
    end
    
    other_fields = {}; % can choose to plot other quantities here
    
    
    %%%% number figure
    figure;
    hold on;
    
    for i = 1:analyVar.numBasenamesAtom
        
        myplot(indivDataset{i}.timestampAtom, indivDataset{i}.(numfield), analyVar, i);
    
    end
    
    xlabel('Timestamp');
    if analyVar.UseImages == 1
        ylabel('Atom Number From Images');
    else
        ylabel('Atom Number From LabVIEW');
    end

    legend(num2str(analyVar.timevectorAtom))
    hold off;
   
    %%%%% temperature figures
    
    figure
    hold on;
    for i = 1:analyVar.numBasenamesAtom
        myplot(indivDataset{i}.timestampAtom,indivDataset{i}.(tempXfield), analyVar, i);
    end
    xlabel('Timestamp');
    if analyVar.UseImages == 1
        ylabel('X Axis Temp From Images');
    else
        ylabel('X Axis Temp From LabVIEW');
    end
    
    legend(num2str(analyVar.timevectorAtom))
    hold off;
    
    figure;
    hold on;
    for i = 1:analyVar.numBasenamesAtom
        myplot(indivDataset{i}.timestampAtom,indivDataset{i}.(tempYfield), analyVar, i);
    end
    xlabel('Timestamp');
    if analyVar.UseImages == 1
        ylabel('Y Axis Temp From Images');
    else
        ylabel('Y Axis Temp From LabVIEW');
    end
    
    legend(num2str(analyVar.timevectorAtom))
    hold off;    
    
    
    %%%%% other plots
    
    if ~isempty(other_fields)
        for j = 1:length(other_fields)
            figure
            hold on;
            for i = 1:analyVar.numBasenamesAtom
                myplot(indivDataset{i}.timestampAtom, indivDataset{i}.(other_fields{j}), analyVar, i);
            end
            xlabel('Timestamp');
            ylabel(other_fields{j});
        end
    end
    
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;
    funcOut.analyVar = analyVar;
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