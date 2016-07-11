function [ colors ] = RedToBlue( num )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    reds   = linspace(1,.06,num)';
    greens = linspace(0,.22,num)';
    blues  = linspace(0.06,1,num)';
    colors = [reds greens blues];

end