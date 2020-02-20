function vals_ = quick2KL(fits, data, k, lapse)
% function vals_ = quick2KL(fits, data, k, lapse)
% 
% 2 parameter Quick (cumulative Weibull)
%   using given:
%       k ... base of the exponential term (2.0851 for d'=1)
%       L ... lapse rate
%   Computed at values in "data":
%       data(1) ... coh [0 ... 1]
%
% using params:
%       fits(1) ... alpha (threshold)
%       fits(2) ... beta  (shape)
% 

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    vals_ = quick2([], data);
    
else

    if nargin < 4 || isempty(lapse)
        lapse = 0.01;
    end
    
    % compute the Quick function from the given parameters
    vals_ = 0.5 + (0.5 - lapse) .* (1 - k.^(-(data(:,1)./fits(1)).^fits(2)));
end
