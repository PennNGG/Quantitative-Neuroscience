function alloc(d_, num_trials)
% function alloc(d_, num_trials)
%
% Alloc method for class dio (Digital I/O).
%
% Input:
%   d_         ... the dio object
%   num_trials ... number of trials to add
%
% Output:
%   nada, but allocates mem for new trials in FIRA.dio

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.dio is just an nx1 cell array
FIRA.dio = cat(1, FIRA.dio, cell(num_trials, 1));
