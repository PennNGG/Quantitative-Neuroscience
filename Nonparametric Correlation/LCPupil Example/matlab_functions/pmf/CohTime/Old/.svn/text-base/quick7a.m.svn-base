function vals_ = quick7a(fits, data)
% function vals_ = quick7a(fits, data)
%
% Computes TIME-based Quick (cumulative Weibull)
%   function:
%   
%   (0.5 + bias) + (1 - (0.5 + bias) - lambda) * 
%       (1 - exp(-(COH/alpha_t).^beta))
%
%  Where
%   alpha_t = Asymptote + Scale./exp((TIME-T_offset)./Tau)
%
%  At values in "data":
%       data(1)   ... COH (%)
%       data(2)   ... TIME (msec)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... Asymptote (lower, y)
%       fits(2) ... Scale
%       fits(3) ... T_offset
%       fits(4) ... Tau
%       fits(5) ... Beta   (slope)
%       fits(6) ... bias   (signed offset)
%       fits(7) ... lambda ("lapse")

% return initial values (init, min, max)
if nargin < 1
    
    vals_ = [ ...
       12     1     100;   ...
        1     1     500;   ...
      100     0.1   150;   ...
      300     0.1  1000;   ...        
        1.2   0.2    12;   ...
        0    -0.05    0.05;...
        0     0       0.45];

else

    alpha_t = fits(1) + fits(2)./exp((data(:,2)-fits(3))./fits(4));
    vals_   = (.5 + fits(6).*data(3)) + (1 - (.5 + fits(6).*data(3)) - fits(7)).* ...
        (1-exp(-(data(:,1)./alpha_t).^fits(5)));

end
