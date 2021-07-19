function buildFIRA_purge
% function buildFIRA_purge
%
% Calls dataType purge methods to purge (clear)
% data from FIRA
%
% Arguments:
%   nada
%
% Returns:
%   nada

% Copyright 2004 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% loop through the dataTypes
for fn = fieldnames(FIRA.spm)'
    purge(FIRA.spm.(fn{:}));
end
