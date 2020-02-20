function vals_ = ddExp3(fits, data)
% function vals_ = ddExp3(fits, data)
%
% 3 parameters: A, alpha, lapse
%
% Computes EXPONENTIAL TIME-based DD function.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^M, where M is fixed, below
%   And on time as a decaying exponential
%       A(coh, t) = A_max * exp(-alpha*t)
%
%   at values in "data":
%       data(1) ... coh [0 ... 1]
%       data(2) ... time (sec)
%       data(3) ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... alpha  (time exponent)
%       fits(3) ... lambda ("lapse")
% 
% lapse uses abbott's law
% P = G + (1 - G - L)P*
% where here P* = erf and G (guess) = 0.5

% return initial values (init, min, max)
if nargin < 1 || isempty(fits)
    
    LMIN = 0.0001;
    LMAX = 0.18;
    % data matrix includes pcor (last column)
    % guess lapse from high coherence trials    
    if nargin < 2 || isempty(data)
        vals   = ddExp2_L;
        lapse  = LMIN;
    else
        vals   = ddExp2_L([], data);
        Lmax   = data(:,1) == max(data(:,1));
        lapse  = max([LMIN min([LMAX, 1.0 - sum(data(Lmax,end))./sum(Lmax)])]);
    end

    vals_ = cat(1, vals, [lapse  0.0001 LMAX]);

else
    
    PHI   = 0.3;
    R0    = 10;
    M     = 1.25;
    
    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));
    vals_ = 0.5 + (0.5 - fits(3)).*erf(mu./nu./sqrt(2));    
end
