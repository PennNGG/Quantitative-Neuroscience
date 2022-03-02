function gc_ = genericCell
% function gc_ = genericCell
%
% Constructor method for class genericCell --
%   just a way of having a cell (arbitrary format)
%   of data for each trial
%
% Input:
%   varargin ... optional list of property/value pairs
%                   also looks in FIRA.spm.genericCell for
%                   optional list of property/value pairs
%
% Output:
%   gc_ ... the created genericCell object, to be stored in
%   FIRA.spm.genericCell
%   Also creates:
%       FIRA.genericCell
%       FIRA.raw.genericCell

% Copyright 2010 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

if ~isempty(FIRA)

    % make FIRA.raw.genericCell
    FIRA.raw.genericCell = [];

    % make FIRA.genericCell
    FIRA.genericCell = {};
end

% struct is empty so don't even bother checking for args
gc_ = class(struct('dummy', 0), 'genericCell');
