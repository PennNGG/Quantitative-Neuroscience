function vals_ = ddPow5(fits, data)
% function vals_ = ddPow5(fits, data)
%
% 5 parameters: A, alpha, PHI, R0, M
%
% Computes TIME-based DD function with LAPSE and BIAS.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^M
%   And on time as a power function
%       T.^N
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... time (sec)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... N      (time exponent)
%       fits(3) ... PHI    (Fano Factor)
%       fits(4) ... R0     (baseline)
%       fits(5) ... M      (Coh exponent)
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    vals_ = [ ...
        15     0.0001 1000; ...
         0    -5         5; ...
         0.3   0        10; ...
         10    0       100; ... 
         1.25 -5         5];
     
else

    acm   = fits(1).*data(:,1).^fits(5);
    tn    = data(:,2).^fits(2);
    mu    = acm.*tn;
    nu    = sqrt(fits(3).*tn.*(2*fits(4) + acm));
    vals_ = 0.5 + 0.5.*erf(mu./(nu.*sqrt(2)));
end
