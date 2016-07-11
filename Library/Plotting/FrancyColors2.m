function [ output ] = FrancyColors2( index )
% return color vector corresponding to index entry
% if index is set to -1, return the whole color array
colors = [...
    214/255 84/255 84/255;...   %01 red
    74/255 143/255 211/255;...  %02 blue
    231/255 186/255 82/255;...  %03 yellow
    142/255 204/255 100/255; ... %04 green
    138/255 73/255 126/255;...  %05 purple
    60/255  160/255 160/255;... %06 cyan
    
    %'transparent' colors
    247/255 206/255 206/255;... %07 red
    206/255 222/255 247/255;... %08 blue        
    247/255 231/255 206/255;... %09 yellow
    222/255 247/255 214/255; ... %10 green
    222/255 206/255 222/255;... %11 purple
    198/255 222/255 222/255 ... %12 cyan

    ];

if index == -1
    output = colors;
else
    output = colors(index,:);
end

end

