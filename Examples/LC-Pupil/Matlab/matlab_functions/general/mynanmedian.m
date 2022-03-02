function y = mynanmedian(x,dim)
%NANMEDIAN Median value, ignoring NaNs.
%   M = NANMEDIAN(X) returns the sample median of X, treating NaNs as
%   missing values.  For vector input, M is the median value of the non-NaN
%   elements in X.  For matrix input, M is a row vector containing the
%   median value of non-NaN elements in each column.  For N-D arrays,
%   NANMEDIAN operates along the first non-singleton dimension.
%
%   NANMEDIAN(X,DIM) takes the median along the dimension DIM of X.
%
%   See also MEDIAN, NANMEAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.12.2.2 $  $Date: 2004/01/24 09:34:33 $
%
%   Modified by jcl on 10/14/05
%    use myprctile instead of prctile, there is a bug in the error checking
%    in prctile.m

if nargin == 1
    y = myprctile(x, 50);
else
    y = myprctile(x, 50, dim);
end
