function m = nangeomean(x,dim)
%NANGEOMEAN Mean value, ignoring NaNs.
%   M = NANGEOMEAN(X) returns the sample geometric mean of X, treating NaNs as missing
%   values.  For vector input, M is the geometric mean value of the non-NaN elements
%   in X.  For matrix input, M is a row vector containing the geometric mean value of
%   non-NaN elements in each column.  For N-D arrays, NANGEOMEAN operates
%   along the first non-singleton dimension.
%
%   NANGEOMEAN(X,DIM) takes the geometric mean along dimension DIM of X.
%
%   See also MEAN, NANMEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.

% written by jcl on 10/28/05, modified from nanmean.m

% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = 1;

if nargin == 1 % let sum deal with figuring out which dimension to use
    % Count up non-NaNs.
    n = sum(~nans);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = exp(sum(log(x))./n);
else
    % Count up non-NaNs.
    n = sum(~nans,dim);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = exp(sum(log(x),dim)./n);
end

