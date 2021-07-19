function vals_ = ddPow3ANZ_L(fits, data, lapse, dvflag)
% function vals_ = ddPow3ANZ_L(fits, data, lapse, dvflag)
%
% 3 parameters: A, N, and a bias (fixed offset)
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
%       fits(2) ... N      (time exponent)
%       fits(3) ... bias   (z-score) scaling factor
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    if nargin < 2
        data = [];
    end

    % get initial values from ddExp3g
    if nargin < 2 || isempty(data)
        vals_ = ddExp4z;
    else
        vals_ = ddExp4z([], data);
    end

    % remove lapse
    vals_(3,:) = [];
    vals_(1,3) = 40;
    vals_(2,3) = 1;

else

    PHI   = 0.3;
    R0    = 10;
    M     = 1.25; % just cuz

    acm   = fits(1).*data(:,1).^M;
    tn    = data(:,2).^fits(2);
    mu    = acm.*tn;
    nu    = sqrt(PHI.*tn.*(2*R0 + acm));

    if nargin > 3 && dvflag
    
        % return dv
        xs    = (0:0.1:200)';
        vals_ = nans(size(data,1),1);
        for vv = 1:size(data,1)
            ps = normpdf(xs,mu(vv)+fits(3).*data(vv,3),nu(vv));
            vals_(vv) = sum(xs.*ps)./10;
        end
        
    else        
        if nargin < 3 || isempty(lapse) || lapse == 0
            lapse = 0.001;
        end

        if size(data,2) == 3
            vals_ = 0.5 + (0.5 - lapse).* ...
                erf((mu+fits(3).*data(:,3))./(nu.*sqrt(2)));
        else
            vals_ = 0.5 + (0.5 - lapse).* ...
                erf(mu./(nu.*sqrt(2)));
        end
    end
end