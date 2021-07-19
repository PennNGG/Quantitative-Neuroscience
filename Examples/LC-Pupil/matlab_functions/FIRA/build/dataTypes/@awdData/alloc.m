function alloc(a, num_trials)
% function alloc(a, num_trials)
%
% Alloc method for class awdData.
%
% Input:
%   k          ... the awdData object
%   num_trials ... number of trials to add
%
% Output:
%   nada, but allocates mem for new trials in FIRA.awData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.awdData is just an nx1 cell array
FIRA.awdData = cat(1, FIRA.awdData, cell(num_trials, 1));
