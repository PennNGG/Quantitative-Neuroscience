function column_ = getFIRA_ecodeColumnByName(name, type)
% function column_ = getFIRA_ecodeColumnByName(name, type)
%
% gets the column number from FIRA that matches the name and type.
% the 'type' argument is recommended but is only essential if the 'name'
% appears in more than one trial field.  
% names: 'sid' 'correct' 'stim'  etc
% types: 'id' 'value' 'time'
% 

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

% updated 11/06/04 by jig
% 9/9/98 mns added error checks

global FIRA

if nargin < 2 || isempty(type)
    
    % Get first occurrance
    column_ = find(strcmp(name, FIRA.ecodes.name), 1);
else
    % find name only in given "type" list
    column_ = find(strcmp(name, FIRA.ecodes.name) & ...
        strcmp(type, FIRA.ecodes.type), 1);
end
