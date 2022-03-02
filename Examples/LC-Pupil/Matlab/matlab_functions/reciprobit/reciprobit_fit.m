function [fits_, llk_] = reciprobit_fit(rts)
% function [fits_, llk_] = reciprobit_fit(rts)
%
% Fit reciprobit data to LATER model with params:
%   1 ... mean rate of rise
%   2 ... bound height
% 
% Assumes rts is column vector of rts in ms

% use negative reciprocal rts for fits
% Convert to seconds, so fits scale better
rrts = 1000./rts(isfinite(rts));

% Guess using mean, std of reciprocal rts
B0 = 1/std(rrts);
M0 = mean(rrts)*B0;

[fits_, fval] = fmincon(@(x)reciprobit_err(x, rrts), [M0 B0], ...
    [], [], [], [], [.001 .001], [1000 1000], [], ...
    optimset('Algorithm', 'active-set', ...
    'MaxIter', 3000, 'MaxFunEvals', 3000));%, 'Display', 'iter'));

llk_ = -fval;