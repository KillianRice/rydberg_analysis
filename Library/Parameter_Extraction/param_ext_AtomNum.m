function [indivDataset] = param_ext_AtomNum(analyVar,indivDataset)
% Function to calculate the atomic number from each image found from the
% 2D fit parameters.
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
%                       winTotNum  - Total number of atoms
%                       winBECNum  - Total number of atoms in condensate (if present)
%                       winThrmNum - Total number of thermal atoms (if bimodal condensate)

%% Find type of fit used
fitType = strrep(analyVar.fitModel,analyVar.InitCase,'');

%% Define functions used to find atom number
% All function account for finite resolution of the camera so sigma = fitSigma*sizefactor
% fields{1:3} refer to amplitude, X sigma, and Y sigma respectively. (Used dynamically due to varying names)
%%%%%%%-----------------------------------%%%%%%%%%%
% Gaussian (integral of 2D gaussian)
funcGaussNum  = @(coeffs,fields) (2*pi*abs(coeffs.(fields{1}))/analyVar.AbsCross)*...
    (coeffs.(fields{2})*coeffs.(fields{3})*(analyVar.sizefactor)^2);

% Bose-enhanced Gaussian (Natali's thesis pg. 123 [eq. 6.10])
funcBoseExNum = @(coeffs,fields) (2*pi*abs(coeffs.(fields{1}))/analyVar.AbsCross)*...
    (coeffs.(fields{2})*coeffs.(fields{3})*(analyVar.sizefactor)^2)*(polylog(3,1)/polylog(2,1));

% Thomas-Fermi (reference needed)
funcTomFerNum = @(coeffs,fields) (3/4)*(8*pi/15)*abs(coeffs.(fields{1}))/(analyVar.AbsCross)*...
    abs((coeffs.(fields{2})))*abs((coeffs.(fields{3})))*analyVar.pixelsize^2;

%% Decide atom number function
% Atom number function is determined from what 2D number distribution fit
% was used in imagefit_NumDistFit
%%%%%%%-----------------------------------%%%%%%%%%%
switch analyVar.sampleType
    case {'Thermal' 'Lattice'}
        funcTotNum = @(coeffs) (funcGaussNum(coeffs,{'Amp' 'sigX' 'sigY'}));
    case 'BEC'
        % Find total atom number if Bimodal
        if strcmpi(analyVar.InitCase,'Bimodal')
            switch fitType
                case 'Gaussian'
                    funcBECNum = @(coeffs) (funcGaussNum(coeffs,{'Amp_BEC' 'sigX_BEC' 'sigY_BEC'}));
                case 'ThomasFermi'
                    funcBECNum = @(coeffs) (funcTomFerNum(coeffs,{'Amp_BEC' 'sigX_BEC' 'sigY_BEC'}));
            end
            funcThrmNum = @(coeffs) (funcBoseExNum(coeffs,{'Amp' 'sigX' 'sigY'}));
            funcTotNum  = @(coeffs) (funcBECNum(coeffs) + funcThrmNum(coeffs));
        else
             switch fitType
                case 'Gaussian'
                    funcTotNum = @(coeffs) (funcGaussNum(coeffs,{'Amp' 'sigX' 'sigY'}));
                case 'ThomasFermi'
                    funcTotNum = @(coeffs) (funcTomFerNum(coeffs,{'Amp' 'sigX' 'sigY'}));
            end
        end
end

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
for basenameNum = 1:analyVar.numBasenamesAtom
    % Preallocate nested loop variables
    [winTotNum, winBECNum, winThrmNum]...
        = deal(NaN(sum(analyVar.LatticeAxesFit),indivDataset{basenameNum}.CounterAtom));
    
    % Processes all the image files in the current batch
    for k = 1:indivDataset{basenameNum}.CounterAtom;
%% Compute number of atoms
% Find number in each window (if multiple windows) and find the number of
% thermal atoms if the distribution is bimodal
%%%%%%%-----------------------------------%%%%%%%%%%
        % Total number of atoms
        winTotNum(:,k) = cellfun(@(x) funcTotNum(x),indivDataset{basenameNum}.All_fitParams{k});
        
        %%% if 87 double the counted number of atoms %%%
        if analyVar.isotope == 87
            winTotNum(:,k) = winTotNum(:,k) * 2;
        end
        
        % Separate thermal and condensate contributions if bimodal
        if strcmpi(analyVar.InitCase,'Bimodal')
            winBECNum(:,k)  = cellfun(@(x) funcBECNum(x),indivDataset{basenameNum}.All_fitParams{k});
            winThrmNum(:,k) = cellfun(@(x) funcThrmNum(x),indivDataset{basenameNum}.All_fitParams{k});
        end  
    end
    
    % Save atom numbers into the indivDataset structure
    indivDataset{basenameNum}.winTotNum  = winTotNum;
    indivDataset{basenameNum}.winBECNum  = winBECNum;
    indivDataset{basenameNum}.winThrmNum = winThrmNum;
end