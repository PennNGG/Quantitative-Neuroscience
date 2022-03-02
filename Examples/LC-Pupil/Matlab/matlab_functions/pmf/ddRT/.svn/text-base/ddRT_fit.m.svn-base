function [Q, Qerr, errVal, exitFlag, outputInfo] = ...
    ddRT_fit(p_err, t_err, data, inits, opt, varargin)
% fit the drift-diffusion model to the given data
%
%   [Q, Qerr] = ddRT_fit(p_err, t_err, data, inits)
%
%   p_err is a function handle for a function that computes some error
%   metric from a set of drift-diffusion model parameters, and some choice
%   data.  It should have the form err = p_err(Q, data).
%
%   t_err is a function handle for a function that computes some error
%   metric from a set of drift-diffusion model parameters, and some
%   response time data. It should have the form err = p_err(Q, data).
%
%   data is an nx3 array of data from n trials:
%       data(:,1) is the sequence of stimulus strengths
%       data(:,2) is the sequence of choices (0 or 1)
%       data(:,3) is the sequence of response times
%
%   inits is a matrix of starting values and constraints for model
%   parameters.  Each row corresponds to an element of Q and has the form
%   [start, min, max].
%
%   Q is a 6-element vector of fitted drift-diffusion parameters:
%
%   Q(1:3) are generic, ideal drift-diffusion parameters:
%       Q(1) is k, the scale factor for stimulus stimulus strength.
%       Q(2) is b (or beta), the exponent of facilitation for stimulus
%       strength.
%       Q(3) is A', the normalized bound height for accumulation (assumes
%       symmetric bounds A'=B');
%
%   Q(4:6) are for accomodating real data:
%       Q(4) is the psychometric lapse rate or upper asymptote.
%       Q(5) is the psychometric guess rate or lower asymptote.
%       Q(6) is tR, the residual, non-decision response time.
%
%   Qerr is a 6x2 array of confidence bounds on the elements of Q.  Each
%   row has the form [low high].
%
%   see also, ddRT_*

% 2008 Benjamin Heasly 2008 University of Pennsylvania

if nargin < 4 || isempty(inits)
    % absurd-possible inits and constraints
    inits = [...
        1,      1e-3    1e3; ...
        1,      1e-3    1e3; ...
        1,      1e-3    1e3; ...
        0.01,   0,      1; ...
        0.5,	0,      1; ...
        1,      0,  	1e3];
end

if nargin < 5 || isempty(opt)
    % basic options
    opt = optimset('LargeScale', 'off', ...
        'Display', 'off', 'Diagnostics', 'off');
end

% make an anonymous function that combines the p and t error functions
errFcn = @(Q, data, varargin) ...
    feval(p_err, Q, data) + feval(t_err, Q, data);

[Q, errVal, exitFlag, outputInfo, lambdaInfo, grad] = fmincon( ...
    errFcn, inits(:,1), [],[],[],[], inits(:,2), inits(:,3), [], opt, ...
    data, varargin{:});

Qerr = nan;