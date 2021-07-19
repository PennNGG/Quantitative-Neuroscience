function alloc(e, num_trials)
% function alloc(e, num_trials)
%
% Alloc method for class errors.
%
% Input:
%   e          ... the errors object
%   num_trials ... number of trials to add
%
% Output:
%   squat, but allocates mem for new trials in FIRA.errors

% Copyright 2007 Benjamin Heasly
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.errors is just an nx1 cell array
FIRA.errors = cat(1, FIRA.errors, cell(num_trials, 1));