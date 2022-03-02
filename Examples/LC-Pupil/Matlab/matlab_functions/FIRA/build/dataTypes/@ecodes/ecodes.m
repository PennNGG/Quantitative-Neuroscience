function ec_ = ecodes(varargin)
% function ec_ = ecodes(varargin)
%
% Constructor method for class ecodes
%
% Input:
%   varargin and FIRA.spm.ecodes are optional lists
%       of property/value pairs (pairs can be listed in any order):
%           'extract', {<name>  <type>  <func_ptr> <varargin>; ...}, ...
%           'tmp',     {<name>  <type>  <func_ptr> <varargin>; ...}, ...
%           'compute', {<name>  <type>; ...}, ...
%           'default', {<name>  <type>; ...}, ...
%
% Output:
%   ec_ ... the created ecodes object, to be stored
%       in FIRA.spm.ecodes
%   Also creates:
%       FIRA.raw.ecodes = []
%       FIRA.ecodes (created by set method)

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% 'default' ecodes
defs = { ...
    'trial_num',    'value';    ...
    'trial_begin',  'time';     ...
    'trial_end',    'time';     ...
    'trial_wrt',    'time'};

% make ecodes struct
ec = struct( ...
    'default',       {defs},        ...
    'num_default',   size(defs, 1), ...
    'extract',       [],            ... % values to extract and save in fira
    'num_extract',   0,             ...
    'time_inds',     [],            ... % inds of extracted ecodes with 'time' values
    'tmp',           [],            ... % values to extract & use temporarily
    'num_tmp',       0,             ...
    'tmp_time_inds', [],            ... % inds of tmp ecodes with 'time' values
    'compute_ind',   0,             ...
    'compute',       {{}},          ... % values to compute later, so need to alloc space
    'num_compute',   0,             ...
    'num_ecodes',    [],            ...
    'raw',           true);           % flag to create raw field

% make and outta if no FIRA
if isempty(FIRA)
    ec_ = class(ec, 'ecodes');
    return
end

% varargin are in FIRA.spm and varargin
if isfield(FIRA.spm, 'ecodes') && iscell(FIRA.spm.ecodes)
    varargin = cat(2, FIRA.spm.ecodes, varargin);
end

% fields for extract, tmp struct arrays
f = {'name', 'type', 'func', 'params'};

% loop through the varargin
for i = 1:2:size(varargin, 2)

    switch varargin{i}

        case {'extract', 'tmp'}
            if isempty(varargin{i+1})   % clear
                ec.(varargin{i}) = [];
            else
                ec.(varargin{i}) = cat(1, ec.(varargin{i}), cell2struct(varargin{i+1}, f, 2));
            end

        case {'compute' 'default'}
            if isempty(varargin{i+1})   % clear
                ec.(varargin{i}) = {};
            else
                ec.(varargin{i}) = cat(1, ec.(varargin{i}), varargin{i+1});
            end
            
        otherwise
            ec.(varargin{i}) = varargin{i+1};
    end
end

% compute sizes
ec.num_extract = size(ec.extract, 1);
ec.num_compute = size(ec.compute, 1);
ec.num_default = size(ec.default, 1);
ec.num_ecodes  = ec.num_extract + ec.num_compute + ec.num_default;
ec.num_tmp     = size(ec.tmp,     1);

% compute inds of extracted ecodes with type = 'time'
% these are precomputed to speed things up a bit in the main
% parse loop when times are automatically extracted and must
% be updated with wrt
if isempty(ec.extract)
    ec.time_inds = [];
else
    ec.time_inds = strmatch('time', {ec.extract.type}, 'exact') + ec.num_default;
end
if isempty(ec.tmp)
    ec.tmp_time_inds = [];
else
    ec.tmp_time_inds = strmatch('time', {ec.tmp.type}, 'exact');
end

% index of first "computed" ecode .. again precompute for speed
ec.compute_ind = ec.num_extract + ec.num_default + 1;

% make it
ec_ = class(ec, 'ecodes');

% conditionally make raw struct
if ec.raw
    FIRA.raw.ecodes = [];
end

% make FIRA.ecodes
FIRA.ecodes = struct( ...
    'name', [], ...
    'type', [], ...
    'data', []);

% need to save ecodes, struct is empty, so create it
% 'name' and 'type' are 1xn cell array of strings
% order of ecodes:
%   default
%   extract
%   compute
if ~isempty(ec.default)
    FIRA.ecodes.name = ec.default(:,1)';
    FIRA.ecodes.type = ec.default(:,2)';
end
if ~isempty(ec.extract)
    FIRA.ecodes.name = cat(2, FIRA.ecodes.name, {ec.extract.name});
    FIRA.ecodes.type = cat(2, FIRA.ecodes.type, {ec.extract.type});
end
if ~isempty(ec.compute)
    FIRA.ecodes.name = cat(2, FIRA.ecodes.name, ec.compute(:,1)');
    FIRA.ecodes.type = cat(2, FIRA.ecodes.type, ec.compute(:,2)');
end
