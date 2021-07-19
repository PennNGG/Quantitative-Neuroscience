function val_ = get(e, property)
% function val_ = get(e, property)
%
% Get method for class ecodes
%
% Input:
%   e        ... the ecodes object
%   property ... string name of property to return
%
% Output:
%   val_ ... value of the named property

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

val_ = e.(property);
