function col_ = getFIRA_ecc(name)
% function col_ = getFIRA_ecc(name)
%
% Utility function for getting the column
%   index

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% get data, no error checking
if ischar(name)
    col_ = find(strcmp(name, FIRA.ecodes.name));

elseif iscell(name)
    col_ = zeros(size(name));
    for ii = 1:length(name)
        col_(ii) = find(strcmp(name{ii}, FIRA.ecodes.name));
    end
end
