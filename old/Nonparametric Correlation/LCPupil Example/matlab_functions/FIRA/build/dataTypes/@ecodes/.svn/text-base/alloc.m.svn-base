function alloc(e_, num_trials)
% function alloc(e_, num_trials)
%
% Alloc method for class ecodes.
%
% Input:
%   e_          ... the ecodes object
%   num_trials  ... if given, the number of trials to alloc;
%                       otherwise just alloc a single trial
%
% Output:
%   nada, but allocates mem for new trials in FIRA.ecodes

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

% check number of channels
if ~e_.num_ecodes
    return
end

global FIRA

% add trials
if nargin >= 2 && num_trials > 0
    % ecodes data is mxn array

    FIRA.ecodes.data = cat(1, ...
        FIRA.ecodes.data, nans(num_trials, size(FIRA.ecodes.name,2)));
end
