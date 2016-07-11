function y = polylog(n,z)
%%% Custom polylog function using curve fit for Polylog of order 2. Curve
%%% fit is a fit to the approx. method between z = [0,1]. This is done for
%%% speed. If curve fitting toolbox does not exist then use the approx
%%% method directly.

% Initialize y
y = zeros(length(z),1);

if n == 2 && exist('cftool','file')
    %%% Some matlab instances may not have Curve Fitting Toolbox
    load('n2_PolylogFit.mat')
    y(:) = n2_PolylogFit(z);
else
    % Only have curve for n == 2 or if no Curve fit toolbox use the
    % approx method directly.
    y = Approx_Polylog(n,z);
end
end

%% Approximate polylog, curve fit above is a fit to this function between 0 and 1
function y = Approx_Polylog(n,z) 
%%% polylog - Computes the n-based polylogarithm of z: Li_n(z)
% Approximate closed form expressions for the Polylogarithm aka de 
% Jonquiere's function are used. Computes reasonably faster than direct
% calculation given by SUM_{k=1 to Inf}[z^k / k^n] = z + z^2/2^n + ...
%
% Usage:   [y errors] = PolyLog(n,z)
%
% Input:   z < 1   : real/complex number or array
%          n > -4  : base of polylogarithm 
%
% Output: y       ... value of polylogarithm
%         errors  ... number of errors 
%
%
% following V. Bhagat, et al., On the evaluation of generalized
% Bose–Einstein and Fermi–Dirac integrals, Computer Physics Communications,
% Vol. 155, p.7, 2003
%
% v3 20120616
% -------------------------------------------------------------------------
% Copyright (c) 2012, Maximilian Kuhnert
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:  
% 
%     Redistributions of source code must retain the above copyright
%     notice, this list of conditions and the following disclaimer. 
%     Redistributions in binary form must reproduce the above copyright
%     notice, this list of conditions and the following disclaimer in the
%     documentation and/or other materials provided with the distribution.  
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          
% -------------------------------------------------------------------------

if nargin ~= 2
    error('[Error in: polylog function] Inappropriate number of input arguments!')
end

if (isreal(z) && sum(z(:)>1)>0) % check that real z is not bigger than 1 
    error('[Error in: polylog function] |z| > 1 is not allowed')
elseif isreal(z)~=1 && sum(abs(z(:))>1)>0 % check that imaginary z is defined on unit circle
    error('[Error in: polylog function] |z| > 1 is not allowed')
elseif n<=-4 % check that n is not too largly negative (see paper)
    error('[Error in: polylog function] n < -4 might be inaccurate')
end

% Initialize y
y = zeros(length(z),1);

% if |z| ~= 1 use Eq. (21)
if numel(z(abs(z) ~= 1)) > 0
    zTmp = z(abs(z) ~= 1);
    nominator = 6435*9^n.*S(n,zTmp,8) - 27456*8^n*zTmp.*S(n,zTmp,7) + ...
        + 48048*7^n*zTmp.^2.*S(n,zTmp,6) - 44352*6^n*zTmp.^3.*S(n,zTmp,5) + ...
        + 23100*5^n*zTmp.^4.*S(n,zTmp,4) - 6720*4^n.*zTmp.^5.*S(n,zTmp,3) + ...
        + 1008*3^n*zTmp.^6.*S(n,zTmp,2) - 64*2^n*zTmp.^7.*S(n,zTmp,1);
    denominator = 6435*9^n - 27456*8^n*zTmp + ...
        + 48048*7^n*zTmp.^2 - 44352*6^n*zTmp.^3 + ...
        + 23100*5^n*zTmp.^4 - 6720*4^n*zTmp.^5 + ...
        + 1008*3^n*zTmp.^6 - 64*2^n*zTmp.^7 + ...
        + zTmp.^8;
    y(z ~= 1) = nominator ./ denominator;
end

% if |z| == 1 use direct sum with specific accuracy to match order 2,3
% curves
if numel(z(z == 1)) > 0
   y(z == 1) = DirectSum_Polylog(n,1,2.5e-4); 
end
end

% define S as partial sums of Eq. 12:
function out = S(n,z,j)
    out  = 0;
    for i = 1:j
        out = out + z.^i./i^n;
    end
end


%% Older version of polylog which computes the sum directly
% If used at machine epsilon (eps) it is the most accurate approx to the
% Jonquiere function. (This is slow)
function y = DirectSum_Polylog(n,z,acc)
%%POLYLOG - Computes the n-polylogarithm of z (Li_n)
%
% Usage:   y = polylog(n,z)
%          y = polylog(n,z,acc)
%
% Input:   |z| < 1 : complex number defined on open unit disk
%          n       : base of polylogarithm
%          acc     : cutoff accuracy
%
% Output: y
%
% -------------------------------------------------------------------------
%  Copyright (C) 2009 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  
% -------------------------------------------------------------------------
if nargin == 2
   acc = 1e-10;
end

y = zeros(length(z),1); y(:) = z;
for j = 1:length(z);
    k   = 1;
    err = 1;
    zk  = z(j);
    while (abs(err)>acc);
        k    = k + 1;
        kn   = k^n;
        zk   = zk.*z(j);
        err  = zk./kn;
        y(j) = y(j) + err;
    end
end
end