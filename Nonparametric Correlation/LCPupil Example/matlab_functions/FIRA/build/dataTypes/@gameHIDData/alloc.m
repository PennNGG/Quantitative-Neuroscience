function alloc(g, num_trials)
% function alloc(g, num_trials)
%
% Alloc method for class gameHIDData.
%
% Input:
%   g          ... the gameHIDData object
%   num_trials ... number of trials to add
%
% Output:
%   squat, but allocates mem for new trials in FIRA.gameHIDData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.gameHIDData is just an nx1 cell array
FIRA.gameHIDData = cat(1, FIRA.gameHIDData, cell(num_trials, 1));
