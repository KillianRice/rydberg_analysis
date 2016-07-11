function output=Intensity_Profile(wavelength, power, waist01, direction1, waist02, direction2, DirofProp)

% Function to take in lasre beam parameters and output intensity profile

% INPUTS:
%   wavelength - wavelength of laser beam (m)
%   power      - power of beam at the atoms (W)
%   waist1     - (minimal) waist of beam along direction1 (m)
%   direction1 - direction of waist1, 1 for x, 2 for y, 3 for z
%   waist2     - (minimal) waist of beam along direction2 (m)
%   direction2 - direction of waist2, 1 for x, 2 for y, 3 for z
%   DirofProp  - direction of beam propagation
% OUTPUTS:
%   output the intensity profile
x=direction1;%change of coordinates for convinience
y=direction2;
z=DirofProp;
%if(direction1==direction2, return and error saying direction of waists 
%must be orthoganol)
Rayleigh1=pi*waist01^2/wavelength;%m, Rayleigh range in direction of 
%propogation assosiated with waist1
Rayleigh2=pi*waist02^2/wavelength;%m, Rayleigh range in direction of 
%propogation assosiated with waist2
waist1=@(z) waist01*(1+(z/Rayleigh1)^2)^0.5;%m, spatially 
%dependant waist along direction1
waist2=@(z) waist02*(1+(z/Rayleigh2)^2)^0.5;%m, spatially 
%dependant waist along direction2
IntensityPeak=2*power/(pi*waist01*waist02);%W/m^2, intensity at focus of beam
output=@(x,y,z)...
    IntensityPeak...
    *(waist01*waist02/(waist1(waist01)*waist2(waist02)))...%account for axial displacement
    *exp(-2*x^2/waist1(waist01)^2)...%account for radial displacement
    *exp(-2*y^2/waist2(waist02)^2);

%maybe at the end I can do a variable substitution from x,y,z to
%dir1,dir2,dirofprop...?