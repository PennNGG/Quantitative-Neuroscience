function vals_ = ddExp3f5(fits, data, chc)
% function vals_ = ddExp3f5(fits, data, chc)
%
% 3 parameters: A, alpha, lapse
%   plus 4 "filter" parameters (a1,a2,t1,t2)
%
% Computes EXPONENTIAL TIME-based DD function.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^M, where M is fixed, below
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
%       fits(4) ... a1
%       fits(5) ... a2
%       fits(6) ... t1
%       fits(7) ... t2
%       fits(8) ... baseline
% 
% lapse uses abbott's law
% P = G + (1 - G - L)P*
% where here P* = erf and G (guess) = 0.5

persistent filt
persistent is
FILT_SIZE = 300;

% return initial values (init, min, max)
if nargin < 1 || isempty(fits)
    
    LMAX = 0.18;
    % data matrix includes pcor (last column)
    % guess lapse from high coherence trials    
    if nargin < 2 || isempty(data)
        lapse = 0;
    else
        Lmax   = data(:,1) == max(data(:,1));
        lapse  = min([LMAX, 1.0 - sum(data(Lmax,end))./sum(Lmax)]);
        Aguess = (sum(data(:,end))./size(data,1)-0.45)*40;
    end

    vals_ = [ ...
        Aguess   0.0001  100;  ...
         1     -50        50;  ...
     lapse       0.0001 LMAX;  ...
        .1     -10        10;  ...
        .1     -10        10;  ...
        1        0.1      10;  ...
        30      10       500;  ...
        0     -100       100];

    filt = nans(FILT_SIZE,1);
    is   = (1:FILT_SIZE)';
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

    % fiter choices
    e1   = exp(-is./fits(6));
    e2   = exp(-is./fits(7));
    filt = fits(8) + fits(4)./sum(e1).*e1 + fits(5)./sum(e2).*e2;
    chc(2:end)  = filter(filt, 1, chc(1:end-1));

    vals_ = 0.5 + (0.5 - fits(3)).* ...
        erf((mu./nu + chc.*data(:,3))./sqrt(2));
end
