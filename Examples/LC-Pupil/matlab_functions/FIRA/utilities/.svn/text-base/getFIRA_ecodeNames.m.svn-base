function names_ = getFIRA_ecodeNames(type)
% function names_ = getFIRA_ecodeNames(type)
%
% returns a cell array of (string) names.  
% Argument:
%   type ... type of data ('id', 'value', 'time')
% If no arg is given then all names are returned.

% 11/05/04 update by jig for new FIRA
% 2/7/02 jig updated... check for empty FIRA
% 10/4/98 mns wrote it

global FIRA

% default
names_ = {};

if isempty(FIRA)
    return
end

% if no arg is given the return all names
if nargin < 1 | isempty(type)
    names_ = FIRA.ecodes.name;
    return
end

% if arg given, it's the 'type'...
q = strmatch(type, FIRA.ecodes.type);
if ~isempty(q)
    names_ = FIRA.ecodes.name(q);
end
