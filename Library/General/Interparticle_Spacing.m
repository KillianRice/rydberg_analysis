function [Spacing, Spacing_error] = Interparticle_Spacing(Density, Density_error)

%Wigner-Seitz Radius
Spacing         = (3./(4*pi*Density)).^(1/3);
Spacing_error   = Spacing.*((Density_error./(3*Density)).^2).^0.5;

end

