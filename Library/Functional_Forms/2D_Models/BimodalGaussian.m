function Z = BimodalGaussian(coeffs,data)
%% Functional form for fitting condensate image
% Fits BEC part to Gaussian
% Fits Thermal part to Bose enhanced  Gaussian
% Includes constant offset and linear background corrections
%
%% Deal initial guess to variables
Amp_BEC  = coeffs(1);
SigX_BEC = coeffs(2);
SigY_BEC = coeffs(3);
Amp      = coeffs(4);
SigX     = coeffs(5);
SigY     = coeffs(6);
xCntr    = coeffs(7);
yCntr    = coeffs(8);
Offset   = coeffs(9); 
SlopeX   = coeffs(10);
SlopeY   = coeffs(11);

% Fix fugacity when analyzing condensates (Natali's thesis)
fugacity = 1;

% Separate coordinate grid, weighting vector, and rotation
X    = data(:,1); Y = data(:,2);
wght = data(:,3); %Extra vector for weighting if needed
rotAngle = 0*pi/180; % It was 30 degree in 84Sr data fitting

% Redefine x & y vector about center
Xm = X - xCntr; Ym = Y - yCntr;
% If condensate is rotated with respect to the image plane then find the
% projection onto the principle axes
XpSq = ((cos(rotAngle).*Xm).^2 + (2.*cos(rotAngle).*sin(rotAngle).*Xm.*Ym) + (sin(rotAngle).*Ym).^2);
YpSq = ((sin(rotAngle).*Xm).^2 - (2.*cos(rotAngle).*sin(rotAngle).*Xm.*Ym) + (cos(rotAngle).*Ym).^2);
  
%% Functional form
Z = (Offset + SlopeX.*Xm + SlopeY.*Ym ... % Linear Background
    + abs(Amp_BEC)*exp(-XpSq/(2*SigX_BEC^2) - YpSq/(2*SigY_BEC^2))... % Condensate part
    + (abs(Amp).*polylog(2,fugacity.*exp(-XpSq/(2*SigX^2) - YpSq/(2*SigY^2))))/polylog(2,fugacity))... % Thermal pedestal
    ./wght; % Weighting
end