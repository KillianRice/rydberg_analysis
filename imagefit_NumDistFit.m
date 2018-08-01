    function imagefit_NumDistFit(varargin)
%This program is designed to read several datafiles and corresponding background
%files,  plots these normalized data sets on the same graph.
%
% INPUTS:
%   varargin - variable input argument to allow passing of analysis
%              variables from analysis runner program. If not passed, the
%              program will call AnalysisData itself.
%              It is important to follow the input construction below for
%              varargin to retrieve variable data from other programs.
%              -- first  argument - analyVar
%              -- second argument - indivDataset
%
% OUTPUTS:
%   none
%
% NOTES:
%   12.10.13 - Changed name from imagefit_GaussianBimodal_P6v
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load variables and file data
if nargin == 0 % If run without arguments
    analyVar     = AnalysisVariables;
    indivDataset = get_indiv_batch_data(analyVar);
else
    analyVar     = varargin{1}; % if arguments are passed analyVar must be first
    indivDataset = varargin{2}; % indivDataset must be second
end

%% Initialize parallel workers
%Open parpool if none open
% if parpool('size') == 0
%     parpool open
% end

%% Loop through each batch file listed in basenamevectorAtom
for basenameNum = 1:analyVar.numBasenamesAtom
    % this will keep track of all the files analyzed in all the batches
    fprintf('\nCloud fitting batch file %g of %g\n',basenameNum,analyVar.numBasenamesAtom)
    
    % Process all the data files in this batch
    parfor k = 1:indivDataset{basenameNum}.CounterAtom;
%% Retrieve OD image from file
%%%%%%%-----------------------------------%%%%%%%%%%
        if exist([analyVar.analyOutDir char(indivDataset{basenameNum}.fileAtom(k)) analyVar.ODimageFilename],'file')
            OD_Image_Single = dlmread([analyVar.analyOutDir char(indivDataset{basenameNum}.fileAtom(k)) analyVar.ODimageFilename]);
        else
            % Error if background subtraction not run (means no OD file saved)
            callStruct = dbstack(0);
            error('%s Cannot find \n\t%s',...
                callStruct.name,[indivDataset{basenameNum}.fileAtom{k} analyVar.ODimageFilename]);
        end
        
        % Save logical mask to local variable for convenience
        roiWin_Index = indivDataset{basenameNum}.roiWin_Index;
        
%% Smooth image using moving average if needed
%%%%%%%-----------------------------------%%%%%%%%%%
            if analyVar.fitSmoothOD
                OD_Image_Single = analyVar.smoothFilt(OD_Image_Single,analyVar.smoothFiltMat);
            end

%% Retrieve windowed image to be fitted    
%%%%%%%-----------------------------------%%%%%%%%%%
            OD_Fit_ImageCell = cellfun(@(x) reshape(OD_Image_Single(x),[1 1]*analyVar.funcFitWin(basenameNum)),...
                cellfun(analyVar.fitWinLogicInd,roiWin_Index,'UniformOutput',0),'UniformOutput',0);
            
%% Initial guesses
%%%%%%%-----------------------------------%%%%%%%%%%           
            % Get initial guesses for non-linear fitting
            InitGuess = get_fit_params(analyVar,OD_Image_Single,OD_Fit_ImageCell,indivDataset,basenameNum,k);
            
%% Fitting constraints
%%%%%%%-----------------------------------%%%%%%%%%%           
            % Assign fit constaints specified in AnalysisVariables
            [lowBndVec, upBndVec] = get_fit_bounds(analyVar,basenameNum);
            lowBndCell = mat2cell(repmat(lowBndVec,size(InitGuess)),ones(1,size(InitGuess,1),size(InitGuess,2)));
            upBndCell  = mat2cell(repmat(upBndVec,size(InitGuess)),ones(1,size(InitGuess,1),size(InitGuess,2)));

%% Weighting 
%%%%%%%-----------------------------------%%%%%%%%%%
            % Return a weighting cell if needed
            errCell = cellfun(@(x) get_OD_weight(analyVar.weightPeak,x),OD_Fit_ImageCell,'UniformOutput',0);

%% Fitting routine
%%%%%%%-----------------------------------%%%%%%%%%%
                % Generate spatial coordinates (independent variables)
                [Xgrid,Ygrid] = meshgrid(1:length(OD_Fit_ImageCell{1}));
                
                % lsqcurvefit options
                optimOpt = optimset('Display','off','FinDiffType','central','TolFun',1e-9,'TolX',1e-9);
                
                % Call to fitting function chosen in AnalysisVariables by specifying sampleType
                %   Simplified function call is 
                %   [P,R,J] = nlinfit([XData(:), YData(:), error(:)],OD_Fit_Image./error,@modelName,InitGuess)
                PCell = cellfun(@(x,y,z,lb,ub) (lsqcurvefit(str2func(analyVar.fitModel),z,[Xgrid(:), Ygrid(:), y(:)], x(:),lb,ub,optimOpt)),...
                            cellfun(@(m,n) (m(:)./n(:)),OD_Fit_ImageCell,errCell,'UniformOutput',0),...
                            errCell, InitGuess,lowBndCell,upBndCell,'UniformOutput',0);          
                        
%% Writing fit coefficients to disk
%%%%%%%-----------------------------------%%%%%%%%%%
                % Tack on whether weighting was used or not (to avoid
                % problems due to changing the option between fitting and plotting)
                PCell = cellfun(@(x) [x' analyVar.weightPeak],PCell,'UniformOutput',0);
                    
                % Write fit parameters to file
                dlmwrite([analyVar.analyOutDir char(indivDataset{basenameNum}.fileBack(k)) ...
                    analyVar.sampleType analyVar.fitModel analyVar.paramFitFilename ...
                    analyVar.paramFitFileExt],PCell,'\t')
    end % end loop through each dataset
end     % end loop through master batch file


%% Wrap Up
fclose('all'); % Close any file handles which may be open
fprintf('The cloud fitting is completed.\n\n')