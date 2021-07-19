function P = ddRT_psycho_val(Q, x)
% get values of the drift-diffusion RT psychometric function
%
%   P = ddRT_psycho_val(Q, x)
%
%   P is the probability of a (correct) response.
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
%   x is the stimulus strength
%
%   ddRT_psycho_val ignores Q(6).
%
%   So,
%       p = 1 / (1 + exp(-2 * A' * sign(x)*(k|x|)^b))
%   or, equally, 
%       p = 1 / (1 + exp(-2 * Q(3) * sign(x)*(Q(1)|x|)^Q(2)))
%
%   This is from equations A.18-A.20 in 
%   Palmer, Huk, and Shadlen, "The effect of stimulus strength on the
%   speed and accuracy of a perceptual decision." Journal of Vision (2005)
%   5, 376-404.
%
%   And, for a version of Abbott's law, 
%       P = Q(5) + (1-Q(4)-(Q5))*(p-.5)*2

%   2008 Benjamin Heasly, University of Pennsylvania
if length(Q) == 3
    Q(4:5) = 0;
end
p = 1 ./ (1 + exp(-2 * Q(3) * sign(x).*(Q(1) * abs(x)).^Q(2)));
%P = Q(5) + (1-Q(4)-Q(5))*p;

P = Q(5) + (1-Q(4)-Q(5))*(p-.5)*2;