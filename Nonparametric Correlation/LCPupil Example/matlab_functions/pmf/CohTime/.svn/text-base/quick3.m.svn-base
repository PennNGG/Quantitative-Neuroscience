function vals_ = quick3(fits, data)
% function vals_ = quick3(fits, data)
% 
% 3 parameter Quick (cumulative Weibull),
%   Computed at values in "data":
%       data(1)   ... coh [0 ... 1]
%
%   Given parameters in "fits":
%       fits(1) ... alpha   (threshold)
%       fits(2) ... beta    (shape)
%       fits(3) ... lambda  (lapse)
% 
% Lapse is computed using Abbott's Law:
% P = 0.5 + (0.5 - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    % get guess for alpha, beta from quick2
    vals_ = [quick2([], data); 0 0 0.49];
    
    % Data is coh, % cor, (optional) n
    % guess lapse from high coherence trials    
    if nargin > 1 && ~isempty(data)
        Lmax  = data(:,1) == max(data(:,1));
        if length(unique(data(:,1))) == size(data, 1)
            vals_(3,1) = min([0.49, 1.0 - data(Lmax, 2)]);
        else
            vals_(3,1) = min([0.49, 1.0 - sum(data(Lmax,2))./sum(Lmax)]);
        end
    end
else

    % compute the Quick function from the given parameters
    vals_ = 0.5 + (0.5 - fits(3)) .* (1 - exp(-(data(:,1)./fits(1)).^fits(2)));
end
