function a_ = awdData(varargin)
% function a_ = awdData(varargin)
%
% Constructor method for class awdData.
%   just makes FIRA.awdData
%
% Input:
%   varargin ... optional list of property/value pairs
%
% Output:
%   a_ ... the created awdData object, to be stored
%           in FIRA.spm.awData
%   Also creates:
%       FIRA.dio

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make (empty) struct
a = struct('raw', false);

% struct is empty so don't even bother checking for args
a_ = class(a, 'awdData');

if ~isempty(FIRA)

    % make FIRA.awData
    FIRA.awdData = {};
end
