function purge(a)
% function purge(a)
%
% Purge method for class analog. Purges
%   analog data from FIRA
%
% Input:
%   a ... the analog object
%
% Output:
%   nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% purge data from FIRA.analog
FIRA.analog.data = [];

% purge data from FIRA.raw.analog
if isfield(FIRA, 'raw')
    FIRA.raw.analog.data = [];
end
