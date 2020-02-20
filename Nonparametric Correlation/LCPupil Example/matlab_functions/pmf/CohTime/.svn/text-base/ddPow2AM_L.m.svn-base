function vals_ = ddPow2AM_L(fits, data, lapse, dvflag)
% function vals_ = ddPow2AM_L(fits, data, lapse, dvflag)
%
% 2 parameters: A, M
%
% Computes TIME-based DD function with LAPSE and BIAS.
%   Assumes DD to a fixed TIME (given as col 2 of data).
%   Thus, pct correct is fraction of gaussian above
%       0 at TIME.
%   Max Drift rate depends on coherence as a power law:
%       A_max(coh) = A*coh^M
%
%   at values in "data":
%       data(1)   ... coh [0 ... 1]
%       data(2)   ... time (sec)
%
%   given parameters in "fits":
%       fits(1) ... A      (coh scale)
%       fits(2) ... M      (time exponent)
%
% lapse uses abbott's law
% P = 0.5 + (0.5 - L)P*
% here  P* = erf

% return initial values (init, min, max)
if nargin < 2 || isempty(fits)

    % data matrix includes pcor (last column)
    if nargin < 2 || isempty(data)
        Aguess = 20;
    else
        Aguess = (sum(data(:,end))./size(data,1)-0.45)*40;
    end

    vals_ = [ ...
        Aguess  0.0001 100; ...
         1      0.0001   2];
else

    PHI   = 0.3;
    R0    = 20;
    N     = 0.4; % just cuz

    acm   = fits(1).*data(:,1).^fits(2);
    tn    = data(:,2).^N;
    mu    = acm.*tn;
%     nu    = sqrt(PHI.*tn.*(2*R0 + acm));
    nu    = sqrt(R0 + PHI.*tn.*acm);

    if nargin > 3 && dvflag
    
        % return expected value of dv
        xs    = (0:0.1:100)';
        vals_ = nans(size(data,1),1);
        for vv = 1:size(data,1)
            ps = normpdf(xs,mu(vv),nu(vv));
            vals_(vv) = sum(xs.*ps)./10; % expected value, NOT area, dummy
        end
        
    else        
        if nargin < 3 || isempty(lapse) || lapse == 0
            lapse = 0.001;
        end

        vals_ = 0.5 + (0.5 - lapse).*erf(mu./nu./sqrt(2));
    end
end