function alloc(d, num_trials)
% function alloc(d, num_trials)
%
% Alloc method for class distrData.
%
% Input:
%   d          ... the distrData object
%   num_trials ... number of trials to add
%
% Output:
%   squat, but allocates mem for new trials in FIRA.distrData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.distrData is just an nx1 cell array
FIRA.distrData = cat(1, FIRA.distrData, cell(num_trials, 1));
