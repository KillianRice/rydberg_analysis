function [ Density, Density_error ] = Thermal_PeakDensity( analyVar, Ave_AtomNum, Ave_AtomNum_error, Ave_Temp, Ave_Temp_error )

kB = analyVar.kBoltz;
mass = analyVar.mass;
trapfreqZ       = analyVar.trapfreqZ;
trapfreqZ_error = analyVar.trapfreqZ_error;
trapfreqX       = analyVar.trapfreqX;
trapfreqX_error = analyVar.trapfreqX_error;
trapfreqY       = analyVar.trapfreqY;
trapfreqY_error = analyVar.trapfreqY_error; 

trapfreq = (trapfreqX*trapfreqY*trapfreqZ)^(1/3);
trapfreq_error = trapfreq*(...
    (trapfreqX_error/(trapfreqX*3))^2+...
    (trapfreqY_error/(trapfreqY*3))^2+...
    (trapfreqZ_error/(trapfreqZ*3))^2 ...
)^0.5;

Volume = (...
        2*pi*kB*Ave_Temp/...
        (mass*trapfreq.^2)...
        ).^(3/2);

Volume_error = Volume.*(...
    (3*Ave_Temp_error./(Ave_Temp*2)).^2+...
    (3*trapfreq_error/trapfreq)^2 ...
    ).^0.5;    
    
Density = Ave_AtomNum./Volume;
Density_error = Density.*(...
    (Ave_AtomNum_error./Ave_AtomNum).^2+...
    (Volume_error./Volume).^2 ...
    ).^0.5;    
end
