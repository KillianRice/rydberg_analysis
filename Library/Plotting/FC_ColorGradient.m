function [ vec ] = FC_ColorGradient( Number_of_Colors, entry)
ColorArray = nan(Number_of_Colors, 3);
X13 = round(Number_of_Colors/3);
X23 = round(2*Number_of_Colors/3);
slopeSlow = 36/Number_of_Colors;
slopeFast = 557/Number_of_Colors;
for index = 1:Number_of_Colors
    if index < X13
        ColorArray(index,1) = 229-slopeSlow*index;
        ColorArray(index,2) = 180-slopeFast*index;
        ColorArray(index,3) = 0;
    elseif index >= X13 && index < X23 
        ColorArray(index,1) = 229-slopeSlow*index;
        ColorArray(index,2) = 0;
        ColorArray(index,3) = -155+slopeFast*index;
    elseif index >= X23
        ColorArray(index,1) = 557-slopeFast*index;
        ColorArray(index,2) = 0;
        ColorArray(index,3) = 229-slopeSlow*index;
    end
end
    ColorArray = ColorArray./255;
    ColorArray(ColorArray>1) = 1;
    ColorArray(ColorArray<0) = 0;

switch nargin
    case 1
        vec = ColorArray;
    case 2
        vec = ColorArray(entry, :);
end

end

