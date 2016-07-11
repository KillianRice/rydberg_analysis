function [countA_AxH,countB_AxH] = create_plot_counts(analyVar,indivDataset)

countA_AxH = cell(1,analyVar.numBasenamesAtom);
countB_AxH = cell(1,analyVar.numBasenamesAtom);
    
for basenameNum = 1:analyVar.numBasenamesAtom;
    
    picoARegex = [char(analyVar.basenamevectorAtom(basenameNum)) '(\d{3})_picoA_(\d{3}).dat'];
    picoBRegex = [char(analyVar.basenamevectorAtom(basenameNum)) '(\d{3})_picoB_(\d{3}).dat'];
    
    countA_AxH{basenameNum} = zeros(1,indivDataset{basenameNum}.CounterAtom);
    countB_AxH{basenameNum} = zeros(1,indivDataset{basenameNum}.CounterAtom);
    
    figure(analyVar.figNum.picoCountsA + basenameNum)
    for k = 1:indivDataset{basenameNum}.CounterAtom
        countA_AxH{basenameNum}(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
        sumflag = 0;
        for f = 1:indivDataset{basenameNum}.CounterPico
            [tokens,match] = regexp(indivDataset{basenameNum}.filePico{f}, picoARegex,'tokens','match');
            if ~isempty(match) && str2double(tokens{1}{1}) == k
                dat = dlmread([analyVar.dataDir indivDataset{basenameNum}.filePico{f}],'\t');
                if analyVar.SumCounts
                    if ~sumflag
                        totalDat = dat(:,2);
                        sumflag = 1;
                    else
                        totalDat = totalDat + dat(:,2);
                    end
                    plot(dat(:,1),totalDat)
                else
                    plot(dat(:,1),dat(:,2));
                    hold on
                end
            end
        end
        title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k))));
    end
    
    figure(analyVar.figNum.picoCountsB + basenameNum)
    for k = 1:indivDataset{basenameNum}.CounterAtom
        countA_AxH{basenameNum}(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
        sumflag = 0;
        for f = 1:indivDataset{basenameNum}.CounterPico
            [tokens,match] = regexp(indivDataset{basenameNum}.filePico{f}, picoBRegex,'tokens','match');
            if ~isempty(match) && str2double(tokens{1}{1}) == k
                dat = dlmread([analyVar.dataDir indivDataset{basenameNum}.filePico{f}],'\t');
                if analyVar.SumCounts
                    if ~sumflag
                        totalDat = dat(:,2);
                        sumflag = 1;
                    else
                        totalDat = totalDat + dat(:,2);
                    end
                    plot(dat(:,1),totalDat)
                else
                    plot(dat(:,1),dat(:,2));
                    hold on
                end
            end
        end
        title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k))));
    end
            
    
end






end