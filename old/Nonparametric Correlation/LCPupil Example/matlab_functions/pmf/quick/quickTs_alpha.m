function [fun_, A0_, tin_] = quickTs_alpha(index)
% function [fun_, A0_, tin_] = quickTs_alpha(index)
%
% Returns:
%       fun_    ... inline function
%       A0_     ... [init min max] x param
%       tin_    ... flag, whether T is an arg to fun_

if nargin < 1 || isempty(index)
    index = 1;
end

switch index
    
    case 1
        
        expr  = 'A(1)';
        A0_   = [ ...
            20 0.001 100];
        
    case 2
        
        expr  = '1./(A(1).*T.^A(2))';
        A0_   = [ ...
            0.05 0.0001 10; ...
            0.8  -5      5];
        
    case 3
        
        expr  = 'A(1) + A(2).*exp(-T./A(3))';
        A0_   = [ ...
            20   0.01 100; ...
            40   0.01 100; ...
             0.2 0.01 10];
        
end

if size(symvar(expr), 1) == 1
    
    fun_ = inline(expr, 'T', 'A');
    tin_ = true;
    
else
    
    fun_ = inline(expr, 'A');
    tin_ = false;
end
