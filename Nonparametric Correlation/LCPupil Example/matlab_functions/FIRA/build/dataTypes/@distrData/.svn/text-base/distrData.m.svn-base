function g_ = distrData(varargin)
% function g_ = distrData(varargin)
%
% Constructor method for class distrData.
%   just makes FIRA.distrData
%
% Input:
%   varargin ... ignored
%
% Output:
%   g_  ... the created distrData object, to be stored
%               in FIRA.spm.distrData
%   Also creates
%       FIRA.distrData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make (empty) struct
d = struct('raw', false);

if ~isempty(FIRA)

    % make FIRA.kbdData
    FIRA.distrData = {};
end

% struct is empty so don't even bother checking for args
g_ = class(d, 'distrData');
