function sumSquaredDiff = WeightedBackgroundFunction(coefficients,state,basisSet)
% Weight background images by coefficients in A then compare the squared
% difference. Fminsearch will attempt to minimize the squared difference by
% changing coefficients in A. 
% In linear algebra terms, we're attempting to decompose each atom 
% background into a linear combination of the background image basis set.
%
% INPOUTS
%   coefficeitns   - Coefficients of the background basis set
%   state          - Background image of atoms (minus the cloud)
%   basisSet       - All background images of dataset which define the basis
%                    set we'd like to decompose the atom backgrounds
%                    into
%
% OUTPUTS
%   sumSqauredDiff - squared difference between current linear decomposition and atom
%                    background image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define current linear decomposition of background based on coefficients A
stateApprox = sum(bsxfun(@times,basisSet,coefficients),2);
% Determine squared difference between current decomposition and atom
% background in order to minimize.
sumSquaredDiff = sum((state - stateApprox).^2);