function m = nanharmmean(x,dim)
%NANHARMMEAN Mean value, ignoring NaNs.
%   M = NANHARMMEAN(X) returns the sample harmonic mean of X, treating NaNs as missing
%   values.  For vector input, M is the harmonic mean value of the non-NaN elements
%   in X.  For matrix input, M is a row vector containing the harmonic mean value of
%   non-NaN elements in each column.  For N-D arrays, NANHARMMEAN operates
%   along the first non-singleton dimension.
%
%   NANHARMMEAN(X,DIM) takes the harmonic mean along dimension DIM of X.
%
%   See also MEAN, NANMEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.

% written by jcl on 10/28/05, modified from nanmean.m

% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = inf;

if nargin == 1 % let sum deal with figuring out which dimension to use
    % Count up non-NaNs.
    n = sum(~nans);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(1./x)./n;
    m = 1 ./ m;
else
    % Count up non-NaNs.
    n = sum(~nans,dim);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(1./x, dim)./n;
    m = 1 ./ m;
end

