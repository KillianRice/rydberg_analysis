function Z = PureGaussian(coeffs,data)
%% Functional form for fitting condensate image
% Fits BEC part to Gaussian profile
% Includes constant offset and linear background corrections

Amp     = coeffs(1);
SigX    = coeffs(2);
SigY    = coeffs(3);
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
  
%% Fitting function
Z = (Offset + SlopeX.*Xm + SlopeY.*Ym... % Linear background
    + abs(Amp)*exp(-(XpSq/(2*SigX^2)) - (YpSq/(2*SigY^2))))... % Condensate part
    ./wght; % Weighting
end