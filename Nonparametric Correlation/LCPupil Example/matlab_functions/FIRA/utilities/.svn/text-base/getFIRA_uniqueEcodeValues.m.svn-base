function ids_ = getFIRA_uniqueEcodeIDs(names)
% function ids_ = getFIRA_uniqueEcodeIDs(names)
%
% given a cell array of FIRA.ecode.type strings,
% returns a cell array, each entry of which is an
% array of unique ids from the given column

% updated 11/05/04 by jig for new FIRA

% yup, it's FIRA-dependent
global FIRA

% check
if isempty(FIRA)
    ids_ = {}; 
    return
end

% Larray is made from all id values
num_names = length(names);
ids_      = cell(num_names, 1);
for i = 1:num_names
    col = getFIRA_ecodeColumnByName(names{i}, 'id');
    if ~isempty(col) & ~isempty(FIRA.ecodes.data)
        ids_{i} = nonanunique(FIRA.ecodes.data(:, col));
    end
end