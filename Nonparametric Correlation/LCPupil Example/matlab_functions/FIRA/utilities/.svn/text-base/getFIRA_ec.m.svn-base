function ecs_ = getFIRA_ec(trial, names)
% function ecs_ = getFIRA_ec(trial, names)
%
% Utility function for getting the value 
%   from FIRA.ecodes.data, by name and trial #
%
% names can be string or cell array of strings
%

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

if isempty(trial)
    trial = (1:size(FIRA.ecodes.data, 1))';
elseif islogical(trial)
    trial = find(trial);
end

% get data, no error checking
if ischar(names)
    
    % names is char
    inds = strcmp(names, FIRA.ecodes.name);
    if any(inds)
        ecs_ = FIRA.ecodes.data(trial, inds);
    else
        ecs_ = [];
    end
    
elseif iscell(names)
    
    % names is cell array of strings
    ecs_   = nans(length(trial), length(names));
    for ii = 1:length(names)
        if ~isempty(names{ii}) && any(strcmp(names{ii}, FIRA.ecodes.name))
            ecs_(:, ii) = FIRA.ecodes.data(trial, strcmp(names{ii}, FIRA.ecodes.name));
        end
    end
    
else
    
    ecs_ = [];
end
