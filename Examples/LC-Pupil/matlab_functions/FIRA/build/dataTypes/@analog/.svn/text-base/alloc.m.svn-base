function alloc(an, num_trials)
% function alloc(an, num_trials)
%
% Alloc method for class analog.
%
% Input:
%   an          ... the analog object
%   num_trials  ... if given, the number of trials to alloc;
%                       otherwise just alloc a single trial
%
% Output:
%   nada, but allocates mem for new trials in FIRA.analog

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check number of sigs
num_sigs = size(FIRA.analog.name, 2);
if ~num_sigs
    return
end

% check number of trials to add
if nargin < 2 || isempty(num_trials)
    num_trials = 1;
end

% analog data is mxn" array of structs
% each struct has start_time, values
FIRA.analog.data = cat(1, FIRA.analog.data, ...
    struct( ...
    'start_time', nancells(num_trials, num_sigs), ...
    'length',     0, ...
    'values',     []));
