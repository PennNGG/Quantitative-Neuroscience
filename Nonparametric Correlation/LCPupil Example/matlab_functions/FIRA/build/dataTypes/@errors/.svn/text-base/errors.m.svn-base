function e_ = lpHIDData(varargin)
% function e_ = lpHIDData(varargin)
%
% Constructor method for class errors.
%   just makes FIRA.errors
%
% Input:
%   varargin ...    ignored
%
% Output:
%   e_ ...  the created errors object, to be stored
%           in FIRA.spm.errors
%
%   Also creates
%       FIRA.errors

% Copyright 2007 Benjamin Heasly
%   University of Pennsylvania

global FIRA

% make empty struct
e = struct('raw', false);

if ~isempty(FIRA)
    FIRA.errors = {};
end

% struct is empty so don't even bother checking for args
e_ = class(e, 'errors');
