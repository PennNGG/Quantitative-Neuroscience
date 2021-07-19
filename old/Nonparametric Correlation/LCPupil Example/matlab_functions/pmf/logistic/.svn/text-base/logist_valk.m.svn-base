function ps_ = logist_valk(fits, data)
% function ps_ = logist_valk(fits, data)
%
% Uses the logistic model to compute p (probability of
% making a particular decision) for the given data (m rows
% of trials x n columns of data categories) and parameters
% (nx1). Assumes logit(p) (that is, ln(p/(1-p)) is a linear
% function of the data.
% Assumes lower bound = 0.01; upper bound = 0.99;
%   (see Klein, 2001)

% mxn times nx1 gives mx1
lapse = 0.00001;
ps_ = lapse + (1 - 2*lapse)./(1+exp(-(data*fits(:))));
