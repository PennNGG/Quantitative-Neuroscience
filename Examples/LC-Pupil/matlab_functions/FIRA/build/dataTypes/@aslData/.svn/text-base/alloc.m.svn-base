function alloc(as, num_trials)
% function alloc(as, num_trials)
%
% Alloc method for class aslData.
%
% Input:
%   as         ... the aslData object
%   num_trials ... number of trials to add
%
% Output:
%   nada, but allocates mem for new trials in FIRA.aslData

% Copyright 2007 by Benjamin Heasly
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.aslData is just an nx1 cell array
FIRA.aslData = cat(1, FIRA.aslData, cell(num_trials, 1));
