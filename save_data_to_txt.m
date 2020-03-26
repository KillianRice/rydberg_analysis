function [ files ] = save_data_to_txt( analyVar, indivDataset, avgDataset )

    indVarField = 'imagevcoAtom';
    depVarField = {'sfiIntegral'};
    
    for j = 1:length(depVarField)
        
        [xdata, ydata] = getxy(indVarField, depVarField{j}, analyVar, indivDataset, avgDataset);
        
        for i = 1:analyVar.numBasenamesAtom

            if size(xdata{i}) ~= size(ydata{i})
                warning(['Dimensions of xdata, ydata not the same. ' ...
                    'Trying to fix, but may lead to unpredictable results.'])
                ydata{i} = ydata{i}';
            end


            outfile = fopen(strcat('./out/',analyVar.dataDirName,analyVar.basenamevectorAtom{i},'_',depVarField{j},'.txt'),'w');
            fprintf(outfile, '%0.30e\t%0.30e\n', [xdata{i} ydata{i}]');
            fclose(outfile);
        end
        
        if length(analyVar.timevectorAtom) > 1
           
            [xavg, yavg, yerr] = get_averages(analyVar, indivDataset, avgDataset, indVarField, depVarField{j});
            scanIDs = analyVar.uniqScanList;
            
            for i = 1:length(scanIDs)
            
                if size(xavg{i}) ~= size(yavg{i})
                    warning(['Dimensions of xdata, ydata not the same. ' ...
                        'Trying to fix, but may lead to unpredictable results.'])
                    yavg{i} = yavg{i}';
                end
            
                outfile = fopen(strcat('./out/',analyVar.dataDirName,'_',num2str(scanIDs(i)),'_',depVarField{j},'.txt'),'w');
                fprintf(outfile, '%0.30e\t%0.30e\t%0.30e\n', [xavg{i} yavg{i} yerr{i}]');
                fclose(outfile);
            
            end
            
        end
        
    end


end

