function vals_ = quickPow4tb(fits, data, lapse)
% function vals_ = quickPow4tb(fits, data, lapse)
% 
% 4 parameter Quick (cumulative Weibull),
%   Computed at values in "data":
%       data(1) ... coh [0 ... 1]
%       data(2) ... time (sec)
%       data(3) ... dot dir (-1/1)
%
%   Given parameters in "fits":
%       fits(1) ... alpha   (threshold)
%       fits(2) ... alpha pow
%       fits(3) ... beta    (shape)
%       fits(4) ... bias
% 
% Lapse is computed using Abbott's Law:
% P = 0.5 + (0.5 - L)P*

% Copyright 2007 by Joshua I. Gold
%   University of Pennsylvania

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    % get guess for alpha, beta from quick2
    q2    = quick2([],data(:,[1 3]));
    vals_ = [q2(1,:); -0.5 -4 4; q2(2,:); 0 -.5 .5];
    
else

    if nargin < 3 || isempty(lapse)
        lapse = 0;
    end
    
    % compute the Quick function from the given parameters
    cohs = abs(data(:,1).*data(:,3)+fits(4));
    vals_ = 0.5 + (0.5 - lapse) .* (1 - exp(-(cohs./...
        (fits(1).*data(:,2).^fits(2))).^fits(3)));
end
