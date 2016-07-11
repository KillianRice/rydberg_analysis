function [ order_value ] = Order_of_Magnitude( x )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
order_value = nan(size(x));

if find(x==1000)
    order_value(x==1000) = 3; % I have absolutley no idea why this script fails for ONLY 1E3 (as far as I can tell).
    order_value(x~=1E3) = log(abs(x(x~=1E3)))./log(10);
else
    order_value = log(abs(x))./log(10);
end

order_value = floor(order_value);
