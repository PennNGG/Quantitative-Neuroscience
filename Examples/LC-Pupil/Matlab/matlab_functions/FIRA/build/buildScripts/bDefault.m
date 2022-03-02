function bDefault(trials, varargin)
% function bDefault(trials, varargin)
%
% Convenience function for building a default
%   FIRA with "trials" trials and dataTypes specified
%   by varargin

% INIT FIRA
buildFIRA_init([], varargin);

% CONDITIONALLY ALLOC MEM IN FIRA
 if nargin > 1 && ~isempty(trials)
    buildFIRA_alloc(trials);
end
