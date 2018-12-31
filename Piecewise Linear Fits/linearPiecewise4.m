function vals_ = linearPiecewise4(fits, xs)
% function vals_ = linearPiecewise4(fits, xs)
%
% Piecewise linear function. Uses four parameters to define 2 
%   linear functions:
%   y = m1 * x + b1
%   y = m2 * x + b2
%
% Assumes that the point where the two functions cross defines the start/stop
%   points of the two functions with respect to the data, such that the 
%   first function describes points to the left, and the second function
%   describes points to the right.
%   
%  Arguments:
%   fits:   the four fit parameters m1, b1, m2, b2
%   xs:     values to compute function over
%   
%  Returns:
%   vals_:  values computed from xs and fits
%
% Created 09/2017 by Joshua I Gold
%   University of Pennsylvania

% for ease of reading
m1 = fits(1);
b1 = fits(2);
m2 = fits(3);
b2 = fits(4);

% get logical arrays of xs values associated with each function
% 1. special case of parallel lines
if m1 == m2
    Lx1 = true(size(xs));
else
    Lx1 = xs<=((b2-b1)./(m1-m2));
end

% make dummy array
vals_ = xs;

% function #1
vals_(Lx1) = xs(Lx1).*m1 + b1;

% function #2
vals_(~Lx1) = xs(~Lx1).*m2 + b2;
