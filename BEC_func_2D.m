function y = BEC_func(x,y,cfac,X0,Y0,Rtfx,Rtfy)
    y = heaviside(1-((x-X0)./Rtfx).^2-((y-Y0)./Rtfy).^2)*4*pi/3*cfac.*(1-((x-X0)./Rtfx).^2-((y-Y0)./Rtfy).^2).^(3/2);
end