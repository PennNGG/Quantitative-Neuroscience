function purge(e)
% function purge(e)
%
% Purge method for class ecodes. Purges
%   ecode data from FIRA
%
% Input:
%   e ... the ecodes object
%
% Output:
%   nada

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% purge data from FIRA.ecodes
FIRA.ecodes.data = [];

% purge data from FIRA.raw.ecodes
if isfield(FIRA, 'raw')
    FIRA.raw.ecodes = [];
end
