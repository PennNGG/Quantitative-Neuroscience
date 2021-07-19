function vals_ = quick5c(fits, data)
% function vals_ = quick5c(fits, data)
%
% Computes TIME-based Quick (cumulative Weibull)
%   function:
%   
%   0.5 + 0.5 * 
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

% return initial values (init, min, max)
if nargin < 1
    
    vals_ = [ ...
       12     1     100;   ...
        1     1     500;   ...
      100     0.1   100;   ...
      300     0.1  1000;   ...        
        1.2   0.2    12];

else

    alpha_t = fits(1) + fits(2)./exp((data(:,2)-fits(3))./fits(4));
    vals_   = .5 + 0.5 * ...
        (1-exp(-(data(:,1)./alpha_t).^fits(5)));

end
