%%%% get_daq_averages - Soumya K Kanungo 2021-02-04
%%%% returns averaged data of the given field of DAQ_voltages based on the
%%%% scanID's in the master batch file.
function [num, num_err, tx, tx_err, ty, ty_err] = get_num_temp_averages(analyVar, indivDataset)
    scanIDs = analyVar.uniqScanList;
    num = zeros(1,length(scanIDs));
    tx = zeros(1,length(scanIDs));
    ty = zeros(1,length(scanIDs));
    num_err = zeros(1,length(scanIDs));
    tx_err = zeros(1,length(scanIDs));
    ty_err = zeros(1,length(scanIDs));
    for id = 1:length(scanIDs)
        tempnum = [];
        temptx = [];
        tempty = [];
        for basename = 1:analyVar.numBasenamesAtom
            if scanIDs(id) == analyVar.meanListVar(basename)
                tempnum = union(tempnum,indivDataset{basename}.numberAtom);
                temptx = union(temptx,indivDataset{basename}.tempXAtom);
                tempty = union(tempty,indivDataset{basename}.tempYAtom);
            end
        end
        num(id) = median(tempnum); 
        %%%% Taking median since there can be sometimes no atoms in
        %%%% bad shots and it will screw up the avg value.
        tx(id) = median(temptx);
        ty(id) = median(tempty);
        num_err(id) = std(tempnum);
        tx_err(id) = std(temptx);
        ty_err(id) = std(tempty);
    end

end