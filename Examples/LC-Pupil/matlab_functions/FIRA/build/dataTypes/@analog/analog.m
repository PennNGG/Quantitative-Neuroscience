function an_ = analog(varargin)
% function an_ = analog(varargin)
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

names = { ...
    'LFP01' ...
    'LFP02' ...
    'LFP03' ...
    'LFP04' ...
    'LFP05' ...
    'LFP06' ...
    'LFP07' ...
    'LFP08' ...
    'LFP09' ...
    'LFP10' ...
    'LFP11' ...
    'LFP12' ...
    'LFP13' ...
    'LFP14' ...
    'horiz_eye' ...
    'vert_eye'};

% make the analog struct
an = struct( ...
    'keep_sigs',     'all',  ... % 'all' or list of signal numbers
    'names',         {names},... % names of analog channels .. filled in last->first
    'new_names',     [],     ... % {<index> <name>; ...}
    'gain',          10.2,   ... % set in Rex
    'acquire_rates', [],     ... % override of acquire rates
    'resample',      [],     ... % possibly new sample rates {'channel' <sr>; ...}
    'reoffset',      [],     ... % possibly new offset {'channel' <offset>; ...}
    'rezero',        [],     ... % possibly new zero points (offsets): {'channel' <ecode_time> <ecode_value>; ...}
    'rezero_samples',10,     ... % number of samples used for re-zeroing (see analog/parse)
    'regain',        [],     ... % possibly new gains {'channel' gain; ...}
    'sac_dmin',      1,      ... % minimum distance of a saccade (deg)
    'sac_vpmin',     0.12,   ... % minimum peak velocity of a saccade (deg/ms)
    'sac_vimin',     0.04,   ... % minimum instantaneous velocity of a saccade (deg/ms)
    'sac_amin',      0.005,  ... % minimum instantaneous acceleration of a saccade (deg/ms/ms)
    'sac_smoothhw',  4,      ... % smoothing function size is hw*2+1
    'sac_smoothstd', 1.33,   ... % STD of smoothing function
    'sac_smooth',    [],     ... % smoothing function
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

    % check names
    if ~isempty(an.new_names)
        for nn = 1:size(an.new_names,1)
            an.names{an.new_names{nn,1}} = an.new_names{nn,2};
        end
        an.new_names = [];
    end   
    
    % make sure the kept_sigs channels are legit and sorted
    if isnumeric(an.keep_sigs)
        % an.keep_sigs = sort(unique(an.keep_sigs(an.keep_sigs>=0 & an.keep_sigs<=16))); % original setting for plexon files
        % Alpha-omega use ch 17+ for external analog signals, here we use
        % 17 and 18 for eye signals. Long Ding 9/4/2015
        % added two more analog channels. Long Ding 12/12/2016
        an.keep_sigs = sort(unique(an.keep_sigs(an.keep_sigs>=0 & an.keep_sigs<=20))); 
    end
    
    % make smoothing function
    if ~isempty(an.sac_smoothhw)
        sm = normpdf(1:(an.sac_smoothhw*2+1), an.sac_smoothhw+1, an.sac_smoothhw);
        an.sac_smooth = sm./sum(sm);
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
        'name',         {{}}, ... % 1xn cell array of strings
        'acquire_rate', [],   ... % 1xn array of #'s, in Hz
        'store_rate',   [],   ... % 1xn array of #'s, in Hz
        'gain',         [],   ... % 1xn array of #'s
        'offset',       [],   ... % 1xn array of #'s
        'zero',         [],   ... % list of ecodes used as re-zero points
        'error',        {{}}, ... % mx1  array of error messages
        'data',         []);      % mxn" cell array
    
    % conditionally fill names
    if ~isempty(an.names)
        FIRA.analog.name = an.names(an.keep_sigs);
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
                if sum(Lr) == 1 && isfinite(an.resample{rr,2})
                    FIRA.analog.store_rate(Lr) = an.resample{rr,2};
                end
            end
        end
    end
    
    % create object
    an_ = class(an, 'analog');
end
