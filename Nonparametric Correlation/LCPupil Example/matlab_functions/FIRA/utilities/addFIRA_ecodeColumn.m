function addFIRA_ecodeColumn(name, type)
% function addFIRA_ecodeColumn(name, type)
%
% utility for adding a new column to the existing FIRA
%   struct
%

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

if isempty(FIRA) || nargin < 1
    return
end

if nargin < 2
    type = 'value';
end

% make ecodes array, if necessary
if ~isfield(FIRA, 'spm') || ~isfield(FIRA.spm, 'ecodes')
    FIRA.spm.ecodes = [];    
    ecodes;
end

% easy-peasy
if isempty(strmatch(name, FIRA.ecodes.name))
    FIRA.spm.ecodes = set(FIRA.spm.ecodes, 'compute', {name, type});
end