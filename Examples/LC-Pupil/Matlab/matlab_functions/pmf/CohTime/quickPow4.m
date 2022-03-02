function vals_ = quickPow4(fits, data)
% function vals_ = quickPow4(fits, data)
% 
% 3 parameter Quick (cumulative Weibull),
%   Computed at values in "data":
%       data(1)   ... coh [0 ... 1]
%
%   Given parameters in "fits":
%       fits(1) ... alpha   (threshold)
%       fits(2) ... alpha pow
%       fits(3) ... beta    (shape)
%       fits(4) ... lambda  (lapse)
% 
% Lapse is computed using Abbott's Law:
% P = 0.5 + (0.5 - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    % get guess for alpha, beta from quick2
    q2    = quick2([],data(:,[1 3]));
    vals_ = [q2(1,:); -0.5 -1.5 1.5; q2(2,:); 0 0 0.18];
    
    % Data is coh, % cor, (optional) n
    % guess lapse from high coherence trials    
    if nargin > 1 && ~isempty(data)
        Lmax  = data(:,1) == max(data(:,1));
        if length(unique(data(:,1))) == size(data, 1)
            vals_(4,1) = min([vals_(4,3), 1.0 - data(Lmax, 3)]);
        else
            vals_(4,1) = min([vals_(4,3), 1.0 - sum(data(Lmax, 3))./sum(Lmax)]);
        end
    end
else

    % compute the Quick function from the given parameters
    vals_ = 0.5 + (0.5 - fits(4)) .* (1 - exp(-(data(:,1)./...
        (fits(1).*data(:,2).^fits(2))).^fits(3)));
end
