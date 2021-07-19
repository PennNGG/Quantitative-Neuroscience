function q_ = QUESTData(varargin)
% function q_ = QUESTData(varargin)
%
% Constructor method for class QUESTData.
%   just makes FIRA.QUESTData
%
% Input:
%   varargin ... ignored
%
% Output:
%   q_  ... the created QUESTData object, to be stored
%               in FIRA.spm.QUESTData
%   Also creates
%       FIRA.QUESTData

% Copyright 2007 by Benjamin Heasly
%   University of Pennsylvania

global FIRA

% make (empty) struct
q = struct('raw', false);

if ~isempty(FIRA)
    % make FIRA.QUESTData
    FIRA.QUESTData = {};
end

% struct is empty so don't even bother checking for args
q_ = class(q, 'QUESTData');
