analyVar = AnalysisVariables;

inputfilename=[analyVar.dataDir 'test.batch'];
outputfilename=[analyVar.dataDir 'test_output.batch'];

MCSLineFormat = '%q%f%f%f';
indivBatchMCS = textscan(fopen(inputfilename), MCSLineFormat, 'commentstyle', '%');
indivBatch.fileMCS = indivBatchMCS{:,1};
indivBatch.secondIndVar = indivBatchMCS{:,2}; %array of the values of the second independant variable in a 2-D scan; e.g. the delay time of ramps when laser f is in a for loop inside a for loop over ramp delay times
indivBatch.AtomNumber = abs(indivBatchMCS{:,3}); %array of the number of atoms in the trap, as calculated by LabView
indivBatch.Temperature = indivBatchMCS{:,4}; %array of the number of temperature of atoms in the trap, as calculated by LabView, note that this requires that the correct drop time is used in LabView; the field used in 'fancy mode'
indivBatch.CounterMCS = size(indivBatch.fileMCS,1);

freq =[...
    98.7000e+000
    98.7100e+000
    98.7200e+000
    98.7300e+000
    98.7400e+000
    98.7500e+000
    98.7600e+000
    98.7700e+000
    98.7800e+000
    98.7900e+000
    98.8000e+000
    98.8100e+000
    98.8200e+000
    98.8300e+000
    98.8400e+000
    98.8500e+000
    98.8600e+000
    98.8700e+000
    98.8800e+000
    98.8900e+000
    98.9000e+000];    
    
    fid2 = fopen(outputfilename, 'wt');
    for kk = 1:length(indivBatchMCS{1})
%         tline = fgetl(fopen(inputfilename,'rt'));
        nline = [...
            indivBatch.fileMCS{kk}, '\t',...
            mat2str(indivBatch.secondIndVar(kk)), '\t',...
            mat2str(38), '\t',...
            mat2str(0), '\t',...
            mat2str(indivBatch.AtomNumber(kk)), '\t',...
            mat2str(indivBatch.Temperature(kk)), '\t',...
            mat2str(0.540), '\t',...
            mat2str(freq(kk)), '\t',...
            mat2str(indivBatch.secondIndVar(kk)), '\t',...
            '\n'];
        fprintf(fid2, nline);
    end

fclose all;