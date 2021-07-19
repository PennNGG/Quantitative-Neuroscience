function vals_ = ddOU2(fits, data, lapse)
% function vals_ = ddOU2(fits, data, lapse)
%
% 2 parameters: A, leak
%
% Computes TIME-based DD function with LEAK.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^M, where M is fixed, below
%
%   at values in "data":
%       data(1) ... coh [0 ... 1]
%       data(2) ... time (sec)
%       data(3) ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... leak   (OU Leak)
% 
% lapse uses abbott's law
% P = G + (1 - G - L)P*
% where here P* = erf and G (guess) = 0.5

% return initial values (init, min, max)
if nargin < 1 || isempty(fits)
    
    % data matrix includes pcor (last column)
    % guess lapse from high coherence trials    
    if nargin < 2 || isempty(data) || any(data(:,end)>1)
        AG = 20;
    else
        AG = (sum(data(:,end))./size(data,1)-0.45)*40;
    end

    vals_ = [ ...
        AG      0.0001 100; ...
        -1    -20        0];

else
    
    if nargin < 3 || isempty(lapse)
        lapse = 0.0001;
    end    
    
    if fits(2) == 0
        fits(2) = 0.0001;
    end
    
    PHI   = 0.3;
    R0    = 10;
    M     = 1.25;

    acm   = fits(1).*data(:,1).^M;
    mu    = acm./fits(2).*(exp(fits(2)*data(:,2))-1);
    nu    = (2*R0+acm).*PHI./(2*fits(2)).*(exp(2*fits(2)*data(:,2))-1);
    vals_ = 0.5 + (0.5 - lapse).*erf(mu./sqrt(2*nu));    
end
