function purge(gc)
% function purge(gc)
%
% Purge method for class genericCell. Purges
%   genericCell data from FIRA
%
% Input:
%   gc ... the genericCell object
%
% Output:
%   nada

% Copyright 2010 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% purge FIRA.genericCell
FIRA.genericCell = {};

% purge FIRA.raw.genericCell
if isfield(FIRA, 'raw')
    FIRA.raw.genericCell = [];
end
