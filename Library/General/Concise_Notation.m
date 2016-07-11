function [ Quantity_String,  Uncertainty_String] = Concise_Notation( Quantity, Uncertainty, SigFigs )
% Franciso Camargo 2016-03-31
% Return the strings needed to present a quantity of interest in 'concise'
% notation; the uncertainty is parenthesis following the estimate of the
% quantity. Also returned will be a string used to establish the order of
% magnitude.

integerTest=~mod(SigFigs,1); % 1 if integer
if integerTest ~= 1
    error('SigFigs must be made to be a positive integer.')
end
if SigFigs <= 0
    error('SigFigs must be made to be a positive integer.')
end

Uncertainty_order   = Order_of_Magnitude( Uncertainty );
Uncertainty0        = round(Uncertainty/10^(Uncertainty_order-SigFigs+1));
Uncertainty         = Uncertainty0*10^(Uncertainty_order-SigFigs+1);
Uncertainty_order0  = Order_of_Magnitude( Uncertainty );

%% Repeat if rounding up of the Uncertainty has occured
% EX: 1+/-0.099 with 1 SigFig will cause the Uncertainty to round to 0.1
%   so need to repeat to adjust the value of the order of magnitude of the
%   Uncertainty since the answer needs to be 1.0(1)

while Uncertainty_order0 ~= Uncertainty_order
    Uncertainty_order   = Order_of_Magnitude( Uncertainty );
    Uncertainty0        = round(Uncertainty/10^(Uncertainty_order-SigFigs+1));
    Uncertainty         = Uncertainty0*10^(Uncertainty_order-SigFigs+1);
    Uncertainty_order0  = Order_of_Magnitude( Uncertainty );
end

if Uncertainty_order <= 0
    order_String        = ['%0.' sprintf('%0.0f', abs(Uncertainty_order0-SigFigs+1)) 'f'];
    Uncertainty_String  = sprintf('%0.0f', Uncertainty0);
else
    order_String        = '%0.0f';
    Uncertainty_String  = sprintf('%0.0f', Uncertainty);
end

Quantity_String = sprintf(order_String, Quantity);


end

