function val_ = get(s, property)
% function val_ = get(s, property)
%
% Get method for class spikes
%
% Input:
%   s        ... the spikes object
%   property ... string name of property to return
%
% Output:
%   val_ ... value of the named property

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

val_ = s.(property);
