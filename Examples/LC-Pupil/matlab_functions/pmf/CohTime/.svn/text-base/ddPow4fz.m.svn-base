function vals_ = ddPow4fz(fits, data, rmc)
% function vals_ = ddPow4fz(fits, data, rmc)
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
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... N      (time exponent)
%       fits(3) ... lambda ("lapse")
%       fits(4) ... bias   (z-score) scaling factor
%
%   rmc ... (optional) array of run-mean choices
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    if nargin < 2
        data = [];
    end

    % get initial values from ddExp3z
    vals_ = ddExp3z([], data);
    vals_(2,:) = [1 0 10];
    vals_(4,:) = [0 0 100];

else

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25;

    acm   = fits(1).*data(:,1).^M;
    tn    = data(:,2).^fits(2);
    mu    = acm.*tn;
    nu    = sqrt(PHI.*tn.*(2*R0 + acm));
    vals_ = 0.5 + (0.5 - fits(3)).* ...
        erf((mu./nu + fits(4).*rmc.*data(:,3))./sqrt(2));
end
