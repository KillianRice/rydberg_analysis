function [indivDataset] = param_ext_AtomTemp(analyVar,indivDataset)
% Function to calculate the thermal and BEC cloud size from each 
% image found from the 2D fit parameters.
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
%                    AtomTempX - Temperature (nK) of the cloud along X
%                    AtomTempY - Temperature (nK) of the cloud along Y

%% Define functions used to find cloud temperature
%%%%%%%-----------------------------------%%%%%%%%%%
% Cloud temperature when the droptime is much longer than the trap
% frequencies at the end of forced evaporation
% Reference - Natali's Ph.D thesis Ch. 6 (eq. 6.6)
funcTemp = @(coeffs,fitWidth,iter) ((coeffs.(fitWidth).*analyVar.sizefactor).^2.*analyVar.mass)./...
                                     (analyVar.kBoltz.*(analyVar.droptimeAtom(iter)*1e-3).^2);

%% Decide cloud width parameters needed
% Temperature is only a relevant parameter for thermal clouds or bimodal condensates
%%%%%%%-----------------------------------%%%%%%%%%%
paramTempX = 'sigX'; paramTempY = 'sigY';

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%

for basenameNum = 1:analyVar.numBasenamesAtom
    % Preallocate nested loop variables
    
    [tempX, tempY]...
        = deal(NaN(1,indivDataset{basenameNum}.CounterAtom));
    
    % Processes all the image files in the current batch
    for k = 1:indivDataset{basenameNum}.CounterAtom;
    %% Find cloud temperature
    % Find temperature of central window (this is the only case thats relevant)
        tempX(:,k) = funcTemp(indivDataset{basenameNum}.All_fitParams{k}{1},paramTempX,basenameNum);
        tempY(:,k) = funcTemp(indivDataset{basenameNum}.All_fitParams{k}{1},paramTempY,basenameNum);
    end
    
    % Save cloud temperature for each window into the indivDataset structure
    indivDataset{basenameNum}.atomTempX = tempX;
    indivDataset{basenameNum}.atomTempY = tempY;
    
    if analyVar.TempXY
        indivDataset{basenameNum}.atomTemp  = (tempX.*tempY).^0.5;
    else
        indivDataset{basenameNum}.atomTemp  = (tempX.*tempX).^0.5;
    end
    indivDataset{basenameNum}.deBroglie = (2*pi*analyVar.hbar^2./...
    (analyVar.mass*analyVar.kBoltz.*indivDataset{basenameNum}.atomTemp)...
    ).^0.5;

end
end
