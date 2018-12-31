function vals_ = linear2(fits, xs)
% function vals_ = linear2(fits, xs)
%
% Simple linear function y = mx + b.
%   
%  Arguments:
%   fits:   the two fit parameters m, b
%   xs:     values to compute function over
%   
%  Returns:
%   vals_:  values computed from xs and fits
%
% Created 09/2017 by Joshua I Gold
%   University of Pennsylvania

vals_ = fits(1).*xs + fits(2);
