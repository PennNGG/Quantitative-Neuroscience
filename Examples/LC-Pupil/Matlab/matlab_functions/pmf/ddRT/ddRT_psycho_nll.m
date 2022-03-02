function nll = ddRT_psycho_nll(Q, data)
% get likelihood of drift-diffusion parameters from choice data
%
%   nll = ddRT_psycho_nll(Q, data)
%
%   nll is the negative-log-likelihood of drift-diffusion model parameters
%   Q, given the stimuli and choices in data.
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
%   ddRT_psycho_nll ignores Q(6) and data(:,3).

%   2008 Benjamin Heasly, University of Pennsylvania
yes = data(:,2) == 1;
likeYes = ddRT_psycho_val(Q, data(yes,1));
likeNo = 1-ddRT_psycho_val(Q, data(~yes,1));
nll = -sum(log(likeYes)) - sum(log(likeNo));