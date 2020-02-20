function [Lsb_, uniques_] = selectFIRA_trialsByUniqueID(name, trials)
% function [Lsb_, uniques_] = selectFIRA_trialsByUniqueID(name, trials)
%
% makes a selection matrix based on the unique values
% from an "id" column of FIRA.ecodes.data
%
% Arguments:
%   name     ... name of the ecode column
%   trials   ... (optional) list of trials to choose from
%
% Returns:
%   Lsb_     ... selection matrix, rows are trials, columns
%                   are unique IDs
%   uniques_ ... array of unique IDs used (correspond to columns
%                   of Lsb_)

global FIRA

% checks
if isempty(FIRA) || isempty(FIRA.ecodes.data) 
    Lsb_ = [];
    if nargout == 2
        uniques_ = [];
    end
    return
end
if nargin < 2 || isempty(trials)
    trials = [1:size(FIRA.ecodes.data,1)]';
end
if nargin < 1 || isempty(name) || strcmp(name, 'none')
        Lsb_ = true(length(trials),1);
    if nargout == 2
        uniques_ = 0;
    end
    return
end

% get unique values
col = find(strcmp(name, FIRA.ecodes.name) , 1);
uniques = nonanunique(FIRA.ecodes.data(trials, col));
if isempty(uniques)
    Lsb_ = false(length(trials), 1);
else
    Lsb_ = false(length(trials), length(uniques));
    for i = 1:length(uniques)
        Lsb_(:,i) = FIRA.ecodes.data(trials, col) == uniques(i);
    end
end

% optional second return argument
if nargout == 2
    uniques_ = uniques;
end
