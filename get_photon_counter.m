analyVar = AnalysisVariables;
indivDataset = get_indiv_batch_data(analyVar);

function photoncounter = get_photon_counter(analyVar)
% Reads the master file list provided from AnalysisVariables (in analyVar) and
% opens each dataset batch file to create the dataset variables and the
% BackgroundAll matrix
%
% INPUTs:
%   analyVar - Structure from AnalysisVariables which enumerates all the
%              variables needed for the analysis
%
% OUTPUTS:
%   indivDataset - a cell of structures containing the individual dataset variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop through each batch file listed in analyVar.basenamevectorAtom
photoncounter = cell(analyVar.numBasenamesAtom,1);
for basenameNum = 1:analyVar.numBasenamesAtom
    % Find basename for background
    f = regexp(analyVar.basenamevectorBack,[char(analyVar.basenamevectorAtom(basenameNum)) '.*'],'match'); f = [f{:}];
    %%%catch error about reference non-cell array when no names found in background file
    
    batchfileAtom = [analyVar.dataDir char(analyVar.basenamevectorAtom(basenameNum)) '.batch']; % current atom batchfile name
    batchfileBack = [analyVar.dataDir f{:} '.batch'];                                           % current background batchfile name
    batchfilePico = [analyVar.dataDir char(analyVar.basenamevectorAtom(basenameNum)) '_pico.batch'];  % current pico batch file
    
    batchfileCounter = [analyVar.dataDir char(analyVar.basenamevectorAtom(basenameNum)) '_counter.dat'];  % current pico batch file
    
    batchLineFormat = '%q%f%f%s%f%f%f%f%f%f%f%s%f%f%f%f%f%f';
    picoBatchLineFormat = '%q';
    
    
    %batch line format reads as follows:
    %Scan name and image number \t independent parameter value \t a bunch
    %of old stuff up to "wavemeteroff" \t 3 beam vca 1 static voltage value
    %\t 3 beam vca 2 static voltage value \t intial evaporation voltage \t
    %final evaporation voltage \t evaporation time constant \t trap depth / temperature (eta)
    
    %read in all atom files, no limit
    indivBatchAtomData = textscan(fopen(batchfileAtom), batchLineFormat,'commentstyle','%');
    %read in all background files, no limit
    indivBatchBackData = textscan(fopen(batchfileBack), batchLineFormat,'commentstyle','%');
    % create structure with the variables from the filename
    indivBatch = cell2struct(cat(2,indivBatchAtomData,indivBatchBackData),cat(2,analyVar.indivBatchAtomVar,analyVar.indivBatchBackVar),2);
    
    if analyVar.plotCounts
        indivBatchPicoData = textscan(fopen(batchfilePico), picoBatchLineFormat, 'commentstyle', '%');
        indivBatchCounterData = textscan(fopen(batchfileCounter), counterBatchLineFormat, 'commentstyle', '%');
        indivBatch.filePico = indivBatchPicoData{:}; 
        indivBatch.CounterPico = size(indivBatch.filePico,1); % determine how many pico count files in batch
    end
    indivBatch.CounterAtom = size(indivBatch.fileAtom,1); % determine how many atom files in batch associated with this basename
    indivBatch.CounterBack = size(indivBatch.fileBack,1); % determine how many background files in batch associated with this basename

    % Subplot number for plotting program
    [indivBatch.SubPlotRows, indivBatch.SubPlotCols] = optiSubPlotNum(indivBatch.CounterAtom);
    % Retrieve indexing matricies that outline the different regions of the image
    [indivBatch.image_Index,indivBatch.roiWin_Index] = get_image_regions(analyVar,basenameNum);
end