function k_ = kbdData(varargin)
% function k_ = kbdData(varargin)
%
% Constructor method for class kbdData.
%   just makes FIRA.kbdData
%
% Input:
%   varargin ... ignored
%
% Output:
%   k_  ... the created kbdData object, to be stored
%               in FIRA.spm.kbdData
%   Also creates
%       FIRA.kbdData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make (empty) struct
kb = struct('raw', false);

if ~isempty(FIRA)

    % make FIRA.kbdData
    FIRA.kbdData = {};
end

% struct is empty so don't even bother checking for args
k_ = class(kb, 'kbdData');
