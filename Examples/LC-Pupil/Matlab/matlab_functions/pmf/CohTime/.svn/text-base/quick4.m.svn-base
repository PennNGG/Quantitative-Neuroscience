function vals_ = quick4(fits, data)
% function vals_ = quick4(fits, data)
% 
% 4 parameter Quick (cumulative Weibull),
%   Computed at values in "data":
%       data(1)   ... coh [0 ... 1]
%
%   Given parameters in "fits":
%       fits(1) ... alpha   (threshold)
%       fits(2) ... beta    (shape)
%       fits(3) ... lambda  (lapse)
%       fits(4) ... gamma   (guess)
% 
% Guess and lapse is computed using Abbott's Law:
% P = G + (1 - G - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    % get guess for alpha, beta from quick2
    vals_ = [quick3([], data); 0 0 .5];
    
    % Data is coh, % cor, (optional) n
    % guess from low coherence trials    
    if nargin > 1 && ~isempty(data)
        Lmin = data(:,1) == min(data(:,1));
        if length(unique(data(:,1))) == size(data, 1)
            vals_(4,1) = min([0.5, data(Lmin, 2)]);
        else
            vals_(4,1) = min([0.5, sum(data(Lmin,2))./sum(Lmin)]);
        end
    end
else

    % compute the Quick function from the given parameters
    vals_ = fits(4) + (1 - fits(4) - fits(3)) .* ...
        (1 - exp(-(data(:,1)./fits(1)).^fits(2)));
end
