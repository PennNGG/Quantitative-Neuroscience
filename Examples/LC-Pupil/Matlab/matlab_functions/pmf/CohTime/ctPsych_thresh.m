function [thresh_, cis_, slope_] = ctPsych_thresh(fun, fits, sems, fracc, vtime)
% function [thresh_, cis_, slope_] = ctPsych_thresh(fun, fits, sems, fracc, vtime)
%
% computes threshold from general ctPsych function:
%   coherence needed for "fracc" fraction correct at "vtime"
%   viewing time. no lapse, no bias
% 

if nargin < 2 || isempty(fits)
    thresh_ = nan;
    return
end

if nargin < 4 || isempty(fracc)
    fracc = 0.8161;
end

if nargin < 5 || isempty(vtime)
    vtime = 1;
end

% yeegads. Find initial values of fit == 0 (not given
%   data), assume these correspond to lapse & bias
%   terms, set to 0
in0       = feval(fun);
L0        = in0(:,1) == 0;
tfits     = fits;
tfits(L0) = 0;

GRAIN     = 0.001;
cohs      = (GRAIN:GRAIN:1)';
tdat      = [cohs vtime.*ones(size(cohs,1),1) ones(size(cohs))];
ps        = feval(fun, tfits, tdat);
ti        = find(ps>=fracc,1);
if isempty(ti)
    thresh_ = 1.0;
else
    thresh_ = cohs(ti);
end

if nargout > 1 && nargin >= 3 && ~isempty(sems)
    % get monte carlo fits
    n     = 1000;
    Ffits = find(~L0)';
    fitr  = repmat(tfits', n, 1);
    for ff = Ffits
        fitr(:,ff) = min(in0(ff,3),max(in0(ff,2),normrnd(fits(ff), sems(ff), n, 1)));
    end
    rti = length(cohs)*ones(n,1);
    for nn = 1:n
        ps = feval(fun, fitr(nn,:)', tdat);
        ff = find(ps>fracc,1);
        if ~isempty(ff)
            rti(nn) = find(ps>=fracc,1);
        end
    end
    cii = round(prctile(rti,[16 84]));
    if length(cii) == 2
        cis_ = [cohs(cii(1)) cohs(cii(2))];
    end
end

if nargout > 2
    sls    = diff(ps)./diff(log(cohs));
    slope_ = sls(find(sls==max(sls),1));
end

