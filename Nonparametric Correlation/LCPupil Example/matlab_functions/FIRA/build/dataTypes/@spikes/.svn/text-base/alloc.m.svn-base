function alloc(s_, num_trials)
% function alloc(s_, num_trials)
%
% Alloc method for class spikes.
%
% Input:
%   s_         ... the spikes object
%   num_trials ... if given, the number of trials to alloc;
%                       otherwise just alloc a single trial
%
% Output:
%   nada, but allocates mem for new trials in FIRA.spikes

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

% check number of spike channels
global FIRA

if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

if ~isempty(FIRA.spikes) && ~isempty(FIRA.spikes.id)
    FIRA.spikes.data = cat(1, FIRA.spikes.data, ...
        cell(num_trials, size(FIRA.spikes.id, 2)));
end
