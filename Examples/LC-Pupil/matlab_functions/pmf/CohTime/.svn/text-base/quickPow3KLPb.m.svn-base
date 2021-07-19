function vals_ = quickPow3KLPb(fits, data, k, l, p)
% function vals_ = quickPow3KLPb(fits, data, k, l, p)
% 
% 3 parameter 'Quick' (cumulative Weibull) function
%   with time-dependent (power law) threshold
%   and given:
%       k ... base of the exponential term
%       l ... lapse
%       p ... alpha pow
%
%   Computed at values in "data":
%       data(1) ... coh [0 ... 1]
%       data(2) ... time (sec)
%       data(3) ... dot dir (-1/1)
%
%   Given parameters in "fits":
%       fits(1) ... alpha   (threshold)
%       fits(2) ... beta    (shape)
%       fits(3) ... bias
% 
% Lapse is computed using Abbott's Law:
% P = 0.5 + (0.5 - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    % get guess for alpha, beta from quick2
    vals_ = quick2([],data(:,[1 3]));

    % guess guess
    L0 = data(:,1) == min(data(:,1));
    if sum(L0) > 5
        guess = sum(data(L0,end))./sum(L0) - 0.5;
    else
        guess = 0;
    end
    vals_ = [vals_; guess -.4 .4];

else

    % compute the Quick function from the given parameters
    gd    = fits(3).*data(:,3);
    vals_ = 0.5 + gd + (0.5 - l - gd) .* (1 - k.^(-(data(:,1)./...
        (fits(1).*data(:,2).^p)).^fits(2)));
end
