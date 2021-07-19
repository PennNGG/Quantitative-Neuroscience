function [fits_, sems_, sse_] = getFIT_exp1(data, inits)
% function fits_ = getFIT_sf(data)
%
% Fit single exponential
%
% data = [xs ys es]
%

if nargin < 2 || isempty(inits)
    inits = [100 1 5000; 1 0 2; 1 0.01 2];
end

[fits_,f,e,o,l,g,H]=fmincon('errFIT_exp1',...
    inits(:,1),[],[],[],[],inits(:,2),inits(:,3),[], ...
    optimset('algorithm', 'active-set', 'Display', 'off', 'Diagnostics', 'off'), ...
    data);

if nargout > 1
    sems_ = sqrt(diag(-((-H)^(-1))));
end

if nargout > 2
    sse_  = errFIT_exp1(fits_, data);
end
