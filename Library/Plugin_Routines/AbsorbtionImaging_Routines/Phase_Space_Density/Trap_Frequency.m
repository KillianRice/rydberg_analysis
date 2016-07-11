function [indivDataset]=Trap_Frequency(analyVar,indivDataset)

% Function to take in laser beam parameters and output intensity profile

% INPUTS:

% OUTPUTS:
%   output     - trap frequency in s^-1



Epsilon0=analyVar.Epsilon0;
mass=analyVar.mass;
Polarizability=analyVar.Polarizability;
SpeedOfLight=analyVar.SpeedOfLight;
Gravity=analyVar.Gravity;
IRwavelength=analyVar.IRwavelength;
wx0A=analyVar.wx0A;
wz0A=analyVar.wz0A;
wy0B=analyVar.wy0B;
wz0B=analyVar.wz0B;
voltages = cell(1,analyVar.numBasenamesAtom);

if analyVar.EvaporationVoltages
    evaporationTrajectory(scanDataSet);
else
    for ii=1:analyVar.numBasenamesAtom
    voltages{ii} = indivDataset{ii}.TrapPower;
    end
end

Trap_Frequency = cell(1,analyVar.numBasenamesAtom);

for kk=1:analyVar.numBasenamesAtom
    
    Trap_Frequency{kk}  = nan(1, indivDataset{kk}.CounterAtom);
    
    for jj = 1:indivDataset{kk}.CounterAtom
        
    PA=analyVar.ODTPowerConversion*voltages{kk}(jj); %power
    %of first arm of laser beam given by voltage in DAQ times conversion from
    %analyVar
    PB=PA;%set power of second arm equal to first for now


    %%Hard code the trap frequency functions including the effect of gravity
    %%for a cross-arm ODT trap with orthogonal beams in the horizontal plane.
    Trap_Frequency_x=...
      (1/2).*pi.^(-3/2).*(Epsilon0.^(-1).*mass.^(-1).* ...
      Polarizability.^(-1).*SpeedOfLight.^(-1).*(16.*exp(1).^(( ...
      -1/8).*Epsilon0.^2.*Gravity.^2.*mass.^2.*pi.^2.* ...
      Polarizability.^(-2).*SpeedOfLight.^2.*wx0A.^2.*wy0B.^2.* ...
      wz0A.^4.*wz0B.^6.*(PB.*wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^( ...
      -2)).*PA.*pi.^2.*Polarizability.^2.*wx0A.^(-3).*wz0A.^(-1)+ ...
      exp(1).^((-1/8).*Epsilon0.^2.*Gravity.^2.*mass.^2.*pi.^2.* ...
      Polarizability.^(-2).*SpeedOfLight.^2.*wx0A.^2.*wy0B.^2.* ...
      wz0A.^6.*wz0B.^4.*(PB.*wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^( ...
      -2)).*IRwavelength.^2.*PB.*wy0B.^(-5).*wz0B.^(-5).*(PB.* ...
      wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^(-2).*((-1).*Epsilon0.^2.* ...
      Gravity.^2.*mass.^2.*pi.^2.*SpeedOfLight.^2.*wx0A.^2.* ...
      wy0B.^6.*wz0A.^6.*wz0B.^4+4.*Polarizability.^2.*(PB.*wx0A.* ...
      wz0A.^3+PA.*wy0B.*wz0B.^3).^2.*(wy0B.^4+wz0B.^4)))).^(1/2);

    Trap_Frequency_y=...
      (1/2).*pi.^(-3/2).*(Epsilon0.^(-1).*mass.^(-1).* ...
      Polarizability.^(-1).*SpeedOfLight.^(-1).*(16.*exp(1).^(( ...
      -1/8).*Epsilon0.^2.*Gravity.^2.*mass.^2.*pi.^2.* ...
      Polarizability.^(-2).*SpeedOfLight.^2.*wx0A.^2.*wy0B.^2.* ...
      wz0A.^6.*wz0B.^4.*(PB.*wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^( ...
      -2)).*PB.*pi.^2.*Polarizability.^2.*wy0B.^(-3).*wz0B.^(-1)+ ...
      exp(1).^((-1/8).*Epsilon0.^2.*Gravity.^2.*mass.^2.*pi.^2.* ...
      Polarizability.^(-2).*SpeedOfLight.^2.*wx0A.^2.*wy0B.^2.* ...
      wz0A.^4.*wz0B.^6.*(PB.*wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^( ...
      -2)).*IRwavelength.^2.*PA.*wx0A.^(-5).*wz0A.^(-5).*(PB.* ...
      wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^(-2).*((-1).*Epsilon0.^2.* ...
      Gravity.^2.*mass.^2.*pi.^2.*SpeedOfLight.^2.*wx0A.^6.* ...
      wy0B.^2.*wz0A.^4.*wz0B.^6+4.*Polarizability.^2.*(wx0A.^4+ ...
      wz0A.^4).*(PB.*wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^2))).^(1/2);

    Trap_Frequency_z=...
      pi.^(-1/2).*(Epsilon0.^(-1).*mass.^(-1).*Polarizability.^( ...
      -1).*SpeedOfLight.^(-1).*(PB.*wx0A.*wz0A.^3+PA.*wy0B.* ...
      wz0B.^3).^(-2).*(exp(1).^((-1/8).*Epsilon0.^2.*Gravity.^2.* ...
      mass.^2.*pi.^2.*Polarizability.^(-2).*SpeedOfLight.^2.* ...
      wx0A.^2.*wy0B.^2.*wz0A.^6.*wz0B.^4.*(PB.*wx0A.*wz0A.^3+PA.* ...
      wy0B.*wz0B.^3).^(-2)).*PB.*wy0B.^(-1).*wz0B.^(-3).*((-1).* ...
      Epsilon0.^2.*Gravity.^2.*mass.^2.*pi.^2.*SpeedOfLight.^2.* ...
      wx0A.^2.*wy0B.^2.*wz0A.^6.*wz0B.^4+4.*Polarizability.^2.*( ...
      PB.*wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^2)+exp(1).^((-1/8).* ...
      Epsilon0.^2.*Gravity.^2.*mass.^2.*pi.^2.*Polarizability.^( ...
      -2).*SpeedOfLight.^2.*wx0A.^2.*wy0B.^2.*wz0A.^4.*wz0B.^6.*( ...
      PB.*wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3).^(-2)).*PA.*wx0A.^(-1) ...
      .*wz0A.^(-3).*((-1).*Epsilon0.^2.*Gravity.^2.*mass.^2.* ...
      pi.^2.*SpeedOfLight.^2.*wx0A.^2.*wy0B.^2.*wz0A.^4.*wz0B.^6+ ...
      4.*Polarizability.^2.*(PB.*wx0A.*wz0A.^3+PA.*wy0B.*wz0B.^3) ...
      .^2))).^(1/2);
  
    Trap_Frequency{kk}(jj) = abs((Trap_Frequency_x.*Trap_Frequency_y.*Trap_Frequency_z).^(1/3));
    
    end
    
    indivDataset{kk}.Trap_Frequency = Trap_Frequency{kk};

end
end