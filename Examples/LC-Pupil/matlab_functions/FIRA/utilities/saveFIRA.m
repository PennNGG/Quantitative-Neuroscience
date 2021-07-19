function saveFIRA(filename)
% function saveFIRA(filename)
%
% Saves a copy of FIRA called "data" into
%   the given file. Ignores field FIRA.raw

% created 11/05/04 by jig
%
% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

data = FIRA;
if isfield(data, 'raw')
    data = rmfield(data, 'raw');
end

save(filename, 'data');
