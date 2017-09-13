function vals_ = linearPiecewiseSimple2(fits, xs)
% function vals_ = linearPiecewiseSimple2(fits, xs)
%
% Really simple piecewise linear function. Uses two parameters to define two
%   pieces:
%   1. y = 0
%   2. y = mx
%  
%  Arguments:
%   fits:   the two fit parameters
%               fits(1): inflection point
%               fits(2): slope after inflection point (m)
%   xs:     values to compute function over
%   
%  Returns:
%   vals_:  values computed from xs and fits
%
% Created 09/2017 by Joshua I Gold
%   University of Pennsylvania

% make array filled with zeros
vals_ = zeros(size(xs));

% find elements after inflection point
Lg = xs>=fits(1);

% compute linear portion after inflection point
vals_(Lg) = (xs(Lg)-fits(1))*fits(2);
