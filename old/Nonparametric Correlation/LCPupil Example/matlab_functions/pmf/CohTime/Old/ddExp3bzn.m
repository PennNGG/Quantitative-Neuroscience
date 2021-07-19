function vals_ = ddExp3bzn(fits, data, sess)
% function vals_ = ddExp3bzn(fits, data, sess)
%
% 3 parameters: A, alpha, lapse
% bn for additional BIAS parameters, 1 per session
% z for z-score (i.e., criterion) change
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
%       fits(3) ... lapse  
%       fits(3+(1...n_ses)) ... biases
% 
%   sess ... (optional) array of session indices
%           should be ordered 1...n
%  
% guess & lapse uses abbott's law
% P = G + (1 - G - L)P*
% here  P* = erf
%       G  = 0.5 +- bias  

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)
    
    % data matrix includes pcor (last column)
    % guess lapse from high coherence trials    
    if nargin < 2 || isempty(data)
        lapse = 0;
    else
        Lmax = data(:,1) == max(data(:,1));
        lapse = 1.0 - sum(data(Lmax,end))./sum(Lmax);
    end
    
    vals_ = [ ...
        15   0.01 inf; ...
         0 -10    10; ...
     lapse   0     0.45];
 
 
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
    
        PHI   = 0.3;
    R0    = 10;
    M     = 1.25;
    
    if fits(2) == 0
        fits(2) = 0.0001;
    end
    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(1 - exp(-fits(2).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));
    vals_ = 0.5 + (0.5 - fits(3)).* ...
        erf((mu./nu + fits(4).*data(:,3))./sqrt(2));

    
    if size(data, 2) >= 4
        gamma = 0.5 + data(:,3).*fits(data(:,4)+3);
    else
        gamma = 0.5 + data(:,3).*fits(4);
    end

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




if nargin < 2 || isempty(fits)
    
    % data matrix includes pcor (last column)
    % guess lapse from high coherence trials
    if nargin < 2 || isempty(data)
        lapse = 0;
    else
        Lmax = data(:,1) == max(data(:,1));
        lapse = 1.0 - sum(data(Lmax,end))./sum(Lmax);
    end
    
    vals_ = [ ...
        15   0.01 inf; ...
        0 -10    10; ...
        lapse   0     0.45];

    bias = [0 -0.49 0.49];

    % no data given, assume one session and set bias to 0
    if nargin < 2 || isempty(data)
        vals_ = cat(1, vals_, bias);
        return
    end
    
    % check for "session" column, compute n sessions
    if nargin < 3 || isempty(sess)
        nses = 1;
        Lses = true(size(data,1),1);
    else
        nses = max(sess);
        for nn = 1:nses
            Lses(:,nn) = sess = ss;
        end
    end
    
    % guess bias separately for each session
    % 	using low coherence trials
    for ss = 1:nses

        Lmin = Lses(:,ss) & data(:,1) == min(data(:,1));
        L1 = Lmin & data(:,3) == 1;
        if sum(L1)
            b1 = sum(data(L1,end))./sum(L1) - 0.5;
        else
            b1 = nan;
        end

        L2 = Lmin & data(:,3) == -1;
        if sum(L2)
            b2 = 0.5 - sum(data(L2,end))./sum(L2);
        else
            b2 = nan;
        end
        if isnan(b1) && isnan(b2)
            vals_ = cat(1, vals_, bias);
        else
            vals_ = cat(1, vals_, [nanmean([b1 b2]) bias(2:3)]);
        end
    end
    
else
    
    if size(data, 2) >= 4
        gamma = 0.5 + data(:,3).*fits(data(:,4)+3);
    else
        gamma = 0.5 + data(:,3).*fits(4);
    end

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