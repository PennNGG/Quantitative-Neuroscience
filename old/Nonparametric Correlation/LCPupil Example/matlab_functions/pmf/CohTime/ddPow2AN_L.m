function vals_ = ddPow2AN_L(fits, data, lapse)
% function vals_ = ddPow2AN_L(fits, data, lapse)
%
% 2 parameters: A, N
%
% Computes TIME-based DD function with LAPSE and BIAS.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^1.25
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... time (sec)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... N      (time exponent)
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    if nargin < 2
        data = [];
    end

    % get initial values from ddExp3g
    if nargin < 2 || isempty(data)
        vals_ = ddExp3;
    else
        vals_ = ddExp3([], data);
    end

    % remove lapse
    vals_(2,2) = 0.001;
    vals_(3,:) = [];

else

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25; % just cuz

    acm   = fits(1).*data(:,1).^M;
    tn    = data(:,2).^fits(2);
    mu    = acm.*tn;
    nu    = sqrt(PHI.*tn.*(2*R0 + acm));

    if nargin < 3 || isempty(lapse) || lapse == 0
        lapse = 0.001;
    end

    vals_ = 0.5 + (0.5 - lapse).*erf(mu./(nu.*sqrt(2)));
end
