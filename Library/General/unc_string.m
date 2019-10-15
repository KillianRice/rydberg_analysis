function unc_string = unc_string(x, dx)
    %  unc_string - Joe Whalen, 2019.10.15
    %  Given a measured quantity and its uncertainty creates a string with
    %  parenthetical error bars i.e.:
    %  x = 0.05, dx = 0.0001 -> unc_string = 5.00(1)E-2

    digits_of_precision = floor(log10(x)) - floor(log10(dx));
    x_fmt = strcat('%.',num2str(digits_of_precision),'f');
    dx_fmt = '(%.0f)';
    exponent = 'E%+.0f';
    
    unc_string = [ num2str(x/10^floor(log10(x)),x_fmt),...
                    num2str(dx/10^floor(log10(dx)),dx_fmt),...
                    num2str(floor(log10(x)), exponent)];
end

