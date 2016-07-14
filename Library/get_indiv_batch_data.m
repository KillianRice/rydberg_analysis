function indivDataset = get_indiv_batch_data(analyVar)
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
indivDataset = cell(analyVar.numBasenamesAtom,1);


%% Print Information about what is being analyzed and how
disp(['Analyzing ' num2str(analyVar.numBasenamesAtom) ' scans'])
if analyVar.UseImages
    disp('Analysing Images')
    if strcmp(analyVar.sampleType, 'BEC')
        if analyVar.pureSample
            disp(['Sample type is pure ' analyVar.sampleType])
        else
            disp(['Sample type is mixed ' analyVar.sampleType])
        end
    else
        disp(['Sample type is ' analyVar.sampleType])
    end
end
    

for basenameNum = 1:analyVar.numBasenamesAtom
    
    % Find basename for background
    f = regexp(analyVar.basenamevectorBack,[char(analyVar.basenamevectorAtom(basenameNum)) '.*'],'match'); 
    f = [f{:}];
    %%%catch error about reference non-cell array when no names found in background file
    
    batchfileAtom   = [analyVar.dataDir char(analyVar.basenamevectorAtom(basenameNum)) '.batch']; % current atom batchfile name
    batchfileBack   = [analyVar.dataDir char(analyVar.basenamevectorAtom(basenameNum)) '.batch'];                                           % current background batchfile name
    batchfilePico   = [analyVar.dataDir char(analyVar.basenamevectorAtom(basenameNum)) '_pico.batch'];  % current pico batch file
    batchfileSR400  = [analyVar.dataDir char(analyVar.basenamevectorAtom(basenameNum)) '_sr400_counts.dat'];
    batchfileMCS    = [analyVar.dataDir char(analyVar.basenamevectorAtom{basenameNum}) '_MCS.batch'];
    
    
    % print batch name
    disp(char(analyVar.basenamevectorAtom(basenameNum)));
    
    batchLineFormat = '%q%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
    %batch line format reads as follows:
    %Scan name and image number \t independent parameter value \t a bunch
    %of old stuff up to "wavemeteroff" \t 3 beam vca 1 static voltage value
    %\t 3 beam vca 2 static voltage value \t intial evaporation voltage \t
    %final evaporation voltage \t evaporation time constant \t trap depth / temperature (eta)
    
    picoBatchLineFormat = '%q';
    SR400LineFormat = '%q%f%f%f';
    MCSLineFormat = '%q%f';% file name \t independant variable
    
    %read in all atom files, no limit
    
    indivBatchAtomData = textscan(fopen(batchfileAtom), batchLineFormat,'commentstyle','%');
    %read in all background files, no limit
    indivBatchBackData = textscan(fopen(batchfileBack), batchLineFormat,'commentstyle','%');
    % create structure with the variables from the filename
    indivBatch = cell2struct(cat(2,indivBatchAtomData,indivBatchBackData),cat(2,analyVar.indivBatchAtomVar,analyVar.indivBatchBackVar),2);
    indivBatch.CounterAtom = size(indivBatch.fileAtom,1); % determine how many atom files in batch associated with this basename
    indivBatch.CounterBack = size(indivBatch.fileBack,1); % determine how many background files in batch associated with this basename
%%    
    if analyVar.plotCounts
        indivBatchPicoData = textscan(fopen(batchfilePico), picoBatchLineFormat, 'commentstyle', '%');
        indivBatch.filePico = indivBatchPicoData{:}; 
        indivBatch.CounterPico = size(indivBatch.filePico,1); % determine how many pico count files in batch
    end
%%    
    if analyVar.plotCounts_SR400
        indivBatchSR400 = textscan(fopen(batchfileSR400), SR400LineFormat, 'commentstyle', '%');
        indivBatch.fileSR400 = indivBatchSR400{:,1};
        indivBatch.CounterSR400 = size(indivBatch.fileSR400,1);
    end
%%    
    if analyVar.get_indiv_batch_data_MCS
        indivBatchMCS = textscan(fopen(batchfileMCS), MCSLineFormat, 'commentstyle', '%');
        indivBatch.fileMCS          = indivBatchMCS{:,1};
        indivBatch.secondIndVar     = indivBatchMCS{:,2}; %array of the values of the second independant variable in a 2-D scan; e.g. the delay time of ramps when laser f is in a for loop inside a for loop over ramp delay times
        indivBatch.CounterMCS       = indivBatch.CounterAtom;%number of entries in a batch file
        
        [mcsSpectra, timedelayOrderMatrix]= deal(cell(indivBatch.CounterMCS,1));%cell-array of size equal to the number of frequency points
        for bIndex = 1:indivBatch.CounterMCS %cycle through each frequency point
            %% Read in the txt file that has the values of ramp delay times
            NameLength = length(indivBatch.fileAtom{bIndex});
            FileIndex = indivBatch.fileAtom{bIndex}(NameLength-2:NameLength);
            RampDelay_Address=fullfile(analyVar.dataDir,...
                [char(analyVar.basenamevectorAtom(basenameNum)) '_TauArray' FileIndex '.txt']);
            timedelayOrderMatrix{bIndex} = dlmread(RampDelay_Address,'\t');
            fclose all;
            
            %% Read in the MCS raw data
            MCS_Address = [analyVar.dataDir char(indivBatch.fileMCS(bIndex))];
            mcsSpectra{bIndex} = load(MCS_Address);
            
            fclose all;
            
        end

        indivBatch.mcsSpectra = mcsSpectra;
        indivBatch.timedelayOrderMatrix = timedelayOrderMatrix;

    end
    
    % Subplot number for plotting program
    [indivBatch.SubPlotRows, indivBatch.SubPlotCols] = optiSubPlotNum(indivBatch.CounterAtom);
    if analyVar.UseImages == 1
        % Retrieve indexing matricies that outline the different regions of the image
        [indivBatch.image_Index,indivBatch.roiWin_Index] = get_image_regions(analyVar,basenameNum); 

        % Find number of elements inside the cloud window and around the cloud within the ROI window
        elCloud    = numel(nonzeros(indivBatch.image_Index ~= 0)); %% Enumerates all elements within the roiWinRadAtom (cloud and around)
        elNotCloud = numel(nonzeros(indivBatch.image_Index == 1)); %% Enumerates only elements not within the cloud

        %% Open raw images from camera and parse
        % The raw data is only needed before saving OD image (only OD image needed for fits 
        % and plotting) so this can be skipped for time. 
        noRawFile = {'imagefit_NumDistFit', 'imagefit_ParamEval'};
        curStack = struct2cell(dbstack);
        % This will skip reading the raw file if the caller is not one of the names in needsRawFile
        if ~sum(strcmpi(noRawFile,curStack(2,:)))
            % Aggregate background files into 2 matricies, 1 of area around cloud and the other including the cloud
            % Initialize matricies for speed
            AtomsCloud    = zeros(elCloud,indivBatch.CounterAtom);
            AtomsNotCloud = zeros(elNotCloud,indivBatch.CounterAtom);
            for ii = 1:indivBatch.CounterAtom
                s = [analyVar.dataDir char(indivBatch.fileAtom(ii)) analyVar.dataAtom]; 
                sFID = fopen(s,'rb','ieee-be');
                %Read in binary file created in LabView
                %   LabView saves binary in "big endian" ('be') format: most significant bit in
                %   lowest memory address. Matlab needs this info to import binaryfile correctly.
                %   LabView and Matlab treat matrix coordinates differently.
                %   (0,0) for LabView is lower left corner; for Matlab is upper left corner.
                fullRawImageAtom = double(fread(sFID,analyVar.matrixSize,'*int16')); 
                fclose(sFID);

                % Separate Atoms into cloud part and around cloud part
                AtomsCloud(:,ii)    = fullRawImageAtom(indivBatch.image_Index ~= 0);
                AtomsNotCloud(:,ii) = fullRawImageAtom(indivBatch.image_Index == 1);
            end %%%% end of k = 1:CounterAtom

            % Aggregate background files into 2 matricies, 1 of background behind cloud and the other around the cloud
            % Initialize matricies for speed
            BackgroundCloud    = zeros(elCloud,indivBatch.CounterBack);
            BackgroundNotCloud = zeros(elNotCloud,indivBatch.CounterBack);
            for jj = 1:indivBatch.CounterBack
                t = [analyVar.dataDir char(indivBatch.fileBack(jj)) analyVar.dataBack]; tFID = fopen(t,'rb','ieee-be');
                fullRawImageBack = double(fread(tFID,analyVar.matrixSize,'*int16')); 
                fclose(tFID);

                % Separate Background into part behind cloud and part around cloud
                BackgroundCloud(:,jj)    = fullRawImageBack(indivBatch.image_Index ~= 0);
                BackgroundNotCloud(:,jj) = fullRawImageBack(indivBatch.image_Index == 1);
            end

            % Save Atoms and Background into the indivBatch structure
            indivBatch.AtomsCloud         = AtomsCloud;
            indivBatch.AtomsNotCloud      = AtomsNotCloud;
            indivBatch.BackgroundCloud    = BackgroundCloud;
            indivBatch.BackgroundNotCloud = BackgroundNotCloud;
        end

    end
    %%%% Save the variables for each dataset into a variable containing data from all datasets listed in analyVar.basenamevectorAtom
    indivDataset{basenameNum} = orderfields(indivBatch);
end

%% Clean Workspace
fclose all;