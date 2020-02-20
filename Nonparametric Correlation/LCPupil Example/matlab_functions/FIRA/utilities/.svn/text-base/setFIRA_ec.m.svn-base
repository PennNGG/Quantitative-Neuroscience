function setFIRA_ec(trial, names, values)
% function setFIRA_ec(trial, names, values)
%
% Utility function for setting an ecode

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

if isempty(trial)
    trial = (1:size(FIRA.ecodes.data,1))';
end

% set data, no error checking
if ischar(names)

    % names is char
    if size(values, 2) == 1

        % set named col to value
        FIRA.ecodes.data(trial, strcmp(names, FIRA.ecodes.name)) = values;

    else
        
        % if one name, many values, start at named column
        col = find(strcmp(names, FIRA.ecodes.name));
        FIRA.ecodes.data(trial, col:col+size(values,2)-1) = values;
    end
    
elseif iscell(names)

    % names is cell array of strings
    if length(values) == 1
        for ii = 1:length(names)
            FIRA.ecodes.data(trial, strcmp(names{ii}, FIRA.ecodes.name)) = ...
                values;
        end
    else
        
        for ii = 1:length(names)
            FIRA.ecodes.data(trial, strcmp(names{ii}, FIRA.ecodes.name)) = ...
                values(ii);
        end
    end
end
