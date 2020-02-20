function vals_ = ddExp3nz(fits, data, sess)
% function vals_ = ddExp3nz(fits, data, sess)
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
%       fits(3) ... lambda ("lapse")
%       fits(3+(1...n_ses)) ... biases
% 
%   sess ... (optional) array of session indices
%           should be ordered 1...n
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

    if nargin < 3 || isempty(data) || isempty(sess)
        return
    end
    
    % get initial values from ddExp3z, per session
    vals_ = vals_(1:end-1,:);
    for ss = 1:max(sess)
        vs             = ddExp3z([], data(sess == ss, :));
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
    vals_ = 0.5 + (0.5 - fits(3)).* ...
        erf((mu./nu + fits(sess+3).*data(:,3))./sqrt(2));
end
