function vals_ = quick3K(fits, data, k)
% function vals_ = quick3K(fits, data, k)
% 
% 3 parameter Quick (cumulative Weibull)
%   using given:
%       k ... base of the exponential term (2.0851 for d'=1)
%   Computed at values in "data":
%       data(1) ... coh [0 ... 1]
%
% using params:
%       fits(1) ... alpha (threshold)
%       fits(2) ... beta  (shape)
%       fits(3) ... lapse
% 

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    vals_ = cat(1, quick2([], data), [0.001 0 0.2]);
    
else

    % compute the Quick function from the given parameters
    vals_ = 0.5 + (0.5 - fits(3)) .* (1 - k.^(-(data(:,1)./fits(1)).^fits(2)));
end
