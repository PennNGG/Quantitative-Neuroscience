function vals_ = ddExp4(fits, data)
% function vals_ = ddExp3(fits, data)
%
% 4 parameters: A, M, alpha, lapse
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
%       fits(2) ... M      (coh exponent)
%       fits(3) ... alpha  (time exponent)
%       fits(4) ... lambda ("lapse")
% 
% lapse uses abbott's law
% P = G + (1 - G - L)P*
% where here P* = erf and G (guess) = 0.5

% return initial values (init, min, max)
if nargin < 1 || isempty(fits)
    
    LMAX = 0.18;
    % data matrix includes pcor (last column)
    % guess lapse from high coherence trials    
    if nargin < 2 || isempty(data)
        lapse  = 0;
        Aguess = 20;
    else
        Lmax   = data(:,1) == max(data(:,1));
        lapse  = min([LMAX, 1.0 - sum(data(Lmax,end))./sum(Lmax)]);
        Aguess = (sum(data(:,end))./size(data,1)-0.45)*40;
    end

    vals_ = [ ...
        Aguess    0.001   100; ...
         1      -3         10; ...
         1     -50         50; ...
     lapse        0.0001  LMAX];

else
    
    PHI   = 0.3;
    R0    = 10;
    
    if fits(3) == 0
        fits(3) = 0.0001;
    end
    acm   = fits(1).*data(:,1).^fits(2);
    mu    = acm./fits(3).*(1 - exp(-fits(3).*data(:,2)));
    nu    = sqrt((2*R0 + acm).*PHI.*data(:,2));
    vals_ = 0.5 + (0.5 - fits(4)).*erf(mu./(nu.*sqrt(2)));    
end
