function pm_ = poissMoment(lambda, n)
% function pm_ = poissMoment(lambda, n)
%
% Gets the nth raw moment of a poisson distribution
%   with parameter lambda

pm_  = polyval([flipdim(get_sn2k(round(n)),2) 0], lambda);

