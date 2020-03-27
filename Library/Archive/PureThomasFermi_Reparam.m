function Z = PureThomasFermi(coeffs,data)
%% Functional form for fitting condensate image
% Fits BEC part to Thomas-Fermi profile
% Includes constant offset and linear background corrections
%
% NOTE: Widths SigX and SigY are defined as 
%       Sig = exp(logSig) in order to constrain the fit values to be
%       positive.
%
%% Deal inital guesses to variables
Amp     = coeffs(1);
logSigX = coeffs(2);
logSigY = coeffs(3);
xOffset = coeffs(4);
yOffset = coeffs(5);
Offset  = coeffs(6); 
SlopeX  = coeffs(7);
SlopeY  = coeffs(8);

% Separate coordinate grid, weighting vector, and rotation
X    = data(:,1); Y = data(:,2);
wght = data(:,3); %Extra vector for weighting if needed
rotAngle = 0*pi/180; % It was 30 degree in 84Sr data fitting

% Redefine x & y vector about center
Xm = X - xOffset; Ym = Y - yOffset;
% If condensate is rotated with respect to the image plane then find the
% projection onto the principle axes
XpSq = ((cos(rotAngle).*Xm).^2 + (2.*cos(rotAngle).*sin(rotAngle).*Xm.*Ym) + (sin(rotAngle).*Ym).^2);
YpSq = ((sin(rotAngle).*Xm).^2 - (2.*cos(rotAngle).*sin(rotAngle).*Xm.*Ym) + (cos(rotAngle).*Ym).^2);

% Determine real width by applying exponential (due to reparamterization)
SigX = exp(logSigX); SigY = exp(logSigY);

%% Fitting function
Z =   (Offset + SlopeX.*(Xm) + SlopeY.*(Ym)... % Linear background
    +  heaviside(1 - (XpSq./(SigX.^2)) - (YpSq./(SigY.^2)))... % Condensate cutoff
    .* Amp.*(1 - (XpSq./(SigX.^2)) - (YpSq./(SigY.^2))).^(3/2))... % Condensate part
    ./ wght; % Weighting
end