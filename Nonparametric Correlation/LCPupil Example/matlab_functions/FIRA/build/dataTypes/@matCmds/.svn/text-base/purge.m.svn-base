function purge(m)
% function purge(m)
%
% Purge method for class matCmds. Purges
%   matCmds data from FIRA
%
% Input:
%   m ... the matCmds object
%
% Output:
%   nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% purge data from FIRA.matCmds
FIRA.matCmds = {};

% purge data from FIRA.raw.matCmds
if isfield(FIRA, 'raw')
    FIRA.raw.matCmds.cmds = [];
    FIRA.raw.matCmds.args = [];
    FIRA.raw.matCmds.ind  = 1;
end
