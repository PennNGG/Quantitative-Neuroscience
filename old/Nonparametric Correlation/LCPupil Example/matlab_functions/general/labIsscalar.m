function [b] = isscalar(x)
% isscalar(x) returns 1 if the size of x is 1 by 1

% 8/1/97 mns wrote it

b = all(size(x)==1);

  
