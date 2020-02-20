function var = ddRT_chrono_var(Q, x)
% get variance of the drift-diffusion decision times
%
%   var = ddRT_chrono_var(Q, x)
%
%   var is the variance of the decision time.
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
%   ddRT_chrono_var ignores Q(4:5).
%
%   x is the stimulus strength
%
%   So,
%       u' = sign(x)*(k|x|)^b) and
%       var = [A'tanh(A'u') - A'u'(sech(A'u')^2)] / u'^3,   u'~=0
%       var = (2/3)A'^4,                                    u'==0
%   or, equally,
%       u' = sign(x)*(Q(1)|x|)^Q(2)) and
%       var = [Q(3)*tanh(Q(3)u') - Q(3)u'(sech(Q(3)u')^2)] / u'^3,  u'~==0
%       var = (2/3)*Q(3)^4,                                         u'==0
%
%   This is from equations A.34 and A.35 in
%   Palmer, Huk, and Shadlen, "The effect of stimulus strength on the
%   speed and accuracy of a perceptual decision." Journal of Vision (2005)
%   5, 376-404.
%
%   There was actually an error in A.34.  The leftmost A' in the numerator
%   should be outside the bracket.  Also, the power of 2 in the numerator
%   is confusing.  It belongs around the result of the hyperbolic secant
%   function, not around the argument to the function.

%   2008 Benjamin Heasly, University of Pennsylvania

u = sign(x) .* ((Q(1)*abs(x)).^Q(2));
z = u==0;
var(~z) = Q(3)*[tanh(Q(3)*u(~z)) - Q(3)*u(~z).*sech(Q(3)*u(~z)).^2] ...
    ./ (u(~z).^3);
var(z) = (2/3)*Q(3)^4;