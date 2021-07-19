function alloc(p, num_trials)
% function alloc(p, num_trials)
%
% Alloc method for class PMDHIDData.
%
% Input:
%   p          ... the PMDHIDData object
%   num_trials ... number of trials to add
%
% Output:
%   squat, but allocates mem for new trials in FIRA.PMDHIDData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.PMDHIDData is just an nx1 cell array
FIRA.PMDHIDData = cat(1, FIRA.PMDHIDData, cell(num_trials, 1));