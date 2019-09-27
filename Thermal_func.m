function y = Thermal_func(x,Thfac,x0,sigmax)
y = pi*Thfac.*polylogcopy(5/2,exp(-(x-x0).^2./sigmax^2));
end
