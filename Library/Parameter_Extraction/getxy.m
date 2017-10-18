function [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset)

    xdata = cell(analyVar.numBasenamesAtom,1);
    ydata = cell(analyVar.numBasenamesAtom,1);
    
    for i = 1:analyVar.numBasenamesAtom
        
        xdata{i} = indivDataset{i}.(indVarField);
        ydata{i} = indivDataset{i}.(depVarField);
        
    end

end