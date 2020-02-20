function Qbound = ddRT_initial_params
%Give, reasonable, wide bounds for drift-diffusion parameters
%
%   Qbound = ddRT_initial_params
%
%   Just for convenience and uniformity, specify ddm bounds in one place
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

Qinit = nan*zeros(6,2);

% sensitivity, k
Qbound(1,:) = [1e-4, 1];

% facilitation, b
Qbound(2,:) = [1, 1];

% normalized bound height, A'
Qbound(3,:) = [1e-4, 5];

% lapse rate, lambda
Qbound(4,:) = [.01, .01];

% guess rate, gamma
Qbound(5,:) = [0.5, 0.5];

% residual response time, tR
Qbound(6,:) = [.250, .500];