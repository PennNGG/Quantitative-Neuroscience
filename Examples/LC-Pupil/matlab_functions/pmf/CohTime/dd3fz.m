function vals_ = dd3fz(fits, data, fc)
% function vals_ = dd3fz(fits, data, fc)
%
% 3 parameters: A, lapse, and a bias
%   parameter that scales the filtered choice array
%
% Computes TIME-based DD function with LAPSE and BIAS.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^1.25
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... time (sec)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... lambda ("lapse")
%       fits(3) ... bias   (z-score) scaling factor
%
%   fc ... (optional) array of filtered choices
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    if nargin < 2
        data = [];
    end

    % get initial values from ddExp3z
    vals_ = dd2([], data);
    vals_(3,:) = [5 -50 50];
   
else

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25; % just cuz
    
    if fits(2) == 0
        fits(2) = 0.0001;
    end
    acm   = fits(1).*data(:,1).^M;
    mu    = acm.*sqrt(data(:,2));
    nu    = sqrt((2*R0 + acm).*PHI);    
    
    if nargin < 3 || isempty(fc)
        vals_ = 0.5 + (0.5 - fits(2)).*erf(mu./nu./sqrt(2));
    else
        vals_ = 0.5 + (0.5 - fits(2)).* ...
            erf((mu+fits(3).*fc.*data(:,3))./nu./sqrt(2));
    end
end
