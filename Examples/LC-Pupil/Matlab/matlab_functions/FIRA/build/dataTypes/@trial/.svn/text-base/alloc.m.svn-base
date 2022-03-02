function alloc(t, trials)
% function alloc(t, trials)
%
% Alloc method for class trial. Does nothing.
%
% Input:
%   t_      ... the trial object
%   trials  ... ignored
%
% Output:
%   nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

if isfield(FIRA.raw, 'ecodes') && ~isempty(FIRA.raw.ecodes)
    
    % find startcds
    FIRA.raw.trial.startcds       = find(FIRA.raw.ecodes(:,2) == t.startcd);
    FIRA.raw.trial.num_startcds   = size(FIRA.raw.trial.startcds, 1);
    FIRA.raw.trial.startcd_index  = 1;
    
    % add a tail (makes sure the last trial gets parsed ok)
    FIRA.raw.trial.startcds(end+1,1) = size(FIRA.raw.ecodes,1)+1;
end
