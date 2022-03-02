function [fits_, sems_, sse_] = getFIT_sf(data)
% function fits_ = getFIT_sf(data)
%
% Fit Stromeyer-Foley function (see Klein 2001)
%   d-prime versus stimulus strength
%
% d'(x_t) = x_t^b / (a + (1 - a) * x_t ^ (b + w - 1)
%
% x_t is stimulus strength in threshold units
% fit parameters:
%   a ... ensures that d'=1 at threshold
%   b ... log-log slope at low stimulus strength (near-threshold
%               facilitation)
%   w ... log-log slope at high stimulus strength

inits = [0.6 0 1; 2 0 10; 0.6 0 10];

% fits, sems from non-linear regression (correct trials), coh*time
[fits_,f,e,o,l,g,H]=fmincon('errFIT_sf',...
    inits(:,1),[],[],[],[],inits(:,2),inits(:,3),[], ...
    optimset('LargeScale', 'off', 'Display', 'off', 'Diagnostics', 'off'), ...
    data);

if nargout > 1
    sems_ = sqrt(diag(-((-H)^(-1))));
end

if nargout > 2
    sse_  = errFEF_powFit(fits_, dat, fns);
end
