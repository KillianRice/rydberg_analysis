function y = BEC_func(x,cfac,x0,rtf)
    y = heaviside(1-((x-x0)./rtf).^2)*pi/2*cfac.*(1-((x-x0)./rtf).^2).^2;
end