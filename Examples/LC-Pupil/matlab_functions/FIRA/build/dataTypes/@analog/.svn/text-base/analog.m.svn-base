function an_ = analog(varargin)
% function analog(varargin)
%
% Constructor method for class analog
%
% Input:
%   varargin    ... optional property value pairs
%                   also looks in FIRA.spm.analog for
%                       optional list of property/value pairs
%
% Output:
%   an_, the created object, which should be stored
%       in FIRA.spm
%   Also creates (in set method):
%       FIRA.analog
%       FIRA.raw.analog

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make the analog struct
an = struct( ...
    'keep_sigs',     'all',  ... % 'all' or list of channel numbers
    'names',         [],     ... % override names of analog channels
    'acquire_rates', [],     ... % override of acquire rates
    'resample',      [],     ... % possibly new sample rates {'channel' <sr>; ...}
    'channel_order', [],     ... % for Plexon data
    'raw',           true);      % for Plexon data

if isempty(FIRA)
    an_ = class(an, 'analog');
    return
end

% check FIRA.spm.analog, varargin for args
if isfield(FIRA.spm, 'analog') && iscell(FIRA.spm.analog)
    varargin = cat(2, FIRA.spm.analog, varargin);
end

% loop through the args
for i = 1:2:size(varargin, 2)
    an.(varargin{i}) = varargin{i+1};
end

% check sigs
if isempty(an.keep_sigs)

    % if no analog given, save nothing...
    an_ = [];

else

    % make sure the kept_sigs channels are legit and sorted
    if isnumeric(an.keep_sigs)
        an.keep_sigs = sort(unique(an.keep_sigs(an.keep_sigs>=0 & an.keep_sigs<=16)));
    end

    % conditionally make FIRA.raw.analog
    if an.raw
        FIRA.raw.analog = struct( ...
            'func',     [], ...
            'params',   [], ...
            'data',     []);
    end

    % make FIRA.analog
    FIRA.analog = struct(     ...
        'name',         {{}}, ... % 1xn" cell array of strings
        'acquire_rate', [],   ... % 1xn array of #'s, in Hz 
        'store_rate',   [],   ... % 1xn" array of #'s, in Hz
        'error',        {{}}, ... % mx1  array of error messages
        'data',         []);      % mxn" cell array
    
    % conditionally fill names
    if ~isempty(an.names)
        FIRA.analog.name = an.names;
    end

    % conditionally fill store & acquire rates
    if ~isempty(an.names)        
        if size(an.acquire_rates, 2) == size(an.names, 2)
            % unique acquire rates given for each channel
            FIRA.analog.acquire_rate = an.acquire_rates;
        elseif ~isempty(an.acquire_rates)
            % use first acquire rate for every channel            
            FIRA.analog.acquire_rate = repmat(an.acquire_rates(1), size(an.names));
        end
        
        % set store rates to aquire rates
        FIRA.analog.store_rate = FIRA.analog.acquire_rate;
        
        % possibly override store rates
        if ~isempty(an.resample)
            for rr = 1:size(an.resample, 1)
                Lr = strcmp(an.resample{rr,1}, an.names);
                if sum(Lr) == 1 && isfinite(resample{rr,2})
                    FIRA.analog.store_rate(Lr) = an.resample{rr,2};
                end
            end
        end
    end
    
    % create object
    an_ = class(an, 'analog');
end
