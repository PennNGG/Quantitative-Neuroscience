function error_ = connectPLX(filename)
% function error_ = connectPLX(filename)
%
% Establishes a connection to the Plexon server and fills the
%  FIRA data structure, as follows:
%    FIRA.header.filename ... server id
%    FIRA.header.filetype ... 'connect'
%    FIRA.header.paradigm ... 'connect'
%
%    FIRA.raw.server      ... from PL_initClient -- note this is a new field!
%    FIRA.raw.ecodes      ... []
%    FIRA.raw.spikes      ... []
%    FIRA.raw.afunc       ... @parseNEX_AData
%    FIRA.raw.aparams     ... [] (no parameters needed by parseNEX_AData)
%    FIRA.raw.adata       ... []
%    FIRA.raw.matCs       ... []
%    FIRA.raw.matAs       ... []
%    FIRA.raw.matAi       ... []
%    FIRA.raw.dios        ... []
%
% Arguments:
%   filename  ... ignored
%
% Returns:
%   error_ ... flag
%   also fills appropriate fields of the global FIRA
%

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania
%
% history:
% created 10/14/04 by jig from connectPLX

global FIRA

if ~(strcmp(computer, 'PCWIN') || strcmp(computer, 'PCWIN64'))
    error_ = 1;
    return
end
error_ = 0;

% make the connection & fill FIRA header
FIRA.header.filename = PL_InitClient(0);
if FIRA.header.filename < 1
    error('could not connect to Plexon server');    
end
FIRA.header.filetype = 'connect';
FIRA.header.paradigm = 'connect';

% now set up analog stuff, if necessary
if isfield(FIRA, 'analog')
    
    % set function to parse analog data
    FIRA.raw.analog.func = @parsePLX_aData;

    % set up an index and save the array size
    FIRA.raw.analog.params = struct( ...
        'aind', 1, ...  % index into analog matrix
        'asz',  0, ...  % current size of analog matrix
        'ks',   0);     % list of active channels ("keep sigs")
end
