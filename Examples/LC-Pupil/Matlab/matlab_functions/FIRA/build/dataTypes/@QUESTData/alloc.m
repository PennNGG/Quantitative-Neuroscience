function alloc(q, num_trials)
% function alloc(q, num_trials)
%
% Alloc method for class QUESTData.
%
% Input:
%   q          ... the QUESTData object
%   num_trials ... number of trials to add
%
% Output:
%   nada, but allocates mem for new trials in FIRA.QUESTData

% Copyright 2007 by Benjamin Heasly
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.QUESTData is just an nx1 cell array
FIRA.QUESTData = cat(1, FIRA.QUESTData, cell(num_trials, 1));