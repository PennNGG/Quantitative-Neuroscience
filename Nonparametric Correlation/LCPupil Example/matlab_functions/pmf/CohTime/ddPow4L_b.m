function vals_ = ddPow4L_b(fits, data, lapse)
% function vals_ = ddPow4L_b(fits, data, lapse)
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
%       data(3)   ... array of filtered choices
%       data(4)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... M      (coh exponent)
%       fits(3) ... N      (time exponent)
%       fits(4) ... bias   (z-score) scaling factor
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    % set initial values
    vals_ = [ ...
        15 0.0001 5000; ...
        0 -25         25; ...
        0 -25         25; ...
        0   0      100];
else

    PHI   = 0.3;
    R0    = 10;

    acm   = fits(1).*data(:,1).^fits(2);
    tn    = data(:,2).^0.4;%fits(3);
    mu    = acm.*tn;
    nu    = sqrt(PHI.*tn.*(2*R0 + acm));
    vals_ = 0.5 + (0.5 - lapse).* ...
        erf((mu./nu + fits(4).*data(:,3).*data(:,4))./sqrt(2));
end
