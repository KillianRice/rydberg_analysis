function [ BECSize, BECSize_error ] = BEC_Size( analyVar, Ave_AtomNum, Ave_AtomNum_error);
%% Calculate the in situ BEC size
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

BECSize         = (15*N*a84).^(1/5)*aBar^(4/5);
BECSize_error   = BECSize.*((N_error./(5*N)).^2+(4*aBar_error./(5*aBar)).^2).^0.5;

end

