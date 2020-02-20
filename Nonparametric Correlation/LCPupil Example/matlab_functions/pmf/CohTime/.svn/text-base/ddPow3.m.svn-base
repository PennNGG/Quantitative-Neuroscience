function vals_ = ddPow3(fits, data)
% function vals_ = ddPow3(fits, data)
%
% 3 parameters: A, alpha, lapse
% plus an additional GUESS parameter that scales
%   the given run-mean choice array
%
% Computes TIME-based DD function with LAPSE and BIAS.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^1.25
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
%       fits(3) ... lambda ("lapse")
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

        % data matrix includes pcor (last column)
    % guess lapse from high coherence trials    
    if nargin < 2 || isempty(data)
        lapse = 0;
    else
        Lmax = data(:,1) == max(data(:,1)) & data(:,2) >= median(data(:,2));
        lapse = min([0.49, 1.0 - sum(data(Lmax,end))./sum(Lmax)]);
    end

    vals_ = [ ...
        15  0.0001 1000; ...
         0 -5         5; ...
     lapse  0         0.49];

else

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25;

    acm   = fits(1).*data(:,1).^M;
    tn    = data(:,2).^fits(2);
    mu    = acm.*tn;
    nu    = sqrt(PHI.*tn.*(2*R0 + acm));
    vals_ = 0.5 + (0.5 - fits(3)).* ...
        erf(mu./(nu.*sqrt(2)));
end
