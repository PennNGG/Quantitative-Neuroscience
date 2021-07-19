function err_ = later_err(fits, rrts)
% function err_ = later_err(fits, rrts)
%
% fits are:
%   1 ... mean of rate of rise
%   2 ... bound height
%
% rrts are reciprocal rts, in seconds
%
% Copyright 2019 by Joshua I. Gold, University of Pennsylvania

% negative sum log likelihood
err_ = -sum(log(normpdf(rrts, fits(1)/fits(2), 1/fits(2))));