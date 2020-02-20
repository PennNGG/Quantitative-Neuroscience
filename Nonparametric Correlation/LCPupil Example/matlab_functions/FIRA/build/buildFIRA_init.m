function buildFIRA_init(spm, include_list, exclude_list, flags, messageH)
% function buildFIRA_init(spm, include_list, exclude_list, flags, messageH)
%
% Initialize FIRA, global data structure, with the following fields:
%       FIRA.header
%       FIRA.spm.(dataTypes)    ... holds dataType object
%       FIRA.raw.(dataTypes)    ... raw data (format specific to
%                                       each data type, empty for now, typically
%                                       filled by buildFIRA_read)
%       FIRA.(dataTypes)        ... parsed data (format specific to each
%                                       data type, empty for now, typically
%                                       alloc'd by builFIRA_alloc and filled
%                                       by buildFIRA_parse)
%
% Args determine which data types (see FIRA/build/dataTypes) are included.
% Call parseFIRA_alloc to alloc FIRA.raw.(dataTypes) and FIRA.(dataTypes)
%
% Arguments:
%   The syntax is quite flexible but a little tricky... the basic
%       idea is that spm specifies: 1) dataTypes to include by default,
%       and 2) various non-default properties of each dataType.
%       The following two arguments -- include_list and exclude_list --
%       let you select from that list of dataTypes.
%
%   Include list also can include arguments to send to each
%       data type constructor method, with "override" values
%       for given value, property pairs. Syntax is
%       "<dataTypeName>", {optional list of property, value pairs}, ...
%
%   The idea is that spm usually refers to a file that can be
%       used relatively untouched for all data from a particular paradigm,
%       but the actual data retrieved may depend on the session; thus,
%       the flexibility afforded by the include_list and exclude_list, etc.
%
%   spm can come in several forms:
%       1. the (string) name of an spm file that fills FIRA.spm
%           File should expect the single argument "init", and the given
%           name can be with or without the "spm" prefix (checks both)
%       2. A struct with fields corresponding to "dataTypes"
%           (see FIRA/build/dataTypes for details), each with a value
%           that is an (optional) cell array sent to the type-specific
%           init method as arguments (typically property/value pairs;
%           empty means use defaults)
%       3. A cell array of <dataType>, <arglist> pairs. <arglist>
%           should be a cell array (in fact, if it has length ~= 1 it
%           should be further imbedded in a cell, but that is
%           taken care of automatically)
%
%   flags are optional arguments possibly used by spm (user-specific)
%   messageH is an optional handle to a gui text object for status messages

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA
FIRA = [];

% check args
if nargin < 4
    flags = [];
end
if nargin < 5
    messageH = [];
end

%%%
% HEADER
%%%
FIRA.header = struct( ...
    'filename',         [],             ... % filled in by reader
    'filetype',         [],             ... % filled in by reader
    'paradigm',         [],             ... % filled in by reader
    'subject',          [],             ... % user defined
    'session',          [],             ... % user defined
    'spmF',             [],             ... % ptr to spm (base) func, if used
    'numTrials',        0,              ... % keep track of total trials alloc'd
    'date',             datestr(now),   ...
    'messageH',         messageH,       ... % (optional) handle to gui text object
    'flags',            flags);             % can be used by spm files
FIRA.spm    = [];

%%%
% GET SPM
%%%
% check spm arg ... either name of spm file or struct or cell array
if nargin < 1 || isempty(spm)
    FIRA.header.spmF = [];

elseif isstruct(spm) || iscell(spm)
    FIRA.header.spmF = [];
    FIRA.spm         = spm;

elseif isscalar(spm) || ischar(spm)

    if isscalar(spm)
        spm = int2str(spm);
    end

    % check for "spm" prefix (if only filename given; otherwise
    %   use fullpath as given)
    [path, name] = fileparts(spm);
    if isempty(path) && ~strncmpi(spm, 'spm', 3)
        tries = {fullfile(path, ['spm' name]); spm};
    else
        tries = {spm};
    end
    
    % now try 'em, catching failures
    for i = 1:length(tries)
        failed = false;
        eval([tries{i} '(''init'');'], 'failed = true;');
        if ~failed
            FIRA.header.spmF = str2func(tries{i});
            break
        end
    end

    % be nice
    if failed
        error(sprintf('... could not create FIRA.spm from %s', spm))
    end
end

%%%
% CHECK FIRA.SPM
%%%
% can be a struct with n fields
%   <dataType> = <arglist>
%
% or an (nx2)x1 cell array of <dataType> <arglist>
%   pairs. We'll even be nice and make sure any given
%   arglist is a double cell (which is like a double guitar)
if iscell(FIRA.spm)

    % check args
    for i = 2:2:length(FIRA.spm)
        if iscell(FIRA.spm{i})
            if isempty(FIRA.spm{i})
                FIRA.spm{i} = [];
            elseif length(FIRA.spm{i}) > 1
                FIRA.spm{i} = {FIRA.spm{i}};
            end
        end
    end

    % make struct
    FIRA.spm = struct(FIRA.spm{:});
end

%%%
% PARSE INCLUDED/EXCLUDED DATA TYPES
%%%
% include all types defined in spm.* OR include_list AND NOT exclude_list
% remember that the given include_list can have
% arglists (cell arrays) mixed in
if nargin < 2 || isempty(include_list)
    if isempty(FIRA.spm)
        return
    end
    include_list = fieldnames(FIRA.spm)';
end

while(~isempty(include_list))
    
    % proceed only if not in exclude list and not already made
    if ischar(include_list{1}) && ~any(strcmp(include_list{1}, exclude_list)) && ...
            ~(isfield(FIRA.spm, include_list{1}) && ...
            isa(FIRA.spm.(include_list{1}), include_list{1}))

        %%%
        % ADD FIELDS BASED ON FIRA.SPM
        %%%
        % evaluate each field of FIRA.spm, which is the name of a dataType
        %   class that, when called, typically will create:
        %   FIRA.spm.(name) = the_object
        %   FIRA.raw.(name) = raw data, typically filled by buildFIRA_read
        %   FIRA.(name)     = class-specific data struct, typically created by
        %                       buildFIRA_alloc and filled by buildFIRA_parse
        name = include_list{1};
        
        if size(include_list, 2) > 1 && iscell(include_list{2})

            % eval the named dataType .. stored in FIRA.spm.(*)
            sp = feval(include_list{1}, include_list{2}{:});
            include_list(1:2) = [];
        else
            sp = feval(include_list{1});
            include_list(1) = [];
        end

        % save it
        if isempty(sp)
            if isfield(FIRA.spm, name)
                FIRA.spm = rmfield(FIRA.spm, name);
            end
        else
            FIRA.spm.(name) = sp;
        end
            
    else
        % update include list
        include_list(1) = [];        
    end
end

% remove unused fields from FIRA.spm
for fn = fieldnames(FIRA.spm)'
    if ~isa(FIRA.spm.(fn{:}), fn{:})
        FIRA.spm = rmfield(FIRA.spm, fn{:});
    end
end

% re-order FIRA.spm:
%   1. trial
%   2. ecodes
%   3. everything else
% added 2013/07/30 yl
fn = fieldnames(FIRA.spm);
FIRA.spm = orderfields(FIRA.spm, cat(3-min(size(fn,1),2), ...
    intersect(fn, 'trial'), intersect(fn, 'ecodes'), ...
    setdiff(fn, {'trial', 'ecodes'})));


