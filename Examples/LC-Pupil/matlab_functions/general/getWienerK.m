function [wk_, r_, err_] = getWienerK(in_vec, out_vec, max_lag)
% function [wk_, r_, err_] = getWienerK(in_vec, out_vec, max_lag)
%
% returns wk and pearson's r for
%   filtered in versus out

% Written 3/18/04 by Joshua Gold

% check args
if nargin < 2 || isempty(in_vec) || isempty(out_vec)
    return
end

if nargin < 3 || isempty(max_lag)
    max_lag = 10;
end

% get autocorrelation vector of input
ac = xcorr(in_vec, max_lag-1);

% get xcorr of input/output
xc = xcorr(in_vec, out_vec, max_lag-1);

% compute wiener kernel
wk_ = toeplitz(ac(max_lag:-1:1))\xc(max_lag:-1:1);

if nargout > 1
    yhat = filter(wk_,1,in_vec);
    cc   = corrcoef(yhat, out_vec);
    r_   = cc(2,1);
end

if nargout > 2
    s2   = 1/(length(in_vec)-max_lag).*sum((out_vec-yhat).^2);
    err_ = sqrt(diag(s2*inv(toeplitz(ac(max_lag:-1:1)))));
end
