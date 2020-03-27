%%%% get_averages - Joe Whalen 2018.05.17
%%%% returns averaged data of the given field of indivDataset based on the
%%%% scanID's in the master batch file.

function [ x,y,yerr ] = get_averages( analyVar, indivDataset, avgDataset, indVarField, depVarField )

    [xdata, ydata] = getxy(indVarField, depVarField, analyVar, indivDataset, avgDataset);
    
    scanIDs = analyVar.uniqScanList;
    x = cell(length(scanIDs));
    y = cell(length(scanIDs));
    yerr = cell(length(scanIDs));
    for id = 1:length(scanIDs)
        x{id} = [];
        
        for basename = 1:analyVar.numBasenamesAtom
            if scanIDs(id) == analyVar.meanListVar(basename)
               x{id} = union(x{id},xdata{basename});
            end
        end

        y{id} = zeros(size(x{id}));
        yerr{id} = zeros(size(x{id}));
        
        tempy = zeros(size(analyVar.meanListVar));
        for i = 1:length(x{id})
            num=0;
            for basename = 1:analyVar.numBasenamesAtom
                if scanIDs(id) == analyVar.meanListVar(basename)
                    for j = 1:indivDataset{basename}.CounterAtom
                        if xdata{basename}(j) == x{id}(i)
                            num = num + 1;
                            tempy(num) = ydata{basename}(j);
                        end
                    end
                end
            end
            y{id}(i) = mean(tempy(1:num));
            yerr{id}(i) = std(tempy(1:num))/sqrt(num);
        end
    end

end

