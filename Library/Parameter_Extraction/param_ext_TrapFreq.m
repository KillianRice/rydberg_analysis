function [indivDataset] = param_ext_TrapFreq(analyVar,indivDataset)
% Function to calculate the trap frequency of bimodal condensate samples
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   indivDataset - Output will add the fields below to the structure
%                  indivDatset
%                       condTrapFreq - ODT trap frequencies after
%                                      evaporation


%% Define functions used to find trap frequency
%%%%%%%-----------------------------------%%%%%%%%%%
% Average of temperatures (found in param_ex_AtomTemp)
AvgTemp  = @(indiv,k) (indiv.atomTempX(k) + indiv.atomTempY(k))/2;
% Condensate fraction (found in param_ex_AtomNum)
CondFrac = @(indiv,k) (indiv.winBECNum(k)/indiv.winTotNum(k));
% Total Number (found in param_ex_AtomNum)
TotNum   = @(indiv,k) (indiv.winTotNum(k));
% Condensate transition temperature (Pethick and Smith Eq. 2.31)
Tc       = @(indiv,k) AvgTemp(indiv,k).*10.^(-9)./(1 - CondFrac(indiv,k)).^(1/3);
% Geometric average of trap freq (Pethick and Smith Eq. 2.20)
wBar     = @(indiv,k) analyVar.kBoltz.*Tc(indiv,k)./(0.94*analyVar.hbar*TotNum(indiv,k).^(1/3)); % in rad/second

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for basenameNum = 1:analyVar.numBasenamesAtom    
    % Count all images
    k = 1:indivDataset{basenameNum}.CounterAtom;
    
    % Save trap frequency for each image
    indivDataset{basenameNum}.condTrapFreq = wBar(indivDataset{basenameNum},k)/(2*pi);
end