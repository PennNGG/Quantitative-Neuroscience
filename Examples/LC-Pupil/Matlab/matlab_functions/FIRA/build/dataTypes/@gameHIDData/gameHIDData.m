function g_ = gameHIDData(varargin)
% function g_ = gameHIDData(varargin)
%
% Constructor method for class gameHIDData.
%   just makes FIRA.gameHIDData
%
% Input:
%   varargin ... ignored
%
% Output:
%   g_  ... the created gameHIDData object, to be stored
%               in FIRA.spm.gameHIDData
%   Also creates
%       FIRA.gameHIDData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make (empty) struct
g = struct('raw', false);

if ~isempty(FIRA)

    % make FIRA.kbdData
    FIRA.gameHIDData = {};
end

% struct is empty so don't even bother checking for args
g_ = class(g, 'gameHIDData');
