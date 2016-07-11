function [ Bounds ] = FreqWindow( FreqCenter, Width )
LowerBound = FreqCenter-Width;
UpperBound = FreqCenter+Width;
Bounds = [LowerBound UpperBound];
end

