function mcsTraceAxH = create_plot_mcs_traces(analyVar,indivDataset)

mcsTraceAxH = cell(1,analyVar.numBasenamesAtom);
colors      = analyVar.COLORS;
spectrum    = cell(1,analyVar.numBasenamesAtom);

for basenameNum = 1:analyVar.numBasenamesAtom
    
    indVar = indivDataset{basenameNum}.imagevcoAtom;
    
    figure(analyVar.figNum.MCSTraces + basenameNum);
    for kk = 1:indivDataset{basenameNum}.CounterAtom
        spectrum{kk} = indivDataset{basenameNum}.mcsSpectra{kk};
        spectrum{kk}(:,1) = spectrum{kk}(:,1)/analyVar.MCS_bin_size;%convert from vs time to vs bin number so that we can choose roi
        mcsTraceAxH{basenameNum}(kk) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,kk);
        hold on
%         pcolor(spectrum(:,2:size(spectrum,2)))
%         shading flat;
        
        for i = 2:(size(spectrum{kk},2)-1)
            b = bar(spectrum{kk}(:,1)+1,spectrum{kk}(:,i));%+1 to ind var so that the bin index in the plots is correct
            set(get(b,'child'),'facea',0.5);
            set(b,'FaceColor',colors(mod(i,size(colors,1)+1),:));
            set(b,'EdgeColor','none');
        end
        set(gca,'xlim',[0,spectrum{kk}(size(spectrum{kk},1),1)]);
        hold off
    end
    title(char(indVar(kk)));
    
        figure(analyVar.figNum.MCSTraces + basenameNum*100);
    for kk = 1:indivDataset{basenameNum}.CounterAtom
        spectrum{kk} = indivDataset{basenameNum}.mcsSpectra{kk};
        spectrum{kk}(:,1) = spectrum{kk}(:,1)/analyVar.MCS_bin_size;%convert from vs time to vs bin number so that we can choose roi
        mcsTraceAxH{basenameNum}(kk) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,kk);
        hold on
%         pcolor(spectrum(:,2:size(spectrum,2)))
%         shading flat;
        
        for i = 2:(size(spectrum{kk},2)-1)
            b = bar(spectrum{kk}(:,1)+1,spectrum{kk}(:,i));%+1 to ind var so that the bin index in the plots is correct
            set(get(b,'child'),'facea',0.5);
            set(b,'FaceColor',colors(mod(i,size(colors,1)+1),:));
            set(b,'EdgeColor','none');
        end
        set(gca,'xlim',[0,spectrum{kk}(size(spectrum{kk},1),1)]);
        hold off
    end
    title(char(indVar(kk)));
    
end