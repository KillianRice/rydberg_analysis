function [ files ] = save_data_to_txt_ver2( analyVar, indivDataset, avgDataset )

    indVarField = 'imagevcoAtom';
    depVarField = {'sfiIntegral'};
    depVarField1 = {'sfiIntegral_roi1'}; % FOR mm-wave stuff
    depVarField2 = {'sfiIntegral_roi2'}; % FOR mm-wave stuff
    if analyVar.UseImages==1
        tempXfield= {'atomTempX'};
        tempYfield= {'atomTempY'};
        numfield= {'winTotnum'};
    else
        tempXfield= {'tempXAtom'};
        tempYfield= {'tempXAtom'};
        numfield= {'numberAtom'};
    end
    
    for j = 1:length(depVarField)
        
        [xdata, ydata] = getxy(indVarField, depVarField{j}, analyVar, indivDataset, avgDataset);
        [tempx, tempy] = getxy(tempXfield{j}, tempYfield{j}, analyVar, indivDataset, avgDataset);
        [~, num]   = getxy(indVarField, numfield{j}, analyVar, indivDataset, avgDataset);
        [ydata1, ydata2] = getxy(depVarField1{j},depVarField2{j}, analyVar, indivDataset, avgDataset);
        for i = 1:analyVar.numBasenamesAtom

            if size(xdata{i}) ~= size(ydata{i})
                warning(['Dimensions of xdata, ydata not the same. ' ...
                    'Trying to fix, but may lead to unpredictable results.'])
                ydata{i} = ydata{i}';
            end


            outfile = fopen(strcat('./out/',analyVar.dataDirName,analyVar.basenamevectorAtom{i},'_',depVarField{j},'.txt'),'w');
            fprintf(outfile, '%0.30e\t%0.30e\t%0.30e\t%0.30e\t%0.30e\t%0.30e\t%0.30e\n', [xdata{i} ydata{i} tempx{i} tempy{i} num{i} ydata1{i} ydata2{i}]');
            fclose(outfile);
        end
        
    end


end

