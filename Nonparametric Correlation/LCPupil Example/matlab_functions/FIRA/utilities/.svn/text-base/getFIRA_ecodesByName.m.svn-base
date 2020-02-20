function ecodes_ = getFIRA_ecodesByName(cname, ctype, trials)
% function ecodes_ = getFIRA_ecodeTimesByName(cname, ctype, trials)
%
% gets an array of ecodes (times, ids, or values) from FIRA.ecodes.data.
%   name and type arguments can be strings or cell arrays
%   of strings
%
% Arguments:
%   cname   ... column name (required)
%   ctype   ... column type ('time', 'id', or 'value') (optional)
%   trials  ... selection array of trials (optional)
%
% Returns:
%   array of ecodes
%

% created 11/18/04 by jig
global FIRA

% check
if nargin < 1 || isempty(cname) || isempty(FIRA) || isempty(FIRA.ecodes.data)
    ecodes_ = [];
    return
end

if iscell(cname)
    col = [];
    if nargin < 2 || isempty(ctype)
        for ii = 1:length(cname)
            col = cat(2, col, find(strcmp(cname{ii}, FIRA.ecodes.name),1));
        end
    elseif iscell(ctype) && length(ctype) == length(cname)
        for ii = 1:length(cname)
            col = cat(2, col, find(strcmp(cname{ii}, FIRA.ecodes.name) & ...
                strcmp(ctype{ii}, FIRA.ecodes.type),1));
        end
    else
        if iscell(ctype)
            ctype = ctype{1};
        end
        for ii = 1:length(cname)
            col = cat(2, col, find(strcmp(cname{ii}, FIRA.ecodes.name) & ...
                strcmp(ctype, FIRA.ecodes.type),1));
        end
    end
else
    if nargin < 2 || isempty(ctype)
        col = find(strcmp(cname, FIRA.ecodes.name),1);
    else
        col = find(strcmp(cname, FIRA.ecodes.name) & ...
            strcmp(ctype, FIRA.ecodes.type),1);
    end
end
   
if ~any(col)
    ecodes_ = [];
    return
end

if nargin < 3 || isempty(trials)
    ecodes_ = FIRA.ecodes.data(:, col);
else
    ecodes_ = FIRA.ecodes.data(trials, col);
end
