function vals_ = ddExp4g(fits, data)
% function vals_ = ddExp4g(fits, data)
%
% 3 parameters: A, alpha, lapse
% plus an additional GUESS parameter, based on Abbot's law
%
% Computes TIME-based DD function with LAPSE and BIAS.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^1.25
%   And on time as a decaying exponential
%       A(coh, t) = A_max * exp(-alpha*t)
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... time (sec)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... alpha  (time exponent)
%       fits(3) ... lambda ("lapse")
%       fits(4) ... bias  
% 
% guess & lapse uses abbott's law
% P = G + (1 - G - L)P*
% here  P* = erf
%       G  = 0.5 +- bias  

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    bias  = [0 -0.49 0.49];
    
    if nargin < 2 || isempty(data)        
        
        vals_ = cat(1, ddExp3, bias);
    else

        Lmin = data(:,1) == min(data(:,1));
        L1 = Lmin & data(:,3) == 1;
        if sum(L1)
            b1 = -0.5 + sum(data(L1,end))./sum(L1);
        else
            b1 = nan;
        end

        L2 = Lmin & data(:,3) == -1;
        if sum(L2)
            b2 = 0.5 - sum(data(L2,end))./sum(L2);
        else
            b2 = nan;
        end
        if ~isnan(b1) || ~isnan(b2)
            bias(1) = nanmean([b1 b2]);
        end
        
        vals_ = cat(1, ddExp3([], data), bias);
    end

else
    
    PHI   = 0.3;
    R0    = 10;
    M     = 1.25;
    
    if fits(2) == 0
        fits(2) = 0.0001;
    end
    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));
    gamma = 0.5 + data(:,3).*fits(4);
    vals_ = gamma + (1 - gamma - fits(3)).*erf(mu./(nu.*sqrt(2)));    
end
