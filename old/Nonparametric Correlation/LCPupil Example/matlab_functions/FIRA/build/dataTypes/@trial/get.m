function val_ = get(t, property)
% function val_ = get(t, property)
%
% Get method for class trial
%
% Input:
%   t        ... the trial object
%   property ... string name of property to return
%
% Output:
%   val_ ... value of the named property

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

val_ = t.(property);
