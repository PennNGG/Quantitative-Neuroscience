function purge(s)
% function purge(s)
%
% Purge method for class spikes. Purges
%   spike data from FIRA
%
% Input:
%   s ... the spikes object
%
% Output:
%   nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% purge data from FIRA.spikes
% behavior depends on whether 'all' spikes
% are considered (purge everything) or specific
% spikes (keep specific references)
if strncmp(s.keep_spikes, 'all', 3)
    FIRA.spikes.channel = [];
    FIRA.spikes.unit    = [];
    FIRA.spikes.id      = [];
end
FIRA.spikes.data = {};

% purge data from FIRA.raw.spikes
if isfield(FIRA, 'raw')
    FIRA.raw.spikes = [];
end
