function nll = ddRT_chrono_nll_from_data(Q, data)
% get likelihood of drift-diffusion parameters from response times
%
%   nll = ddRT_chrono_nll_from_data(Q, data)
%
%   nll is the negative-log-likelihood of drift-diffusion model parameters
%   Q, given the stimuli and response times in data.
%
%   From repeated simulations, I found that the standard deviation of mean
%   response time at a given drift rate is roughly equal to .8 times the
%   decision time.  So this gives a Fano factor of 1.25.  This is a rough
%   prediction of the expected variance of mean response time.
%
%   There is an analytical solution to variance of mean response time.  In
%   Palmer, Huk and Shadlen, "The effect of stimulus strength on the speed
%   and accuracy of a perceptual decision," J. Vision 2005, they give
%   equation A.34.  But this doesn't work.  It gives negative variances
%   when the A' parameter is greater than 1.  So there must be an algebraic
%   or printing error.
%
%   Q is a 6-element vector of drift-diffusion parameters:
%
%   Q(1:3) are generic, ideal drift-diffusion parameters:
%       Q(1) is k, the scale factor for stimulus stimulus strength.
%       Q(2) is b (or beta), the exponent of facilitation for stimulus
%       strength.
%       Q(3) is A', the normalized bound height for accumulation (assumes
%       symmetric bounds A'=B');
%
%   Q(4:6) are for accomodating real data:
%       Q(4) is the psychometric lapse rate or upper asymptote.
%       Q(5) is the psychometric guess rate or lower asymptote.
%       Q(6) is tR, the residual, non-decision response time.
%
%   data is an nx3 array of data from n trials:
%       data(:,1) is the sequence of stimulus strengths
%       data(:,2) is the sequence of choices (0 or 1)
%       data(:,3) is the sequence of response times
%
%   ddRT_psycho_nll ignores Q(4), Q(5) and data(:,2).

%   2008 Benjamin Heasly, University of Pennsylvania

stims = unique(data(:,1));
nll = 0;
for ii = 1:length(stims)

    % isolate by stimulus strength
    stimSelect = data(:,1)==stims(ii);
    n = sum(stimSelect);

    % measured mean response time
    mu = mean(data(stimSelect,3));

    % predicted mean response time at this stimulus strength
    T = ddRT_chrono_val(Q, stims(ii));

    % predict the standard deviation of this prediction of the mean with a
    % fano factor of 1.25.
    std = 0.8*T;

    % get standard error with this standard deviation
    sig = std/sqrt(n);

    % Gaussian likelihood of predicted response time given the data
    like = normpdf(T, mu, sig);

    nll = nll - log(like);
end