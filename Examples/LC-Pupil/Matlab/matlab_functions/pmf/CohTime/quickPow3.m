function vals_ = quickPow3L(fits, data, lapse)
% function vals_ = quickPow3L(fits, data, lapse)
% 
% 3 parameter Quick (cumulative Weibull) function
%   with time-dependent (power law) threshold
%   and given lapse rate (L),
%   Computed at values in "data":
%       data(1)   ... coh [0 ... 1]
%
%   Given parameters in "fits":
%       fits(1) ... alpha (threshold)
%       fits(2) ... alpha pow
%       fits(3) ... beta (shape)
% 
% Lapse is computed using Abbott's Law:
% P = 0.5 + (0.5 - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    % get guess for alpha, beta from quick2
    q2    = quick2([],data(:,[1 3]));
    vals_ = [q2(1,:); -0.5 -1.5 1.5; q2(2,:)];

else

    % compute the Quick function from the given parameters
    vals_ = 0.5 + (0.5 - lapse) .* (1 - exp(-(data(:,1)./...
        (fits(1).*data(:,2).^fits(2))).^fits(3)));
end
