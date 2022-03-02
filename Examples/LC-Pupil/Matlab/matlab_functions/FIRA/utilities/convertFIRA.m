function convertFIRA
% function convertFIRA
%
% converts from old-style (cell array) to new-style
% (struct) FIRA
% Makes a lot of assumptions. 

% created 11/04/04 by jig

global FIRA

% save the old one
hd = FIRA{1};
tf = FIRA{2};
tc = FIRA{3};

% make the FIRA structure with appropriate data types
buildFIRA_init([], {'ecodes', 'analog', 'spikes'});

%%
% add header fields
%%%
if isempty(hd.Afile) & ~isempty(hd.Efile)
    FIRA.header.filename = hd.Efile;
elseif ~isempty(hd.Afile) & isempty(hd.Efile)
    FIRA.header.filename = hd.Afile;
elseif strcmp(hd.Afile, hd.Efile)
    FIRA.header.filename = hd.Afile;
else
    FIRA.header.filename = {hd.Afile, hd.Efile};
end
FIRA.header.filetype  = 'convert';
FIRA.header.paradigm  = hd.paradigm;
FIRA.header.spmF      = hd.generator;

% get non-nan rows of ecode matrix
Lt         = find(~isnan(tf(:,1)));
num_trials = length(Lt);

%%%
% add ecode data
%%%
%
% in old FIRA, header.trialfields contained the names/types
%   of ecode data, which included the following fields:
%   1 ... 'trial #'
%   2 ... 'good trial #'
num_cols         = size(hd.trialfields, 2) - 2;
FIRA.ecodes.data = nans(num_trials, num_cols + 4);
% first column is good trial
FIRA.ecodes.data(:,1) = tf(Lt, 2);
% second and third columns are begin/end times .. these
%   are not stored explicitly in old-style FIRA, so we
%   just look for the smallest/largest time values
tinds = strmatch('time', hd.trialfields(2,:));
if isempty(tinds)
    FIRA.ecodes.data(:,2) = -inf;
    FIRA.ecodes.data(:,3) = inf;
    FIRA.ecodes.data(:,4) = 0;
else
    FIRA.ecodes.data(:,2) = min(tf(Lt,tinds), [], 2);
    FIRA.ecodes.data(:,3) = max(tf(Lt,tinds), [], 2);
    % funny conditions -- I think at some point I started
    % saving the wrt time explicity, but not always... so check
    % if there's a really big number
    Lavg = nanmean(tf(Lt, tinds)) > 9999;
    if any(Lavg)
        FIRA.ecodes.data(:,4) = tf(Lt, tinds(min(find(Lavg))));
    else
        FIRA.ecodes.data(:,4) = 0;
    end
end
% add the rest of the data
if num_cols > 0
    FIRA.ecodes.name = {FIRA.ecodes.name{:} hd.trialfields{1, 3:end}};
    FIRA.ecodes.type = {FIRA.ecodes.type{:} hd.trialfields{2, 3:end}};
    FIRA.ecodes.data(:, 5:end) = tf(Lt, 3:end);
end

%%%
% add spike data
%%%
%
% use spikes check method to parse spikecd
% should default to keep_spikes = 'all'
check(FIRA.spm.spikes, hd.spikecd(:));
num_spikes = length(FIRA.spikes.id);
if num_spikes

    % get index of raster data in old FIRA
    rind = strmatch('ras', hd.trialcells(2,:));

    % set up the cell array
    FIRA.spikes.data = cell(num_trials, num_spikes);

    % loop through the spikes ... assume they're in the
    %  same order as hd.spikecd
    for i = 1:num_trials
        for j = 1:num_spikes
            FIRA.spikes.data{i,j} = tc{Lt(i),rind}(j);
        end
    end
end

%%%
% add analog data
%%%
%
%
if ~isempty(hd.analog)

    % store header info
    FIRA.analog.name       = hd.analog.titles(:)';
    FIRA.analog.store_rate = hd.analog.store_rates(:)';
    num_sigs               = size(FIRA.analog.name, 2);

    % get index of 'atime' in old FIRA
    aind = strmatch('atim', hd.trialcells(1,:));

    % make the matrix of analog structs
    FIRA.analog.data = struct( ...
        'start_time', cell(num_trials, num_sigs), ...
        'length',     0, ...
        'values',     []);

    % fill it
    for i = 1:num_trials
        for j = 1:num_sigs
            FIRA.analog.data(i,j).start_time = tc{Lt(i), aind};
            FIRA.analog.data(i,j).length     = length(tc{Lt(i), 4+j});
            FIRA.analog.data(i,j).values     = tc{Lt(i), 4+j};
        end
    end
end

