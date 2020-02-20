function vals_ = ddOUs2(fits, data, lapse)
% function vals_ = ddOUs2(fits, data, lapse)
%
% 2 parameters: A, leak
%
% s for simple (standard) form
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
    % guess lapse from high-coherence trials    
%     if nargin < 2 || isempty(data) || any(data(:,end)>1)
%         AG = 20;
%     else
%         AG = (sum(data(:,end))./size(data,1)-0.45)*40;
%     end

    vals_ = [ ...
        5    0.0001 100; ...
        0    -50     50];
%     vals_ = [ ...
%         AG      0.0001 100; ...
%         -1    -20       20]

else
    
    if nargin < 3 || isempty(lapse)
        lapse = 0.001;
    end    
    
    if fits(2) == 0 
        
        % use DDM
        vals_ = dds1(fits(1), data, lapse);

    else
        
        leak = abs(fits(2));
        A    = fits(1);
        
        % Pcor is 1 - PHI(-kC * sqrt(stuff))
        %   where PHI is standard cumulative normal distribution
        %   see Bogacz et al 2006, Eq. 2.12
        elt = exp(leak*data(:,2));
        vals_ = 1 - normcdf(-A.*data(:,1).* ...
            sqrt(2./leak.*(elt-1)./(elt+1)));
    
        % add lapse
        vals_ = (1 + (1-2*lapse)*(2.*vals_-1))/2;
    end
end
