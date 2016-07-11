function output=Phase_Space_Density(analyVar, indivDataset, avgDataset)
%Fit to radius equation from Mi's PhD thesis
%sigma^2(t)=sigmaInitial^2+(kB T/M)t^2

% Function to plot the spectrum of atomic number.
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%   winTotNum    - Total number of atoms
%   winBECNum    - Total number of atoms in condensate (if present)
%   winThrmNum   - Total number of thermal atoms (if bimodal condensate)
%
% OUTPUTS:
%   Creates plots showing the atomic number. Valid plots are total number, 
%   BEC number, total number, or lattice peak number
%
%format shortEng %format numbers outputted

%% Start of Code to Calculculate Phase Space Density
%From mathematica notebook 84Sr_Loading_Trap_4.nb (02-23-2015)
%in "Z:\\Rydberg\\Projects\\Optical_Dipole_Trap\\" in the Drobo
%The recipe is as follows:
%to calculate phase space density you need:
%peak density and deBroglie wavelength
%to get deBroglie wavelength you need TEMPERATURE
%to get density you need ATOM NUMBER and first order effective volume
%to get first order effective volume you need TEMPERATURE and geometric
%   mean of the trap frequencies including the effect of gravity
%to get the geometric mean of the trap frequencies you need the displaced
%   (due to gravity) potential
%to get the undisplaced potential you need the beam intensity profiles
%to get the beam intensity profiles you need POWER

%This code will work for a simple cross-beam configuration; will have to
%update to include the ability to say something about the phase space
%density of a trap consisting of beams originating from an AOM with three
%RF frequencies.

%% Beam Intensity Profiles
%Have two beams entering the chamber at the moment, but want to have code
%general enough to be able to add more beams later. So for now what I will
%have is code to generate intensity for a beam that is either propagating
%in the x, y, or z direction (+/- does not matter); standing on the long
%side of the table with the IR laser on it, facing the chamber. y is 
%defined to be along the direction of the first arm which enters the 
%chamber at about -127 degrees. the x is the defined by the direction of
%the second arm which enters the chamber at about +143 degrees. z is
%therefore defined to be vertically up.

[phase_space_density]= deal(cell(1,analyVar.numBasenamesAtom));
indivDataset = PeakDensity(analyVar, indivDataset);
figure
hold on

for basenameNum = 1:analyVar.numBasenamesAtom
    
    phase_space_density{basenameNum}=indivDataset{basenameNum}.Peak_Density.*indivDataset{basenameNum}.deBroglie.^3;
    
    analyVar.COLORS(basenameNum,:)
    analyVar.MARKERS(basenameNum)
    semilogy(indivDataset{basenameNum}.imagevcoAtom',phase_space_density{basenameNum},analyVar.MARKERS{basenameNum},'Color',analyVar.COLORS(basenameNum,:))

end

indivDataset.phase_space_density = phase_space_density;

%hold on
plot(get(gca,'xlim'),[2.612,2.612],'-r')
output = 0;
warning('check that the calculation makes sense')
end

