function purge(d)
% function purge(d)
%
% Purge method for class dio (Digital I/O). Purges
%   dio data from FIRA
%
% Input:
%   d ... the dio object
%
% Output:
%   nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% purge data from FIRA.ecodes
FIRA.dio = {};

% purge data from FIRA.raw.ecodes
if isfield(FIRA, 'raw')
    FIRA.raw.dio = [];
end
