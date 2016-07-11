function Z = BimodalThomasFermi(coeffs,data)
%% Functional form for fitting condensate image
% Fits BEC part to Thomas-Fermi profile
% Fits Thermal part to Bose enhanced Gaussian
% Includes constant offset and linear background corrections
%
% NOTE: Widths SigX_BEC and SigY_BEC are defined as 
%       Sig = exp(logSig) in order to constrain the fit values to be
%       positive.
%       Widths SigX and SigY are defined as
%       Sig_Th^2 = Sig_BEC^2 + beta^2 to constrin the fit of the thermal
%       width to be greater than the BEC width
%
%% Deal initial guess to variables
Amp_BEC     = coeffs(1);
logSigX_BEC = coeffs(2);
logSigY_BEC = coeffs(3);
Amp         = coeffs(4);
betaSigX    = coeffs(5);
betaSigY    = coeffs(6);
xCntr       = coeffs(7);
yCntr       = coeffs(8);
Offset      = coeffs(9); 
SlopeX      = coeffs(10);
SlopeY      = coeffs(11);

% Fix fugacity when analyzing condensates (Natali's PhD thesis p. 132)
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

% Determine real widths (due to reparamterization)
SigX_BEC = exp(logSigX_BEC); SigY_BEC = exp(logSigY_BEC);
SigX = sqrt(SigX_BEC^2 + betaSigX^2); SigY = sqrt(SigY_BEC^2 + betaSigY^2);

%% Fitting function
Z =  (Offset + SlopeX.*(Xm) + SlopeY.*(Ym)... % Linear background
    + heaviside(1 - (XpSq./(SigX_BEC.^2)) - (YpSq./(SigY_BEC.^2)))... % Condensate cutoff
    .* Amp_BEC.*(1 - (XpSq./(SigX_BEC.^2)) - (YpSq./(SigY_BEC.^2))).^(3/2)... % Condensate part
    + Amp.*polylog(2,fugacity.*exp(-XpSq/(2*SigX^2) - YpSq/(2*SigY^2)))/polylog(2,fugacity))... % thermal pedestal
    ./wght; % Weighting
end


%% Archive (just in case)
% Added by Jim (1-10-14)
% % x0=atan(coeffs(10))*8/pi;
% % y0=atan(coeffs(11))*8/pi;
% % xoffsetBEC=coeffs(12);
% % yoffsetBEC=coeffs(13);
% 
% x = data(:,1);  %Data split into x and y vectors
% y = data(:,2);
% w = data(:,3);  %Extra vector for weighting if needed
% numberofpoints = data(:,4);%matrix in which each entry is the number of points 
% sqrtnumbpoints = sqrt(numberofpoints(1,1)); %sqrt of number of points
%   
% Z = (heaviside(1 - ((x - xOffset).^2./(logSigX_BEC.^2)) - ((y - yOffset).^2./(logSigY_BEC.^2))).*...
%      abs(Amp_BEC).*(1 - ((x - xOffset).^2./(logSigX_BEC.^2)) - ((y - yOffset).^2./(logSigY_BEC.^2))).^(3/2)...
%     + (Offset + SlopeX.*(x - xOffset) + SlopeY.*(y - yOffset)+...
%     (Amp.*polylog(2,fugacity.*exp(-(x - xOffset).^2/(2*betaSigX.^2)).*exp(-(y - yOffset).^2./(2*betaSigY.^2)))/...
%     polylog(2,fugacity))))./wght;

%%% Older methods - Added by Jim (2013)
% Z = (offset+slopex*(x-xoffset)+slopey*(y-yoffset)+...
%     (peakOD*polylog(2,fugacity.*exp(-(x-xoffset).^2/(2*sigmax^2)).*exp(-(y-yoffset).^2/(2*sigmay^2)),accuracy)/...
%     polylog(2,fugacity,accuracy)))./(w*sqrtnumbpoints)+...
%     (heaviside(1-((x-xoffsetBEC).^2./(x0.^2))-((y-yoffsetBEC).^2./(y0.^2))).*...
%      abs(amplitudeBEC).*(1-((x-xoffsetBEC).^2./(x0.^2))-((y-yoffsetBEC).^2./(y0.^2))).^(3/2))./...
%     (w.*sqrtnumbpoints)
%Z = (offset + slopex*(x - xoffset) + slopey*(y - yoffset) + (peakOD*dilog(fugacity.*exp(-(x - xoffset).^2/(2*sigmax^2)).*exp(-(y - yoffset).^2/(2*sigmay^2)))/dilog(fugacity)))./(w*sqrtnumbpoints)