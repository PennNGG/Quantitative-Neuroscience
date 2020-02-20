function vals_ = ddExp3lbn(fits, data, chc)
% function vals_ = ddExp3lbn(fits, data, chc)
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
%       data(4)   ... (optional) session
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... alpha  (time exponent)
%       fits(3) ... lapse
%       fits(4) ... local bias (tau = 1)
%       fits(4+(1...n_ses)) ... biases
% 
% guess & lapse uses abbott's law
% P = G + (1 - G - L)P*
% here  P* = erf
%       G  = 0.5 +- bias  
%
%   chc is DA array, rows are ALL trials
%       (including, e.g., long-view-times,
%        that are excluded otherwise); columns are:
%        chc(1) ... -1=left;1=right;0=nc
%        chc(2) ... selector; whether trial is used in fit

% return initial values (init, min, max)
if isempty(fits)
    
    % data matrix includes pcor (last column)
    % guess lapse from high coherence trials    
    Lmax = data(:,1) == max(data(:,1));
    lapse = 1.0 - sum(data(Lmax,end))./sum(Lmax);
        
    vals_ = [ ...
        15   0.01 inf; ...
         0 -10     10; ...
     lapse   0      0.45; ...
         0.2  -5      5];
 
    % check for "session" column, compute n sessions
    if size(data,2) == 4
        nses = 1;
    else
        nses = max(data(:,4));
    end
    
    % guess bias separately for each session
    % 	using low coherence trials
    for ss = 1:nses
        
        if size(data,2) == 4
            Lses = true(size(data,1));
        else
            Lses = data(:,4) == ss;
        end
        
        Lmin = Lses & data(:,1) == min(data(:,1));
        L1 = Lmin & data(:,3) == 1;
        if sum(L1)
            b1 = sum(data(L1,5))./sum(L1) - 0.5;
        else
            b1 = nan;
        end

        L2 = Lmin & data(:,3) == -1;
        if sum(L2)
            b2 = 0.5 - sum(data(L2,5))./sum(L2);
        else
            b2 = nan;
        end
        if isnan(b1) && isnan(b2)
            vals_ = cat(1, vals_, [0 -0.45 0.45]);
        else
            vals_ = cat(1, vals_, [nanmean([b1 b2]) -0.45 0.45]);
        end
    end
        
else
    if fits(4) == 0 || nargin < 3
        lb = 0;
    else
        lb = filter([0 fits(4).*exp(-(0:3))], 1, chc(:,1));
        lb = lb(chc(:,2)==1);
    end
    if size(data, 2) >= 4
        gamma = 0.5 + lb + data(:,3).*fits(data(:,4)+4);
    else
        gamma = 0.5 + lb;
    end
    gamma(gamma>0.99) = 0.99;
    gamma(gamma<0.01) = 0.01;

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25;
    
    acm   = fits(1).*data(:,1).^M;
    if fits(2) == 0
        fits(2) = 0.0001;
    end
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    vals_ = gamma + (1 - gamma - fits(3)) .* ...
        erf(mu./sqrt(2.*PHI.*data(:,2).*(2*R0+acm)));
end
