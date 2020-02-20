function vals_ = ddExp4fz(fits, data, fc)
% function vals_ = ddExp4fz(fits, data, fc)
%
% 4 parameters: A, alpha, lapse, and a bias
%   parameter that scales the filtered choice array
%
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
%       data(1) ... coh [0 ... 1]
%       data(2) ... time (sec)
%       data(3) ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... alpha  (time exponent)
%       fits(3) ... lambda ("lapse")
%       fits(4) ... bias   (z-score) scaling factor
%
%   fc ... (optional) array of filtered choices
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
    vals_ = ddExp3([], data);
    vals_(4,:) = [3 -10 10];

else

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25; % just cuz

    if fits(2) == 0
        fits(2) = 0.001;
    end
    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));

    if nargin < 3 || isempty(fc)
        vals_ = 0.5 + (0.5 - fits(3)).*erf(mu./nu./sqrt(2));
    else
        vals_ = 0.5 + (0.5 - fits(3)).* ...
            erf((mu+fits(4).*fc.*data(:,3))./nu./sqrt(2));
    end
end
