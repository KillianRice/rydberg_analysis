function y = polylog(n,z) 
%% polylog - Computes the n-based polylogarithm of z: Li_n(z)
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
% Approximation should be correct up to at least 5 digits for |z| > 0.55
% and on the order of 10 digits for |z| <= 0.55!
%
% Please Note: z vector input is possible but not recommended as precision
% might drop for big ranged z inputs (unresolved Matlab issue unknown to 
% the author). 
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

% if |z| == 1 use direct sum at eps
if numel(z(z == 1)) > 0
    y(z == 1) = zeta(n);
end

% define S as partial sums of Eq. 12:
    function out = S(n,z,j)
        out  = 0;
        for i = 1:j
            out = out + z.^i./i^n;
        end
    end
    
end