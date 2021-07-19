function vals_ = ddExp3ng(fits, data, sess)
% function vals_ = ddExp3ng(fits, data, sess)
%
% 3 parameters: A, alpha, lapse
% plus an additional n GUESS parameters, based on 
%   a changing criterion (from z-score)
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
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... time (sec)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... alpha  (time exponent)
%       fits(3) ... lapse  
%       fits(3+(1...n_ses)) ... biases
% 
%   sess ... (optional) array of session indices
%           should be ordered 1...n
%
% guess & lapse uses abbott's law
% P = G + (1 - G - L)P*
% here  P* = erf
%       G  = 0.5 +- bias  

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    if nargin < 2
        data = [];
    end
    
    % get initial values from ddExp3z
    vals_ = ddExp3g([], data);
    
    if nargin < 3 || isempty(data) || isempty(sess)
        return
    end
    
    % get initial values from ddExp3z, per session
    vals_ = vals_(1:end-1,:);
    for ss = 1:max(sess)
        vs             = ddExp3g([], data(sess == ss, :));
        vals_(end+1,:) = vs(end, :);
    end
    
else
    
    PHI   = 0.3;
    R0    = 10;
    M     = 1.25;

    if fits(2) == 0
        fits(2) = 0.0001;
    end
    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));
    gamma = 0.5 + data(:,3).*fits(sess+3);
    vals_ = gamma + (1 - gamma - fits(3)).*erf(mu./(nu.*sqrt(2)));
end
