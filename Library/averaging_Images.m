function averaging_Images(varargin)
% Function to read in a set of images (that are all the same experimental
% settings) and average the camera images across scans. This program will
% take in a set of images and will write and output a new set of images
% that can then be run through the imagefit routine as normal. 
%
% This program uses the same averaging variable flag as the post fitting
% averaging (as of 2017.08.11 that is the first column after the
% timestamp). If multiple groups are to be averaged together, a new line in
% the master batch will be written for each group.
%
%
%% Load variables and file data
if nargin == 0 % If run without arguments
    analyVar     = AnalysisVariables;
    indivDataset = get_indiv_batch_data(analyVar);
else
    analyVar     = varargin{1}; % if arguments are passed analyVar must be first
    indivDataset = varargin{2}; % indivDataset must be second
end

%% Setup the independent variables between all similar scans for averaging
simScanIndVar = cell(1, length(analyVar.uniqScanList));
for uniqScanIter = 1:length(analyVar.uniqScanList);
    % Create a cell containing the scanned variable for each batch (set of images)
    indVars = arrayfun(@(x) indivDataset{x}.imagevcoAtom,analyVar.posOccurUniqVar{uniqScanIter},'UniformOutput',0);
    % Save a vector of all the unique scan pnts for comparison
    simScanIndVar{uniqScanIter} = double(unique(int32(cell2mat(indVars)*analyVar.compPrec)))*1/analyVar.compPrec;
end

for uniqScanIter = 1:length(analyVar.uniqScanList);
    %% Loop through all unique values, generate average image, and save the new scan to disk
    % Preallocate nested loop variables
    [avgAtomImages, avgBackImages, ]...
        = deal(NaN(length(simScanIndVar{uniqScanIter}),...
                   length(analyVar.posOccurUniqVar{uniqScanIter}),...
                   prod(analyVar.matrixSize)));
  
    % Loop through all scans that share the current value of the averaging variable
    for simScanIter = 1:length(analyVar.posOccurUniqVar{uniqScanIter})
        % Assign the current scan to be opened
        basenameNum = analyVar.posOccurUniqVar{uniqScanIter}(simScanIter);
        
        % Reference variables in structure by shorter names for convenience
        % (will not create copy in memory as long as the vectors are not modified)
        rawAtomImages  = indivDataset{basenameNum}.rawAtomImages;
        rawBackImages  = indivDataset{basenameNum}.rawBackImages;
        
        % Find the intersection of the scanned variable with the list of all possible values
        % idxShrdInBatch - index of the batch file ind. variables that intersect with
        %                  the set of all ind. variables of similar scans
        % idxShrdWithSim - index of all ind. variables of similar scans that intersect
        %                  with the set of current batch file ind. variables
        % Look at help of intersect if this is unclear
        [~,idxSharedWithSim,idxSharedInBatch] = intersect(simScanIndVar{uniqScanIter},...
            double(int32(indivDataset{basenameNum}.imagevcoAtom*analyVar.compPrec))*1/analyVar.compPrec);
        
        % 3D Matrix containing the various images for each scan
        avgAtomImages(idxSharedWithSim, simScanIter, :)   = rawAtomImages';
        avgBackImages(idxSharedWithSim, simScanIter, :)   = rawBackImages';
    end
    
    % Average all like points together
    % Function below takes the mean of the matrix of mixed NaN's and values
    avgAtomImages = nanmean(avgAtomImages, 2);
    avgBackImages = nanmean(avgBackImages, 2);

    %% Write data to files
    % With the averaged scans, now need to write the images back to disk,
    % create a batch file listing the images, and update the masterbatch file
    %
    % Going to use the first name in the group of images as the template
    % for the new scan, will append 'avgImg' before though to differentiate
    basenameNum = analyVar.posOccurUniqVar{uniqScanIter}(1);
    %
    % NOTE: for the other columns in the scan batch file, I am going to
    % write zeros. Probably won't matter overall since we hardly use them
    % but the columns have to be there
    batchfileAtom = [analyVar.dataDir 'avgImg_' char(analyVar.basenamevectorAtom(basenameNum)) '.batch']; % current atom batchfile name
    batchAtomID   = fopen(batchfileAtom, 'w');
    extraCols     = num2str(ones(1,length(analyVar.indivBatchAtomVar) - 2));
    

    for k = 1:length(simScanIndVar{uniqScanIter}) % number of atom images and background images usually the same)
        %Write a binary file created as if created in Labview
        %   LabView saves binary in "big endian" ('be') format: most significant bit in
        %   lowest memory address. Matlab needs this info to import binaryfile correctly.
        %   LabView and Matlab treat matrix coordinates differently.
        s = [analyVar.dataDir 'avgImg_' char(analyVar.basenamevectorAtom(basenameNum)) '_' num2str(k,'%.3u') analyVar.dataAtom]; sFID = fopen(s,'w');
        t = [analyVar.dataDir 'avgImg_' char(analyVar.basenamevectorAtom(basenameNum)) '_' num2str(k,'%.3u') analyVar.dataBack]; tFID = fopen(t,'w');
        
        
        %   (0,0) for LabView is lower left corner; for Matlab is upper left corner.
        fwrite(sFID, reshape(avgAtomImages(k,1,:),analyVar.matrixSize),'*int16', 'ieee-be'); fclose(sFID);
        fwrite(tFID, reshape(avgBackImages(k,1,:),analyVar.matrixSize),'*int16', 'ieee-be'); fclose(tFID);
        
        indivImageData = ['avgImg_' char(analyVar.basenamevectorAtom(basenameNum)) '_' num2str(k,'%.3u') ' ' num2str(simScanIndVar{uniqScanIter}(k)) ' ' extraCols];
        fprintf(batchAtomID, '\n%s', indivImageData);
    end
    fclose(batchAtomID);
    
    % Construct the data vector needed for writing the line to the master batch
    colVec = cell(1, length(analyVar.colHeadersAtom));
    for i = 1:(length(analyVar.colHeadersAtom))
        switch i
            case 1
                colVec{i} = char(strcat('avgImg_', analyVar.(analyVar.colHeadersAtom{i})(basenameNum)));
            case 2
                timestamp = clock; 
                colVec{i} = [num2str(timestamp(4)) num2str(timestamp(5))];
            otherwise
                colVec{i} = num2str(analyVar.(analyVar.colHeadersAtom{i})(basenameNum));
        end
    end
    masterBatchLine = strjoin(colVec,'\t');
    
    % Append the new line to the bottom of the master batch
    mbAtomFileID = fopen(analyVar.basenamelistAtom, 'a');
    mbBackFileID = fopen(analyVar.basenamelistBack, 'a');
    
    fprintf(mbAtomFileID, '\n%s\n', masterBatchLine);
    fprintf(mbBackFileID, '\n%s\n', masterBatchLine);
    
    fclose(mbAtomFileID);
    fclose(mbBackFileID);
end
end