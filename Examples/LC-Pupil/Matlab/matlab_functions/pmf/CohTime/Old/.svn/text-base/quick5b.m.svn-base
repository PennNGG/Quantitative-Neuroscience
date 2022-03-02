function vals_ = quick5b(fits, data)
% function vals_ = quick5b(fits, data)
%
% Computes TIME-based Quick (cumulative Weibull)
%   function:
%   
%   (0.5 + bias) + (1 - (0.5 + bias) - lambda) * 
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
%       fits(1) ... A1     (alpha scale)
%       fits(2) ... A2     (alpha exponent)
%       fits(3) ... Beta   (slope)
%       fits(4) ... bias   (signed offset)
%       fits(5) ... lambda ("lapse")

% return initial values (init, min, max)
if nargin < 1
    
    vals_ = [ ...
        0.05  0.00001  5;  ...
        0.8  -5        5;  ...
        1.4   0       12;  ...
        0  -0.45       0.45;  ...
        0     0        0.45];

else
    
    vals_ = 0.5 + fits(4).*data(:,3) + ...
        (0.5 - fits(4).*data(:,3) - fits(5)) .* ...
        (1 - exp(-(data(:,1).* ...
        (fits(1).*data(:,2).^fits(2))).^fits(3)));
end
