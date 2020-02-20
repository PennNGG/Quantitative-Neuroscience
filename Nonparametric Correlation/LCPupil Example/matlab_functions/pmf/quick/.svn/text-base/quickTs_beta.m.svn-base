function [fun_, B0_, tin_] = quickTs_beta(index)
% function [fun_, B0_, tin_] = quickTs_beta(index)
%
%
% Returns:
%       fun_    ... inline function
%       B0_     ... [init min max] x param
%       tin_    ... flag, whether T is an arg to fun_

if nargin < 1 || isempty(index)
    index = 1;
end

switch index
    
    case 1
        
        expr  = 'B(1)';
        B0_   = [ ...
            1.2 0.01 10];
        
    case 2
        
        expr  = 'B(1).*T.^B(2)';
        B0_   = [ ...
            1.2  0.01 10; ...
            0.0 -5     5];
                
end

if size(symvar(expr), 1) == 1
    
    fun_ = inline(expr, 'T', 'B');
    tin_ = true;
    
else
    
    fun_ = inline(expr, 'B');
    tin_ = false;
end
