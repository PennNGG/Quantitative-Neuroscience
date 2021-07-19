function err_ = quick_err(fits, data, guess, lapse)
% function err_ = quick_err(fits, data, guess, lapse)
%
%	Computes the error of the Quick function fit, given
%		the data (as a global) and the Quick parameters (fits).
%		Used by fmincon. See quick_val for the definition
%       of the Quick function.
%
%	Input:
%		fits is the vector of 2-4 Quick parameters ...
%			fits(1) = alpha (threshold)
%			fits(2) = beta (slope)
%			fits(3) = (optional) guess rate (lower asymptote)
%			fits(4) = (optional) lapse rate (upper asymptote)
%
%
%		data is the (global) (duhh) data, in columns ...
%			data(:, 1) = abscissa (e.g., coh)
%			data(:, 2) = observed percent correct (0..1)
%			data(:, 3) = (optional) number of observations.
%
%	Returns:
%		err_ ... the negative of the log likelihood of obtaining the data 
%					using the given parameters.
%

if isempty(guess)
    guess = fits(3);
end

if isempty(lapse)
    lapse = fits(end);
end

% compute the Quick fit
ps = quick_val(data(:,1), fits(1), fits(2), guess, lapse);

% Avoid log 0
ps(ps==0) = 0.001;
ps(ps==1) = 1 - 0.001;

if size(data, 2) == 2

    % Now calculate the joint probability of obtaining the data set conceived as
    %   a list of Bernoulli trials.  This is just ps for trials = 1 (correct) and
    %   1-ps for trials of 0 (error).
    % Note that fmincon searches for minimum, which
    %   is why we send the negatve of logL
    err_ = -sum(log([ps(data(:,2)==1); 1-ps(data(:,2)==0)]));

else

    % use 'n' values
    % see appendix of Watson's "Probability summation over time" (1978)
    % paper for derivation
    err_ = -sum(data(:,3).*(data(:,2).*log(ps) + (1-data(:,2)).*log(1-ps)));
end
