function nll = ddRT_chrono_nll_from_data(Q, data)
% get likelihood of drift-diffusion parameters from response times
%
%   nll = ddRT_chrono_nll_from_data(Q, data)
%
%   nll is the negative-log-likelihood of drift-diffusion model parameters
%   Q, given the stimuli and response times in data.
%
%   It's hard to predict the distribution or variability of response times
%   as a function of stimulus strength (see ddRT_chrono_var.m).  So here,
%   get mean and variance of measured response times and compare as
%   Gaussian to model-predicted mean response time.  This assumes you have
%   a good number of trials at each stimulus strength.
%
%   Also, ignore response times above the 95%ile.  Long outliers cause the
%   Gaussian to be too wide and dilute the influence of response times in
%   doing simultaneous choice-time ddRT fits.
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

    % ignore 95%ile outliers
    allLiers = data(stimSelect,3);
    inliers = allLiers(allLiers<=prctile(allLiers, 95));

    %VAR = var(data(stimSelect,3));
    %mu = mean(data(stimSelect,3));
    %n = sum(stimSelect);
    VAR = var(inliers);
    mu = mean(inliers);
    n = length(inliers);

    % standard error of the mean response time
    sig = sqrt(VAR/n);
    
    %disp([VAR sig n mu])

    % predicted mean response time at this stimulus strength
    T = ddRT_chrono_val(Q, stims(ii));

    % Gaussian likelihood of predicted response time given the data
    like = normpdf(T, mu, sig);

    nll = nll - log(like);
end