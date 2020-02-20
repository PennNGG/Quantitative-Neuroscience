function vals_ = quickPow4ta(fits, data, lapse)
% function vals_ = quickPow4ta(fits, data, lapse)
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
    q2 = quick2([],data(data(:,1)>0,[1 4]));
    
    % guess guess
    L0 = data(:,1) == min(data(:,1));
    if sum(L0) > 5
        guess = sum(data(L0,end))./sum(L0) - 0.5;
    else
        guess = 0;
    end
    vals_ = [q2(1,:); -0.5 -1.5 1.5; q2(2,:); guess -.5 .5];
    
else

    if nargin < 3 || isempty(lapse)
        lapse = 0;
    end
    
    % compute the Quick function from the given parameters
    gd    = fits(4).*data(:,3);
    vals_ = 0.5 + gd + (0.5 - lapse - gd) .* (1 - exp(-(data(:,1)./...
        (fits(1).*data(:,2).^fits(2))).^fits(3)));
end
