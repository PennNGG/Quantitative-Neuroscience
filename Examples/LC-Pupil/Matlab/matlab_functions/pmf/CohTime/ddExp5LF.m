function vals_ = ddExp5LF(fits, data, lapse)
% function vals_ = ddExp5LF(fits, data, lapse)
%
% 5 parameters: A, M, alpha, and two for bias
%   (one DC and one that scales the filtered choice array)
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
%       data(3) ... array of filtered choices
%       data(4) ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... M      (coh exponent)
%       fits(3) ... alpha  (time decay)
%       fits(4) ... filtered-choice bias scaling factor
%       fits(5) ... DC bias
%
%   lapse ... (optional) lapse rate
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
    vals_     = ddExp5fzz([], data);
    vals_(3,:) = vals_(2,:);
    vals_(2,:) = [1 -10 10];

else

    PHI   = 0.3;
    R0    = 10;
    
    acm   = fits(1).*data(:,1).^fits(2);
    acm(data(:,1)==0) = 0;
    mu    = acm./fits(3).*(1 - exp(-fits(3).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));
    bi    = (fits(5)+fits(4).*data(:,3)).*data(:,4);
    
    vals_ = 0.5 + (0.5 - lapse).* erf((mu + bi)./nu./sqrt(2));
        
end