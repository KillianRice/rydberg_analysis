function [ Order_value ] = Order_of_Magnitude2( x )
%Order_of_Magnitude2 Calculate the value of the exponent needed to write x
%in SCIENTIFIC notation.
x = x.*1e6;
Order_value = log(abs(x))./log(10);
Order_value = int32(Order_value);
Order_value = floor(Order_value);
Order_value = Order_value - 6;
Order_value = double(Order_value);