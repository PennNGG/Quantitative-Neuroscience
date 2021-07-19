function lp_ = PMDHIDData(varargin)
% function lp_ = PMDHIDData(varargin)
%
% Constructor method for class PMDHIDData.
%   just makes FIRA.PMDHIDData
%
% Input:
%   varargin ... ignored
%
% Output:
%   lp_  ... the created PMDHIDData object, to be stored
%               in FIRA.spm.PMDHIDData
%   Also creates
%       FIRA.PMDHIDData

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make (empty) struct
p = struct('raw', false);

if ~isempty(FIRA)

    % make FIRA.kbdData
    FIRA.PMDHIDData = {};
end

% struct is empty so don't even bother checking for args
lp_ = class(p, 'PMDHIDData');