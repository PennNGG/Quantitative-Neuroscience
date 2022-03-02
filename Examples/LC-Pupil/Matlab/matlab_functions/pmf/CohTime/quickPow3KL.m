function vals_ = quickPow3KL(fits, data, k, lapse)
% function vals_ = quickPow3KL(fits, data, k, lapse)
% 
% 3 parameter 'Quick' (cumulative Weibull) function
%   with time-dependent (power law) threshold
%   and given:
%       k ... base of the exponential term
%       L ... lapse rate
%   Computed at values in "data":
%       data(1) ... coh  [0 ... 1]
%       data(2) ... time (sec)
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
    vals_ = [q2(1,:); -0.5 -2.2 2.2; q2(2,:)];

else

    % compute the Quick function from the given parameters
    vals_ = 0.5 + (0.5 - lapse) .* (1 - k.^(-(data(:,1)./...
        (fits(1).*data(:,2).^fits(2))).^fits(3)));
end
