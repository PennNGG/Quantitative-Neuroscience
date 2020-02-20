function err_ = reciprobit_err(fits, rrts)
% function err_ = reciprobit_err(fits, rrts)
%
% fits are:
%   1 ... mean of rate of rise
%   2 ... bound height
%
% rrts are reciprocal rts

% negative sum log likelihood
err_ = -sum(log(normpdf(rrts, fits(1)/fits(2), 1/fits(2))));