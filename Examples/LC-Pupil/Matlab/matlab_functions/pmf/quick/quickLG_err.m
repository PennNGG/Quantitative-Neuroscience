function err_ = quickLG_err(fits, data)
% function err_ = quickLG_err(fits, data)
%
%	Computes the error of the Quick function fit, given
%		the data (as a global) and the Quick parameters (fits).
%		Used by fmincon.
%
%	The Quick function is (assumes a guess rate of 0.5):
% -
%	  y = lapse + (0.5-lapse) * exp( -(x/alpha)^beta )
% -
%
%	Input:
%		fits is the vector of 3 Quick parameters ...
%			fits(1) = alpha (threshold)
%			fits(2) = beta (slope)
%			fits(3) = lapse rate (upper asymptote), not
%                       fit here if given explicitly 
%
%		data is the (global) (duhh) data, in columns ...
%			data(:, 1) = abscissa (e.g., coh)
%			data(:, 2) = observed percent correct (0..1)
%			data(:, 3) = number of observations.
%
%	Returns:
%		err_ ... the negative of the log likelihood of obtaining the data 
%					using the given parameters.
%

% compute the Quick fit
ps = quickLG_val(data(:,1), fits(1), fits(2), fits(3), fits(4));

% compute log Likelihood of the data given the current fits:
%   (data | fits)
% note that fmincon searches for minimum, which
% is why we send the negatve of logL
% see appendix of Watson's "Probability summation over time" (1978)
% paper for derivation

% avoid log(0)
ps(ps==0) = 0.0001;
ps(ps==1) = 1 - 0.0001;
err_      = -sum(data(:,3).*(data(:,2).*log(ps) + (1-data(:,2)).*log(1-ps)));

% try to approximate chi-2 using Pearson's statistic
%err_ = sum((n.*(y-z).^2)./(z.*(1-z)));
