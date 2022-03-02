function vals_ = dds1(fits, data, lapse)
% function vals_ = dds1(fits, data, lapse)
%
% 1 parameter: A
% s for simple: uses standard DDM assumptions about noise 
%
% Computes TIME-based DD function.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^M, where M is fixed, below
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... time (sec)
%       data(3)   ... dot dir (-1/1)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
% 
% lapse uses abbott's law
% P = G + (1 - G - L)P*
% where here P* = erf and G (guess) = 0.5

% return initial values (init, min, max)
if nargin < 1 || isempty(fits)
    
    % data matrix includes pcor (last column)
    if nargin < 2 || isempty(data)
        Aguess = 20;
    else
        Aguess = (sum(data(:,end))./size(data,1)-0.45)*40;
    end

    % vals_ = [Aguess 0.0001 100];
    vals_ = [2 0.0001 100];

else
        
    if nargin < 3 || isempty(lapse)
        lapse = 0.001;
    end
    
    % Pcor is 1 - PHI(-kC * sqrt(T))
    %   where PHI is standard cumulative normal distribution
    vals_ = 1 - normcdf(-fits(1).*data(:,1).*sqrt(data(:,2)));
    
    % add lapse
    vals_ = (1 + (1-2*lapse)*(2.*vals_-1))/2;
end
