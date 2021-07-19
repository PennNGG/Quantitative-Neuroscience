function vals_ = ddOU4b(fits, data, lapse)
% function vals_ = ddOU4b(fits, data, lapse)
%
% 3 parameters: A, leak, M, bias
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
%       fits(3) ... M
%       fits(4) ... bias
% 
% lapse uses abbott's law
% P = G + (1 - G - L)P*
% where here P* = erf and G (guess) = 0.5

% return initial values (init, min, max)
if nargin < 1 || isempty(fits)
    
    % get initial values from ddExp3g
    if nargin < 2 || isempty(data)
        vals_ = ddOU3b;
    else
        vals_ = ddOU3b([], data);
    end

    vals_ = [vals_(1:2,:); [1.25 0 5]; vals_(3,:)];

else
    if nargin < 3 || isempty(lapse)
        lapse = 0.0001;
    end    
    
    if fits(2) == 0
        fits(2) = 0.0001;
    end
    
    PHI   = 0.3;
    R0    = 10;

    acm   = fits(1).*data(:,1).^fits(3);
    mu    = acm./fits(2).*(exp(fits(2)*data(:,2))-1);
    nu    = (2*R0+acm).*PHI./(2*fits(2)).*(exp(2*fits(2)*data(:,2))-1);
    vals_ = 0.5 + (0.5 - lapse).*erf((mu+fits(4).*data(:,3))./sqrt(2*nu));  
end
