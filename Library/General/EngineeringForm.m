function [ coefficient, EngOrder ] = EngineeringForm( x )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% order           = Order_of_Magnitude(x); %what is the order of magnitude for each value of x
% modulo          = mod(order,3); % what is the remainder of order/3
% coefficient     = x./10.^(order-modulo); %what is the number before the decimal in Engineering form
% EngOrder        = max(order-modulo);% what is the order of magnitude in Engineering form

order           = Order_of_Magnitude(x); %what is the order of magnitude for each value of x
order           = max(order);
modulo          = mod(order,3); % what is the remainder of order/3
coefficient     = x./10.^(order-modulo); %what is the number before the decimal in Engineering form
EngOrder        = order-modulo;% what is the order of magnitude in Engineering form

end

