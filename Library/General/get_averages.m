%%%% get_averages - Joe Whalen 2018.05.17
%%%% returns averaged data of the given field of indivDataset based on the
%%%% scanID's in the master batch file.

%%%% updated 2020.03.30 - added the option to use poisson or gaussian
%%%% statistics. Gaussian takes the mean and standard dev / sqrt(N) as the
%%%% mean and standard error of the mean. Gaussian is to be used to for
%%%% things like atom num, temp and other normally distributed quantities.

%%%% Poisson takes the total number of counts per x variable C and assigns a
%%%% shot noise error of sqrt(C). If the total number of counts in a given
%%%% channel is zero we assign a nominal sigma of sqrt(-log(0.95)/N) where
%%%% N is the number of measurements per channel. This estimates the worst
%%%% case mean where you have a 95% chance of measure zero N times.

function [ x,y,yerr ] = get_averages( analyVar, indivDataset, avgDataset, indVarField, depVarField, weighting )

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
            switch weighting
                case 'gaussian'
                    y{id}(i) = mean(tempy(1:num));
                    yerr{id}(i) = std(tempy(1:num))/sqrt(num);
                case 'poisson'
                    y{id}(i) = sum(tempy(1:num));
                    switch y{id}(i)
                        case 0
                            yerr{id}(i) = sqrt(-log(0.95)/num);
                        otherwise
                            yerr{id}(i) = sqrt(y{id}(i));
                    end
                otherwise
                    error('statistics must be either gaussian or poisson');
            end
                
        end
    end

end

