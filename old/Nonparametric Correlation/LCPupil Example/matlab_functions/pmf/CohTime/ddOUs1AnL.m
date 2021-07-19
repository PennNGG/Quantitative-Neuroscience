function vals_ = ddOUs1AnL(fits, data, lapse, Lg)
% function vals_ = ddOUs1AnL(fits, data, lapse, Lg)
%
% 1 parameter for A, fit to all data
% n parameters for Leak, fit separately to each group (from Lg)
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
%       fits(1) ... A       (coh scale)
%       fits(2) ... leak_1  (OU Leak)
%       .
%       .
%       . 
%       fits(n) ... leak_n-1
% 
% lapse uses abbott's law
% P = G + (1 - G - L)P*
% where here P* = erf and G (guess) = 0.5

nGroups = size(Lg,2);

% return initial values (init, min, max)
if nargin < 1 || isempty(fits)
    
    % data matrix includes pcor (last column)
    % guess lapse from high-coherence trials
    %     if nargin < 2 || isempty(data) || any(data(:,end)>1)
    %         AG = 20;
    %     else
    %         AG = (sum(data(:,end))./size(data,1)-0.45)*40;
    %     end
    %     vals_ = [ ...
    %         AG      0.0001 100; ...
    %         -1    -20       20]

    vals_ = cat(1, [2 0.0001 100], ...
        repmat([0 -50 50], nGroups, 1));

else
    
    if nargin < 3 || isempty(lapse)
        lapse = 0.01;
    end    
    
    vals_ = nans(size(data,1),1);
    
    for gg = 1:nGroups
        
        leak = fits(1+gg);
        if leak==0 
        
            % use DDM
            vals_(Lg(:,gg)) = dds1(fits(1), data(Lg(:,gg),:), lapse);
        else
            
            % Pcor is 1 - PHI(-kC * sqrt(stuff))
            %   where PHI is standard cumulative normal distribution
            %   see Bogacz et al 2006, Eq. 2.12
            vals_(Lg(:,gg)) = 1 - normcdf(-fits(1).*data(Lg(:,gg),1).* ...
                sqrt(2./leak.*(exp(leak.*data(Lg(:,gg),2))-1)./(exp(leak.*data(Lg(:,gg),2))+1)));
        end
    end
    
    % add lapse
    vals_ = (1 + (1-2*lapse)*(2.*vals_-1))/2;
end
