function alloc(lp, num_trials)
% function alloc(lp, num_trials)
%
% Alloc method for class lpHIDData.
%
% Input:
%   lp          ... the lpHIDData object
%   num_trials ... number of trials to add
%
% Output:
%   squat, but allocates mem for new trials in FIRA.lpHIDData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.lpHIDData is just an nx1 cell array
FIRA.lpHIDData = cat(1, FIRA.lpHIDData, cell(num_trials, 1));
