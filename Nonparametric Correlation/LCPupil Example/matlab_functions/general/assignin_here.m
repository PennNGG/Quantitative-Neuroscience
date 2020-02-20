function assignin_here(name, value)
% function assignin_here(name, value)
%
% ooh isn't this clever. A way to assign 
%   the value of a NAMED variable in the
%   CURRENT workspace.

assignin('caller', name, value);
