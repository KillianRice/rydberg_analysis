function output = create_plot_mcs_sum(analyVar,indivDataset)
error('numSpectra structure has changed. and Have to update code. Have to check that we are plotting what we want. Plot all traces together, or seperate? Do we normalize to #of ramps or #of atoms?')

for basenameNum = 1:analyVar.numBasenamesAtom
    
    indVar = indivDataset{basenameNum}.imagevcoAtom;
    mcsSum = indivDataset{basenameNum}.mcsSum;
    numSpectra = indivDataset{basenameNum}.numSpectra;
    markers = analyVar.MARKERS;
    colors = analyVar.COLORS;
    
    figNum = analyVar.figNum.MCSCounts;
    numLabel = {'Total MCS Counts'};
    numTitle = {};
    figure(figNum)
    hold on
    
    for i = 1:numSpectra
        if i == numSpectra
            plot(indVar, mcsSum(:,i), ['--' markers{basenameNum}(2)], 'Color', colors(basenameNum,:))
        else
            plot(indVar, mcsSum(:,i), markers{basenameNum}, 'Color', colors(basenameNum,:))
        end   
    end
    
    hold off
    
end

end