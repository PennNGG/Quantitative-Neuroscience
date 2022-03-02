function vals_ = quick2L(fits, data, lapse)
% function vals_ = quick2L(fits, data, lapse)
% 
% 2 parameter Quick (cumulative Weibull): 
%   alpha (threshold)
%   beta  (shape)
% with a given lapse (L)
%
% Computes a standard 2AFC Quick fit
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%
%   given parameters in "fits":
%       fits(1) ... alpha   (threshold)
%       fits(2) ... beta    (shape)
% 

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    vals_ = quick2([], data);
    
else

    % compute the Quick function from the given parameters
    vals_ = 0.5 + (0.5 - lapse) .* (1 - exp(-(data(:,1)./fits(1)).^fits(2)));
end
