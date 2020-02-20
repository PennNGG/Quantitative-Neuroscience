function vals_ = quick4K(fits, data, k)
% function vals_ = quick4K(fits, data, k)
% 
% 4 parameter Quick (cumulative Weibull)
%   using given:
%       k ... base of the exponential term (2.0851 for d'=1)
%       L ... lapse rate
%   Computed at values in "data":
%       data(1) ... coh [0 ... 1]
%
% using params:
%       fits(1) ... alpha (threshold)
%       fits(2) ... beta  (shape)
%       fits(3) ... lower asymptote
%       fits(4) ... upper asymptote
% 

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    vals_ = [quick2([], data); ...
        0.5 0.4 0.6; 0.01 0.0 0.2];
    vals_(2,2:3) = [.01 20];
else

    % compute the Quick function from the given parameters
    vals_ = fits(3) + (1 - fits(3) - fits(4)) .* (1 - k.^(-(data(:,1)./fits(1)).^fits(2)));
end
