function [nrow, ncol] = arrange_subplots(n, imagesz)
% function [nrow, ncol] = arrange_subplots(n,imagesz)
%
% Purpose
% Calculate how many rows and columns of sub-plots are needed to
% neatly display n subplots. This function considers the size of each subplot.
%
% Inputs
% n - the desired number of subplots.
% imagesz - [height, width] of each subplot. default([1,1])
%
% Outputs
% [nrow, ncol] - defining the number of rows and number of columns required
%                to show n plots.
%
% Example:  [nrow, ncol] = arrange_subplots(26, [200,500])
%           [nrow, ncol] = arrange_subplots(26)
%
% Written by Geng Zhang. (www.bfcat.com). Jan. 2013

if nargin > 1 && numel(imagesz)==2
    ratio = imagesz(2)/imagesz(1);
elseif nargin > 1 && numel(imagesz) == 1
    ratio = imagesz;
else
    ratio = 1;
end

N = n*ratio;
sqr = sqrt(N);
p = [0 0];
if ratio<1
    p(1) = ceil(sqr);
    p(2) = floor(n/p(1));
else
    p(1) = floor(sqr);
    p(2) = ceil(n/p(1));
end

while (max(p)-1)*min(p) >= n
    [~,loc] = max(p);
    p(loc) = p(loc)-1;
end

nrow = p(1);
ncol = p(2);