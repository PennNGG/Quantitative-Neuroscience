function ps_ = logist_valLUg(fits, data, lapse)
% function ps_ = logist_valLUg(fits, data, lapse)
%
% Uses the logistic model to compute p (probability of
% making a particular decision) for the given data (m rows
% of trials x n columns of data categories) and parameters
% (nx1). Assumes logit(p) (that is, ln(p/(1-p)) is a linear
% function of the data. lapse given.
% by Abbott's law (see Strasburger 2001, or Finney 1974)

% mxn times nx1 gives mx1
ps_ = lapse + (1 - 2*lapse)./(1+exp(-(data*fits)));
