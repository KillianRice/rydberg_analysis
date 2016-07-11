function [indivDataset,avgDataset] = add_fit_indiv_batch(analyVar,indivDataset)
% Function to add the OD image and fit coefficients to the indivDataset
% cell of structures. Also creates a separate cell of structures containing
% averaging data (i.e. all unique independent variables)
% This functions allows convenient aggregation of fit
% data to simplify deployment of future parameter analysis.
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   indivDataset - Same as input cell with added fields containing OD_Image
%                  and fit coefficents
%   avgDataset   - Similar to indivDataset but groups sets of scans for
%                  averaging.
% 
%% Loop through all scans to aggregate OD images and fitted coefficients 
% into a cell of structures (adding to indivDataset)
for basenameNum = 1:analyVar.numBasenamesAtom
    % Preallocate space in indivDataset
    [indivDataset{basenameNum}.All_OD_Image, indivDataset{basenameNum}.All_PCell,...
     indivDataset{basenameNum}.All_fitParams] ...
     = deal(cell(1,indivDataset{basenameNum}.CounterAtom));
    
        % Processes all image files in the current batch
        for k = 1:indivDataset{basenameNum}.CounterAtom;       
%% Read OD_Image_Single from file
%%%%%%%-----------------------------------%%%%%%%%%%
            indivDataset{basenameNum}.All_OD_Image{k} = dlmread([analyVar.analyOutDir ...
                char(indivDataset{basenameNum}.fileAtom(k)) analyVar.ODimageFilename]);
            
%% Read fit parameters from file on disk
%%%%%%%-----------------------------------%%%%%%%%%%
            fitFile = [analyVar.analyOutDir char(indivDataset{basenameNum}.fileBack(k)) analyVar.sampleType analyVar.fitModel ...
                analyVar.paramFitFilename analyVar.paramFitFileExt];
            if exist(fitFile,'file')
                % Read fit parameters from file
                % NOTE: the last fit number in the fit parameter file is a flag
                % showing whether weighting was enabled during the fitting routine.
                indivDataset{basenameNum}.All_PCell{k} = mat2cell(dlmread(fitFile),ones(1,sum(analyVar.LatticeAxesFit)),...
                    length(analyVar.InitCondList) + 1);

                % Save real fit P values to struct for convenience
                indivDataset{basenameNum}.All_fitParams{k} = cellfun(@(P) (cell2struct(num2cell(P(1:length(analyVar.InitCondList))),...
                    analyVar.InitCondList,2)),indivDataset{basenameNum}.All_PCell{k},'UniformOutput',0);
            else
                error('imagefit:NoFitSaved','Cannot load fit file since no file exists matching the current parameters.')
            end
        end
end

%% Setup the independent variables between all similar scans for averaging
avgDataset = cell(1,length(analyVar.uniqScanList));
for uniqScanIter = 1:length(analyVar.uniqScanList);
    % Create a cell containing the scanned variable for each batch (set of images)
    indVars = arrayfun(@(x) indivDataset{x}.imagevcoAtom,analyVar.posOccurUniqVar{uniqScanIter},'UniformOutput',0);
    % Save a vector of all the unique scan pnts for comparison
    avgDataset{uniqScanIter}.simScanIndVar = double(unique(int32(cell2mat(indVars)*analyVar.compPrec)))*1/analyVar.compPrec;
end
end