%%%% get_daq_averages - Soumya K Kanungo 2021-02-04
%%%% returns averaged data of the given field of DAQ_voltages based on the
%%%% scanID's in the master batch file.
function [c1,c1_err,c2,c2_err] = get_daq_averages(analyVar, indivDataset)

    channels_to_average = [0,5];
    scanIDs = analyVar.uniqScanList;
    c1 = zeros(1,length(scanIDs));
    c2 = zeros(1,length(scanIDs));
    c1_err = zeros(1,length(scanIDs));
    c2_err = zeros(1,length(scanIDs));
    for id = 1:length(scanIDs)
        temp1 = [];
        temp2 = [];
        for basename = 1:analyVar.numBasenamesAtom
            if scanIDs(id) == analyVar.meanListVar(basename)
                temp1 = union(temp1,indivDataset{basename}.daq_voltages{3+channels_to_average(1)});
                temp2 = union(temp2,indivDataset{basename}.daq_voltages{3+channels_to_average(2)});
            end
        end
        c1(id) = mean(temp1);
        c2(id) = mean(temp2);
        c1_err(id) = std(temp1);
        c2_err(id) = std(temp2);
    end

end

