function vals_ = ddExp6RL_LF(fits, data, lapse, chc)
% function vals_ = ddExp6RL_LF(fits, data, lapse, chc)
%
% 6 parameters for a REINFORCEMENT LEARNING model of bias:
%   A, alpha, a DC bias and three terms to control the RL rule
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
%       fits(3) ... DC bias
%       fits(4) ... b1 (RL term 1)
%       fits(5) ... b2 (RL term 2)
%       fits(6) ... b3 (RL term 3)
%
%   lapse ... (optional) lapse rate
%   fc    ... (optional) array of filtered choices
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
    vals_      = ddExp4z([], data);
    vals_(3,:) = [];
    vals_      = cat(1, vals_, [ ...
        0.1  0 1; ...
        0.1 -20 20; ...
        0.1 -20 20]);
else

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25; % just cuz

    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));

    if nargin < 4 || isempty(chc)
        Bs   = fits(3).*ones(size(data,1),1);
    else
        % compute bias
        filt = fits(4).^(0:length(chc)-1)';
        Bs   = fits(5)*filter(filt,1,chc(:,1)) + fits(6)*filter(filt,1,chc(:,2));
        Bs   = fits(3)+[0; Bs(1:end-1)];
    end

    % return bias, bias./dv
    if nargin > 2 && isnan(lapse)

        % flag for returning biases
        vals_ = [Bs mu];
    else

        if nargin < 3 || lapse < 0.001
            lapse = 0.001;
        end

        vals_ = 0.5 + (0.5 - lapse).* ...
            erf((mu+Bs.*data(:,3))./nu./sqrt(2));
    end
end

