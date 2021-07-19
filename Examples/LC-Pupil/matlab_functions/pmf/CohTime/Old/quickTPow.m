function vals_ = quickPow(fits, data)
% function vals_ = quickPow(fits, data)
%
% Computes TIME-based quick function
%   (0.5 + guess) + (1 - (0.5 + guess) - lapse) * 
%               (1 - exp(-(C/alpha_t).^beta_t))
%
%   where
%       alpha_t is defined by inline function alpha(alpha_params)
%       beta_t  is defined by inline function beta(beta_params)
%
%       data(1)   ... coh (%)
%       data(2)   ... time (s)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1)   ... alpha coefficient
%       fits(2)   ... alpha exponent
%       fits(3)   ... beta coefficient
%       fits(4)   ... beta exponent
%
% see also quickTs_fit and quickTs_err

% return initial values (init, min, max)
if nargin < 1
    
    vals_ = [ ...

        expr  = '1./(A(1).*T.^A(2))';
        A0_   = [ ...
            0.05 0.0001 10; ...
            0.8  -5      5];

if aT
    al = feval(alpha, data(:, 2), as);
else
    al = feval(alpha, as);
end

if bT
    be = feval(beta, data(:, 2), bs);
else
    be = feval(beta, bs);
end

gamma = 0.5 + data(:,3).*guess;
p_    = gamma + (1 - gamma - lapse) .* (1 - exp(-(data(:,1)./al).^be));
