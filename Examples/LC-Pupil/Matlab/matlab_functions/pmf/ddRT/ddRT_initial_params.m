function Qinit = ddRT_initial_params(data)
%Estimate starting values for drift-diffusion parameters
%
%   I'm finding that doing drift-diffusion fits is sensitive to initial
%   parameter guesses--too much so for comfort.  In particlular, the
%   tradeoff between A' and tR is too pronounced for me to trust.
%
%   So I want to look at the data, make a few assumptions, and try to pick
%   starting values that are in the neighborhood of the "true" values.
%
%   data is an nx3 array of data from n trials:
%       data(:,1) is the sequence of stimulus strengths
%       data(:,2) is the sequence of choices (0 or 1)
%       data(:,3) is the sequence of response times
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

% 2008 Benjamin Heasly at University of Pennsylvania

Qinit = nan*zeros(6,1);
xmax = max(data(:,1));
xmin = min(data(:,1));

% lapse and guess rate are easiest
%   in fact, just pick sensible constants
Qinit(4) = .01;
Qinit(5) = .5;

% facilitation exponent b is generally close to 1
%   and often we just want linear stimulus scaling anyway
Qinit(2) = 1;

% Assuming no anticipatory resonses, the lowest reaction time
%   at the highest stimulus strength is an upper bound on tR
Qinit(6) = min(data(data(:,1)==xmax,3));

% Use the lowest stimulus strength as a standin for zero stimulus strength,
%   and use the mean reaction time there as an estimate of tT(x=0).  At
%   x=0, tT = A'^2 + tR, and so we can solve for A'.
Qinit(3) = sqrt(mean(data(data(:,1)==xmin,3)) - Qinit(6));

% Finally, we can use this A' and the accurace data to solve for k.
%   Pick xmax, arbitrarily.
%   Avoid log(0) and log(inf)
xarb = xmax;
p = max(min(mean(data(data(:,1)==xarb,2)), .99), .01);
Qinit(1) = log((1-p)/p)/(-2*xarb*Qinit(3));