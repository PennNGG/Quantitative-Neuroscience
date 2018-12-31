function [fits_, sems_, SSE_] = leastSquaresFit(ys, xs, fun, inits, lbs, ubs)
% function [fits_, sems_, SSE_] = leastSquaresFit(ys, xs, fun, inits, lbs, ubs)
%
% Least-squares fitting using fmincon
%
% Arguments:
%   ys:     observations
%   xs:     indpendent variables
%   fun:    pointer to matlab function that computes the value of the function
%               you are fitting as a function of xs and the current values of
%               the fit parameters.
%   inits:  initial values of the fit parameters
%   lbs:    lower bounds of fit parameters (for fmincon)
%   ubs:    upper bounds of the fit parameters (for fmincon)
%
% Returns:
%   fits_:  best-fitting values of the fit parameters
%   sems_:  numerical estimates of standard errors of the fits
%   SSE_:   final sum-squared error of the fit
%
% Created 09/2017 by Joshua I Gold
%   University of Pennsylvania

% lower bounds
if nargin < 5 || isempty(lbs)
    lbs = -inf.*ones(size(inits));
end

% upper bounds
if nargin < 6 || isempty(lbs)
    ubs = inf.*ones(size(inits));
end

% the error function: SSE
errF = @(fits,ys,xs,fun) sum((ys - feval(fun, fits, xs)).^2);

% Do the fit using fmincon
[fits_,SSE_,~,~,~,~,H]=fmincon(errF,inits,...
    [],[],[],[],lbs,ubs,[], ...
    optimset('Display', 'off', 'Diagnostics', 'off'), ... % 'algorithm', 'active-set', 
    ys,xs,fun);

% compute sems from Hessian
sems_ = sqrt(diag(-((-H)^(-1))));

