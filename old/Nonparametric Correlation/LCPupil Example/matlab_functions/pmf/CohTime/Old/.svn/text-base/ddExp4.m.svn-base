function vals_ = ddExp3g(fits, data)
% function vals_ = ddExp3g(fits, data)
%
% 3 parameters: A, alpha, lapse
% plus a Guess (g) term, based on Abbot's law
%
% Computes TIME-based DD function.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^M
%   And on time as a decaying exponential
%       A(coh, t) = A_max * exp(-alpha*t)
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... time (sec)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... M      (coh exponent)
%       fits(3) ... alpha  (time exponent)
%       fits(4) ... lambda ("lapse")
% 
% lapse uses abbott's law
% for dealing with performance that does not asymptote at 1.
% Without a lapse rate, 
%   P = 0.5[1+erf(blahblah)],
%       which spans [0.5, 1.0]
% We want to span [0.5, lambda], thus
%   P* = (P - 0.5)(1 - lambda) + 0.5

% return initial values (init, min, max)
if nargin < 1
    
    vals_ = [ ...
        20    0.1   150;   ...
        1.25  0.001  10;   ...
        1    -15     15;    ...
        0     0      0.4];

else
    
    PHI   = 0.3;
    R0    = 10;
    
    acm   = fits(1).*data(:,1).^fits(2);
    if fits(3) == 0
        fits(3) = 0.00001;
    end
    mu = acm./fits(3).*(1 - exp(-fits(3).*data(:,2)));
    vals_ = 0.5.*(1+(1-fits(4)).*erf(mu./sqrt(2.*PHI.*data(:,2).*(2*R0+acm))));
end
