function [fits_, sems_, sse_] = getFIT_exp1U(data)
% function fits_ = getFIT_sf(data)
%
% Fit single exponential
%
% data = [xs ys es]
%

inits = [100 1 5000; 1 0 200; 1 0.01 200];

[fits_,f,e,o,l,g,H]=fmincon('errFIT_exp1U',...
    inits(:,1),[],[],[],[],inits(:,2),inits(:,3),[], ...
    optimset('LargeScale', 'off', 'Display', 'off', 'Diagnostics', 'off'), ...
    data);

if nargout > 1
    sems_ = sqrt(diag(-((-H)^(-1))));
end

if nargout > 2
    sse_  = errFIT_exp1(fits_, data);
end
