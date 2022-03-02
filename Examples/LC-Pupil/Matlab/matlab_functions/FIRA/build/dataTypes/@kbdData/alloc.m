function alloc(k, num_trials)
% function alloc(k, num_trials)
%
% Alloc method for class kbdData.
%
% Input:
%   k          ... the kbdData object
%   num_trials ... number of trials to add
%
% Output:
%   nada, but allocates mem for new trials in FIRA.kbdData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.kbdData is just an nx1 cell array
FIRA.kbdData = cat(1, FIRA.kbdData, cell(num_trials, 1));
