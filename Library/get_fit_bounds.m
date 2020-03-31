function [lowBndVec, upBndVec] = get_fit_bounds(analyVar,basenameNum)
% Function to return the bounds for fitting using lsqcurvefit
%
% INPUTS:
%   analyVar - Structure containing all the global variables needed for analysis
%
% OUTPUTS:
%   lowBndVec - lower constraints vector
%   upBndVec  - upper constraints vector

% Number of Initial conditions should match number of constraints

%% Initialize constraints
[lowBndVec, upBndVec] = deal(nan(size(analyVar.InitCondList)));

%% Find bounds based on type of parameter
for i = 1:length(analyVar.InitCondList)
    switch analyVar.InitCondList{i}
        case {'Amp' 'Amp_BEC'}
            [lowBndVec(i) upBndVec(i)] = eval_str_bnds(analyVar,basenameNum,analyVar.lsqAmpBnd);
        case {'sigX' 'sigX_BEC' 'sigY' 'sigY_BEC'}
            [lowBndVec(i) upBndVec(i)] = eval_str_bnds(analyVar,basenameNum,analyVar.lsqSigBnd);
        case {'xCntr' 'yCntr'}
            [lowBndVec(i) upBndVec(i)] = eval_str_bnds(analyVar,basenameNum,analyVar.lsqCntBnd);
        case {'Offset' 'SlopeX' 'SlopeY'}
            [lowBndVec(i) upBndVec(i)] = eval_str_bnds(analyVar,basenameNum,analyVar.lsqLinBnd);
    end
end
end

function [lowBnd, upBnd] = eval_str_bnds(analyVar,basenameNum,bndCell) %#ok<INUSL>
% Function to evaluate bounds specified in AnalysisVariables
%
% INPUTS:
%   bndVec - Vector of bounds specified from AnalysisVariables. Currently
%            can evaluate strings referencing variables and regular
%            doubles.
%
% OUTPUTS:
%   lowBnd - lower constraint value
%   upBnd  - upper constraint value

% Initialize local variables
bndTypes = {'lowBnd','upBnd'};
upBnd = NaN; lowBnd = NaN;

%% Loop through both bounds and assign value
for i = 1:2 %Only two bounds
    if isa(bndCell{i},'char')
        bndStruct.(bndTypes{i}) = eval(bndCell{i});
    else
        bndStruct.(bndTypes{i}) = bndCell{i};
    end
    
    % Return the value specific to the run if needed
    if length(bndStruct.(bndTypes{i})) > 1
        bndStruct.(bndTypes{i}) = bndStruct.(bndTypes{i})(basenameNum);
    end
end

%% Unpack variables from structure
v2struct(bndStruct);
end
    