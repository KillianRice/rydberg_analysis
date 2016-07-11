function ParentStruct = NormalizeUVSpectrum(analyVar, ParentStruct)
NormalizeFlag = ParentStruct.NormalizeFlag;
% 0 - Don't normalize
% 1 - Normalize to number of ramps
% 2 - Normalize to to number of ramps* exposure time
% 3 - Normalize to unity area

PosDataSets = ParentStruct.PosDataSets; % index position of the data sets within the trace

yData_Average       = ParentStruct.yData_Average;
yData_Average_error = ParentStruct.yData_Average_error;

    numLoopsSets = analyVar.numLoopsSets(PosDataSets);
    numLoopsSetsLogic = numLoopsSets ~= mean(numLoopsSets);
    numLoopsSetsLogic = sum(numLoopsSetsLogic);
    if numLoopsSetsLogic ~= 0
        error('FC: Data sets within trace are were not assigned equal number of ramps in master batch entry.')
    end
    numRamps = analyVar.numLoopsSets(PosDataSets(1));
    
    Exposure_Time = analyVar.Exposure_Time(PosDataSets)*1e6;
    Exposure_TimeLogic = Exposure_Time ~= mean(Exposure_Time);
    Exposure_TimeLogic = sum(Exposure_TimeLogic);
    if Exposure_TimeLogic ~= 0
        error('FC: Data sets within trace are were not assigned equal values of exposure time in master batch entry.')
    end
    
    exposuretime = analyVar.Exposure_Time(PosDataSets(1))*1e6; %us
    if exposuretime > 1e3
        warning('FC: Exposure time should be entered in to the master batch in units of seconds.')
    end
    
    switch NormalizeFlag
        case 1
            Norm                = 1/numRamps;
            yData_Average       = cellfun(@(x) Norm*x, yData_Average, 'UniformOutput', 0);
            yData_Average_error = cellfun(@(x) Norm*x, yData_Average_error, 'UniformOutput', 0);

        case 2
            Norm                = 1/numRamps/exposuretime;
            yData_Average       = cellfun(@(x) Norm*x, yData_Average, 'UniformOutput', 0);
            yData_Average_error = cellfun(@(x) Norm*x, yData_Average_error, 'UniformOutput', 0);

        case 3
            for densityIndex = 1:length(yData_Average)            
                [yData_Average{densityIndex}, yData_Average_error{densityIndex}] = NormalizeArray3(...
                    ParentStruct.xData, yData_Average{densityIndex}, yData_Average_error{densityIndex});
                %Normalize all UV Spectrum to unity area.
            end            
    end

    area = nan(1,length(yData_Average));
    % calculate the are under the curve
    for densityIndex = 1:length(yData_Average)            
        area(densityIndex) = abs(trapz(yData_Average{densityIndex}));
    end 
    
    ParentStruct.yData_Average = yData_Average;
    ParentStruct.yData_Average_error = yData_Average_error;
    ParentStruct.SpectrumIntegral = area;
end