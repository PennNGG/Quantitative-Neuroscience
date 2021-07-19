function as_ = aslData(varargin)
% function as_ = aslData(varargin)
%
% Constructor method for class aslData.
%   just makes FIRA.aslData
%
% Input:
%   varargin ... ignored
%
% Output:
%   as_  ... the created aslData object, to be stored
%               in FIRA.spm.aslData
%   Also creates
%       FIRA.aslData

% Copyright 2007 by Benjamin Heasly
%   University of Pennsylvania

global FIRA

% make (empty) struct
as = struct('raw', false);

if ~isempty(FIRA)

    % make FIRA.aslData
    FIRA.aslData = {};
end

% struct is empty so don't even bother checking for args
as_ = class(as, 'aslData');
