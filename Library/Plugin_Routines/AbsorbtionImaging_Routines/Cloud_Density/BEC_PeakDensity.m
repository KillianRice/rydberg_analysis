function [ Density, Density_error ] = BEC_PeakDensity( analyVar, Ave_AtomNum, Ave_AtomNum_error)
N = Ave_AtomNum;
N_error = Ave_AtomNum_error;

hBar    = analyVar.hbar;
a84     = analyVar.a84;
mass    = analyVar.mass;

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

aBar        = hBar^0.5*mass^(-0.5)*trapfreq^(-0.5);
aBar_error  = aBar*((trapfreq_error/(2*trapfreq))^2)^0.5;

mu          = 15^(2/5)*2^-1*hBar*a84^(2/5)*N.^(2/5)*aBar^(-2/5)*trapfreq;
mu_error    = mu.*(...
                (2*N_error./(5*N)).^2+...
                (2*aBar_error/(5*aBar))^2+...
                (trapfreq_error/trapfreq)^2 ...
                ).^0.5;    

U0 = 4*pi*hBar^2*a84/mass;            
            
Density         = mu./U0;
Density_error   = Density.*(...
                    (mu_error./mu).^2 ...
                    ).^0.5;    
end

