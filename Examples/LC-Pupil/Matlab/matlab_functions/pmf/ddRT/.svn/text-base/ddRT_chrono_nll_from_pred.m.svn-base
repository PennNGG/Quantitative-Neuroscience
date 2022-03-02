function nll = ddRT_chrono_nll_from_pred(Q, data)
% get likelihood of drift-diffusion parameters from response times
%
%   nll = ddRT_chrono_nll_from_pred(Q, data)
%
%   nll is the negative-log-likelihood of drift-diffusion model parameters
%   Q, given the stimuli and response times in data.
%
%   Predict the variance of response times as a function of stimulus
%   strength, given a drift-diffusion parameter set.  This comes from
%   equations A.34 and A.35 in Palmer, Huk, Shadlen 2005, "The effect
%   stimulus strength on the speed and accuracy of a perceptual decision".
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
%
%   See also ddRT_chrono_var ddRT_chrono_nll_from_fano
%   ddRT_chrono_nll_from_data

%   2008 Benjamin Heasly, University of Pennsylvania

stims = unique(data(:,1));
nll = 0;
VARD = ddRT_chrono_var(Q, stims);
VARR = (.01*Q(6))^2;
for ii = 1:length(stims)

    % isolate by stimulus strength
    stimSelect = data(:,1)==stims(ii);

    % ignore 95%ile outliers...?
    allLiers = data(stimSelect,3);
    inliers = allLiers(allLiers<=prctile(allLiers, 95));
   
    mu = mean(inliers);
    n = length(inliers);

    % standard error of the mean response time
    sig = sqrt((VARD(ii)+VARR)/n);
    
    %disp([sig n mu])

    % predicted mean response time at this stimulus strength
    T = ddRT_chrono_val(Q, stims(ii));

    % Gaussian likelihood of predicted response time given the data
    like = normpdf(T, mu, sig);

    nll = nll - log(like);
end