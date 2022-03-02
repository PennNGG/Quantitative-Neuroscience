function alloc(m_, num_trials)
% function alloc(m_, num_trials)
%
% Alloc method for class matCmds
%   (Matlab Commands, typically controlling
%       the visual display)
%
% Input:
%   m_          ... the matCmds object
%   num_trials  ... if given, the number of trials to alloc;
%                       otherwise just alloc a single trial
%
% Output:
%   nada, but allocates mem for new trials in FIRA.matCmds

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% FIRA.matCmds is just an nx1 cell array
FIRA.matCmds = cat(1, FIRA.matCmds, cell(num_trials, 1));
