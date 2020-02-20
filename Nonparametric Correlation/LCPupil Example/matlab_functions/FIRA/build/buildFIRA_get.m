function val_ = buildFIRA_get(dataType, property)
% function buildFIRA_get(dataType, property)
%
% Gets the value of the named property from the named
%   dataType (in FIRA.spm) using the class' get method
%
% Arguments:
%   DataType ... data type in FIRA.spm
%   property ... string name of class (struct) field
% 
% Returns:
%   val_ ... the value returned by the "get" method

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

val_ = get(FIRA.spm.(dataType), property);
