function buildFIRA_addTrial(varargin)
% function buildFIRA_addTrial(varargin)
%
% Calls dataType-specific addTrial methods to add data
%   from a new trial to FIRA. Allows data to be added
%   directly to FIRA.(dataType) fields, as opposed to
%   storing "raw" data in FIRA.raw that later needs to
%   be parsed. The down-side is that the format of the given
%   data must be quite specific & there isn't much (any)
%   error checking
%
% Arguments:
%   varargin ... list of <dataType> <data> pairs, where
%                   <dataType> is a string
%                   <data> is a cell array
%
% Returns:
%   nada

% Copyright 2004 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% no args is signal to make sure FIRA exists
% and to make next trial
if ~nargin || strcmp(varargin{1}, 'add')

    % init FIRA
    if isempty(FIRA)
        buildFIRA_init;
        FIRA.header.filename = 'auto';
        FIRA.header.filetype = 'addTrial';
    end

    % alloc the next trial
    buildFIRA_alloc(1);

    if nargin < 2
        % outta
        return
    else
        % remove keyword 'add' from arglist
        varargin(1) = [];
    end
end

% loop through the arglist, adding data to the given dataType
for i = 1:2:size(varargin, 2)
    
    % check that data field exists ...
    if ~isfield(FIRA.spm, varargin{i})

        % if not, make it, don't create "raw" fields
        FIRA.spm.(varargin{1}) = feval(varargin{i}, 'raw', false);

    end

    % add trial data
     addTrial(FIRA.spm.(varargin{i}), varargin{i+1}{:});

end