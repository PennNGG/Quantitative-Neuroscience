function vals_ = quick5a(fits, data)
% function vals_ = quick5a(fits, data)
%
% Computes TIME-based Quick (cumulative Weibull)
%   function:
%   
%   0.5 + (0.5 - lambda) * 
%       (1 - exp(-(COH/alpha_t).^beta))
%
%  Where
%   alpha_t = 1./(A1.*TIME.^A2)
%
%  At values in "data":
%       data(1)   ... COH (%)
%       data(2)   ... TIME (sec)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A1R    (alpha scale, dir = -1)
%       fits(2) ... A1L    (alpha scale, dir = 1)
%       fits(3) ... A2     (allpha exponent)
%       fits(4) ... Beta   (slope)
%       fits(5) ... lambda ("lapse")

% return initial values (init, min, max)
if nargin < 1
    
    vals_ = [ ...
        0.05  0.00001  5;   ...
        0.05  0.00001  5;   ...
        0.8  -5       5;   ...
        1.4   0       15;   ...
        0     0       0.45];

else
    
    alpha = 1./(fits((data(:,3)+3)/2).*data(:,2).^fits(3));
    vals_ = 0.5 + (0.5 - fits(5)) .* ...
        (1 - exp(-(data(:,1)./alpha).^fits(4)));
end
