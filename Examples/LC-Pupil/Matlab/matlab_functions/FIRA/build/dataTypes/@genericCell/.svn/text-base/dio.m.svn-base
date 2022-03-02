function d_ = dio
% function d_ = dio
%
% Constructor method for class dio (Digital I/O)
%
% Input:
%   varargin ... optional list of property/value pairs
%                   also looks in FIRA.spm.dio for
%                   optional list of property/value pairs
%
% Output:
%   d_ ... the created dio object, to be stored in FIRA.spm.dio
%   Also creates:
%       FIRA.dio
%       FIRA.raw.dio

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make (non-empty) struct
d = struct('dummy', 0);

if ~isempty(FIRA)

    % make FIRA.raw.dio
    FIRA.raw.dio = [];

    % make FIRA.dio
    FIRA.dio = {};
end

% struct is empty so don't even bother checking for args
d_ = class(d, 'dio');
