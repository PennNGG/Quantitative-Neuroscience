function purge(e)
% function purge(e)
%
% Purge method for class errors. 
%   Purges saved errors data from FIRA
%
% Input:
%   e ... the errors object
%
% Output:
%   squat

% Copyright 2007 by Benjamin Heaslt
%   University of Pennsylvania

global FIRA

% purge data from FIRA.errors
FIRA.errors = {};