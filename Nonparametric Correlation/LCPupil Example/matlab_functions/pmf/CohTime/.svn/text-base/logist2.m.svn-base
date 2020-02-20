function vals_ = logist2(fits, data, lapse)
% function vals_ = logist2(fits, data, lapse)
% 
% Logistic fit as a function of Coherence AND Time.
%
%   Computed at values in "data":
%       data(1)   ... signed coh [-1 ... 1]
%       data(2)   ... time (sec)
%
%   Given parameters in "fits":
%       fits(1)   ... choice bias
%       fits(2)   ... coh*time interaction
%
% Lapse is computed using Abbott's Law:
% P = 0.5 + (1 - 0.5 - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    vals_ = [ ...
        0 -50 50; ...
        0 -50 50];        
else

    if nargin < 3 || isempty(lapse)
        lapse = 0;
    end
    
    vals_ = lapse + (1 - 2*lapse) .* 1./(1+1./exp(fits(1) + ...
        fits(2).*data(:,1).*data(:,2)));
end
