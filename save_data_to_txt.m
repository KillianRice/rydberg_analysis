function [ files ] = save_data_to_text( analyVar, indivDataset, avgDataset )

    indVarField = 'imagevcoAtom';
    depVarField = 'winTotNum';
    
    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    
    for i = 1:analyVar.numBasenamesAtom
        
        if size(xdata{i}) ~= size(ydata{i})
            warning(['Dimensions of xdata, ydata not the same. ' ...
                'Trying to fix, but may lead to unpredictable results.'])
            ydata{i} = ydata{i}';
        end
       
        
        outfile = fopen(strcat('./out/',analyVar.basenamevectorAtom{i},'.txt'),'w');
        fprintf(outfile, '%0.30e\t%0.30e\n', [xdata{i} ydata{i}]');
        fclose(outfile);
    end


end

