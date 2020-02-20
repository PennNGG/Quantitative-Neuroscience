function lp_ = lpHIDData(varargin)
% function lp_ = lpHIDData(varargin)
%
% Constructor method for class kbdData.
%   just makes FIRA.kbdData
%
% Input:
%   varargin ... ignored
%
% Output:
%   lp_  ... the created lpHIDData object, to be stored
%               in FIRA.spm.lpHIDData
%   Also creates
%       FIRA.lpHIDData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make (empty) struct
lp = struct('raw', false);

if ~isempty(FIRA)

    % make FIRA.kbdData
    FIRA.lpHIDData = {};
end

% struct is empty so don't even bother checking for args
lp_ = class(lp, 'lpHIDData');
