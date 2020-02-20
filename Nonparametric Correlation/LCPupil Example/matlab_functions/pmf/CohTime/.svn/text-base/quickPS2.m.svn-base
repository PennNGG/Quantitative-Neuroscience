function vals_ = quickPS2(fits, data, lapse)
% function vals_ = quickPS2(fits, data, lapse)
% 
% 2 parameter "Probability Summation Over Time" 
%   Quick(ish) (cumulative Weibull),
%   Computed at values in "data":
%       data(1)   ... coh  [0 ... 1]
%       data(2)   ... time (sec)
%
%   Given parameters in "fits":
%       fits(1) ... R (threshold coefficient)
%       fits(2) ... beta (shape)
% 
% Lapse is (possibly) given and used per Abbott's Law:
% P = 0.5 + (0.5 - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    % get guess for alpha, beta from quick2
    vals_        = quick2([], data(:,[1 3]));
    vals_(1,1)   = 1./vals_(1,1);
    vals_(1,2:3) = [1 1000];

else

    if nargin < 3 || isempty(lapse)
        lapse = 0.0001;
    end
    
    % compute the Quick function from the given parameters
%    vals_ = 0.5 + (0.5 - lapse) .* (1 - exp(-(data(:,1)./...
%        (fits(1)*data(:,2).^(-1./fits(2)))).^fits(2)));
    vals_ = 0.5 + (0.5 - lapse) .* (1 - exp(-(data(:,1).* ...
        fits(1)).^fits(2).*data(:,2)));
end
