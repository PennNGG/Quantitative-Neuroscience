function alloc(gc_, num_trials)
% function alloc(gc_, num_trials)
%
% Alloc method for class genericCell
%
% Input:
%   gc_        ... the genericCell object
%   num_trials ... number of trials to add
%
% Output:
%   nada, but allocates mem for new trials in FIRA.genericCell

% Copyright 2010 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.genericCell is just an nx1 cell array
FIRA.genericCell = cat(1, FIRA.genericCell, cell(num_trials, 1));
