function y = Thermal_func(x,y,Thfac,X0,Y0,Sigmax,Sigmay)
    y = sqrt(pi)*Thfac.*polylogcopy(2,exp(-(x-X0).^2./Sigmax^2-(y-Y0).^2./Sigmay^2));
end
