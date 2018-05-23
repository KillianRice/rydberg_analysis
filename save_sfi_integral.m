function [files] = save_sfi_integral(analyVar, indivDataset)

    for basename = 1:analyVar.numBasenamesAtom
        
        outData = [indivDataset{basename}.imagevcoAtom, indivDataset{basename}.sfiIntegral_allDensities];
        
        outfile = fopen(strcat('./out/', analyVar.basenamevectorAtom{basename},...
            '_sfiIntegral_allDensities.txt'),'w');
        
        line = strcat(repmat('%0.30e\t',1,size(outData,2)-1),'%0.30e\n');
        fprintf(outfile, line, outData');
        fclose(outfile);
      
    end

end