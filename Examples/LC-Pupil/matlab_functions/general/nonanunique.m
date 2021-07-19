function [b,ndx,pos] = nonanunique(a)
%NANUNIQUE Set unique, with a single NaN value for all NaNs in a set.
%   Identical in usage and arguments to the standard MatLab function
%   unique(). Changes the NaNs to a random value, runs unique on a, and
%   changes the random value back to NaN in b. 
%   Supersedes and replaces unique.m
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

% RCS info: $Id$
%
% Jon Goldberg, 5/14/98 - based on mns' nanallequal.m
% jig 8/10/98 based on nanunique.m

% get the unique nonNaN members of a
aq = a(:);
[b,ndx,pos] = unique(aq(isfinite(aq)));
