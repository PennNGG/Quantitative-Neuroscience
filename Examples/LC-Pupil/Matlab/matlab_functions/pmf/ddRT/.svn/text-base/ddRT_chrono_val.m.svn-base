function t = ddRT_chrono_val(Q, x)
% get values of the drift-diffusion RT chronometric function
%
%   t = ddRT_chrono_val(Q, x)
%
%   t is the mean respons time.
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
%   ddRT_psycho_val ignores Q(4), Q(5).
%
%   So,
%       t = tR + (A'/kx) * tanh(A'kx),  x~=0
%         = tR + A'^2,                  x==0
%   or, equally, 
%       t = Q(6) + (Q(3)./(Q(1)*x) .* tanh(Q(3)*Q(1)*x)),   x~=0
%         = Q(6) + Q(3)^2,                                  x==0
%
%   This is from equation A.21 in 
%   Palmer, Huk, and Shadlen, "The effect of stimulus strength on the
%   speed and accuracy of a perceptual decision." Journal of Vision (2005)
%   5, 376-404.

%   2008 Benjamin Heasly, University of Pennsylvania

z = x==0;
t(~z) = Q(6) + (Q(3)./(Q(1)*x(~z)) .* tanh(Q(3)*Q(1)*x(~z)));
t(z) = Q(6) + Q(3)^2;