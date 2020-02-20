function [fits_, sems_, sse_] = getFIT_pwl2(data)
%function [fits_, sems_, sse_] = getFIT_pwl2(data)
%
% Fit piecewise linear function
% (2 pieces, first with non-zero slope, second
%       with zero slope)
%
% data = [xs ys es]
%
% fits_ are frac, m1, y1, y2
%

inits = [0.5 0 1; 0 -1000 1000; 0 -1000 1000];

[fits_,f,e,o,l,g,H]=fmincon('errFIT_pwl2',...
    inits(:,1),[],[],[],[],inits(:,2),inits(:,3),[], ...
    optimset('LargeScale', 'off', 'Display', 'off', 'Diagnostics', 'off'), ...
    data);

if nargout > 1
    sems_ = sqrt(diag(-((-H)^(-1))));
end

if nargout > 2
    sse_  = errFIT_exp1(fits_, data);
end
