function ret_ = verify(a, signals, acquire_rates)
% function ret_ = verify(a, signals, acquire_rates)
%
% verify method for class analog
%
% verifies whether the given analog channels
%   are in the "keep_sigs" list, sets up names, etc.
%
% a        ... the analog object
% channels ... list of channel indices (i.e., indices stored in data struct)
% signals  ... list of signal indices
% acquire_rates ... duh

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania
%
% history:
% 11/23/04 written by jig
% 7/19/07 jig added names, etc

global FIRA

% default
if nargin < 2
    ret_ = false;

elseif isempty(a.keep_sigs) || isempty(signals)
    ret_ = false(size(signals));

elseif strcmp(a.keep_sigs, 'all')
    ret_ = true(size(signals));

else % if isnumeric(a.keep_sigs)
    if signals(1) == 1 && sum(signals) == sum(1:signals(end))
        % if given 1...n, return true for keep_sigs
        ret_ = true(size(signals));
        if length(a.keep_sigs) < length(signals)
            ret_(1:(length(signals)-length(a.keep_sigs))) = false;
        end
    else
        ret_ = ismember(signals, a.keep_sigs);
    end
end

% save the result
FIRA.raw.analog.params.kept_sigs = find(ret_);

% check if names, acquire/sample rates have already
%   been added
if ~isempty(FIRA.analog.name) || ~any(ret_)
    return
end

% number of signals (channels) to add
num_sigs = sum(ret_);

% set names to *last* in list first
FIRA.analog.name = a.names(end-num_sigs+1:end);

% conditionally fill store & acquire rates
if nargin < 3 || isempty(acquire_rates)
    if isempty(a.acquire_rates)
        acquire_rates = 1; % dummy
    else
        acquire_rates = a.acquire_rates;
    end
end

if size(acquire_rates, 2) == size(FIRA.analog.name, 2)
    % unique acquire rates given for each channel
    FIRA.analog.acquire_rate = acquire_rates;
else
    % use first acquire rate for every channel
    FIRA.analog.acquire_rate = repmat(acquire_rates(1), size(FIRA.analog.name));
end

% set store rates to aquire rates, then check for overrides
FIRA.analog.store_rate = FIRA.analog.acquire_rate;
if ~isempty(a.resample)
    for ii = 1:size(a.resample, 1)
        Lstr = strcmp(a.resample{ii,1}, FIRA.analog.name);
        if sum(Lstr) == 1 && isfinite(a.resample{ii,2})
            FIRA.analog.store_rate(Lstr) = a.resample{ii,2};
        end
    end
end

% set gain
FIRA.analog.gain = repmat(a.gain, size(FIRA.analog.name));
if ~isempty(a.regain)
    for ii = 1:size(a.regain, 1)
        Lstr = strcmp(a.regain{ii,1}, FIRA.analog.name);
        if sum(Lstr) == 1 && isfinite(a.regain{ii,2})
            FIRA.analog.gain(Lstr) = a.regain{ii,2};
        end
    end
end

% set offset
FIRA.analog.offset = zeros(size(FIRA.analog.name));
if ~isempty(a.reoffset)
    for ii = 1:size(a.reoffset, 1)
        Lstr = strcmp(a.reoffset{ii,1}, FIRA.analog.name);
        if sum(Lstr) == 1 && isfinite(a.reoffset{ii,2})
            FIRA.analog.offset(Lstr) = a.reoffset{ii,2};
        end
    end
end

% set rezero .. based on ecodes
FIRA.analog.zero = cell(2, size(FIRA.analog.name,2));
FIRA.raw.analog.params.rezero_array = [];
if ~isempty(a.rezero) && isfield(FIRA, 'ecodes')
    for ii = 1:size(a.rezero, 1)
        Lstr = strcmp(a.rezero{ii,1}, FIRA.analog.name);
        if sum(Lstr) == 1 && ischar(a.rezero{ii,2})
            FIRA.analog.zero(:, Lstr) = a.rezero(ii,2:3)';
            time_ind = strmatch(a.rezero{ii,2}, FIRA.ecodes.name);
            if isempty(time_ind)
                time_ind = 0;
            end
            val_ind = strmatch(a.rezero{ii,3}, FIRA.ecodes.name);
            if isempty(val_ind)
                val_ind = 0;
            end
            FIRA.raw.analog.params.rezero_array = ...
                cat(2, FIRA.raw.analog.params.rezero_array, [find(Lstr); time_ind; val_ind]);
        end
    end
end
