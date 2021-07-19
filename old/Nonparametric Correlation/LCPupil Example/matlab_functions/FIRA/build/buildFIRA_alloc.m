function buildFIRA_alloc(num_trials)
% function buildFIRA_alloc(num_trials)
%
% Calls dataType-specific alloc methods to allocate
%   space in each FIRA.(dataType) for trial data
%
% Arguments:
%   num_trials ... optional argument specifying number of trials
%               to allocate. If not given or empty, alloc methods
%               typically use FIRA.raw.numTrials
%
% Returns:
%   nada

% Copyright 2004 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check
if isempty(FIRA.spm)

    % update the trials count
    if nargin > 0
        FIRA.header.numTrials = FIRA.header.numTrials + num_trials;
    end

    %outta
    return
end

% get fieldnames
fnames = fieldnames(FIRA.spm)';

% if no argument given, call trial alloc method
% to find the total trials available (in ecodes)
if nargin < 1 || isempty(num_trials)
    if isfield(FIRA.raw, 'trial')
        if ~FIRA.raw.trial.num_startcds
            alloc(FIRA.spm.trial);
            fnames = setdiff(fnames, 'trial');
        end
        num_trials = FIRA.raw.trial.num_startcds;
    else
        num_trials = 1;
    end
end

% loop through the data types, calling the alloc method
for fn = fnames
    alloc(FIRA.spm.(fn{:}), num_trials);
end

% update the trials count
FIRA.header.numTrials = FIRA.header.numTrials + num_trials;

