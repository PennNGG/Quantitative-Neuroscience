function vals_ = ddExp4rmb(fits, data, chc)
% function vals_ = ddExp4rmb(fits, data, chc)
%
% rmb = Run-Mean Bias
% Computes TIME-based DD function with LAPSE and BIAS.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^1.25
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
%       fits(2) ... alpha  (time exponent)
%       fits(3) ... lapse  
%       fits(4) ... chc bias
% 
% guess & lapse uses abbott's law
% P = G + (1 - G - L)P*
% here  P* = erf
%       G  = 0.5 +- bias  

% return initial values (init, min, max)
if isempty(fits)
    
    % data matrix includes pcor (last column)
    % guess lapse from high coherence trials    
    Lmax = data(:,1) == max(data(:,1));
    lapse = min([0.49, 1.0 - sum(data(Lmax,end))./sum(Lmax)]);

    vals_ = [ ...
        15   0.01   inf; ...
         0 -10       10; ...
     lapse   0.0001   0.49; ...
         1 -10       10];
     
else

    if nargin < 3
        if size(data, 2) < 3
            gamma = 0.5
        else
            gamma = 0.5 + fits(4).*data(:,3);
        end
    else
        gamma = 0.5 + fits(4).*chc(:,1).*data(:,3);
    end
    gamma(gamma<0.01) = 0.01;
    gamma(gamma>0.99) = 0.99;

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25;
    
    if fits(2) == 0
        fits(2) = 0.0001;
    end
    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));
    vals_ = gamma + (1 - gamma - fits(3)).*erf(mu./(nu.*sqrt(2)));
end
