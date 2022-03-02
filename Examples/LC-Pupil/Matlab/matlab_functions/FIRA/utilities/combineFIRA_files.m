function combineFIRA_files(fileout, varargin)
% function combineFIRA_files(fileout, varargin)
%
% Still retarded function to combine to spm files.
% Don't expect much.
%

% updated 11/18/04 by jig for new-style FIRA

if nargin < 3
	return
end

global FIRA

% load in the two input files
% (file2 first because the new FIRA will
%   just use the header info from file1)
openFIRA(varargin{1});
if isempty(FIRA)
    error(sprintf('combineFIRA_files: no FIRA found in file <%s>', varargin{1}))
end
tmpFIRA = FIRA;

for ii = 2:size(varargin, 2)

    % open the next file
    openFIRA(varargin{ii});

    % check for data
    if isempty(FIRA)
        error(sprintf('combineFIRA_files: no FIRA found in file <%s>', file1))
    end

    % count number of trials
    num_trials1 = size(tmpFIRA.ecodes.data,  1);
    num_trials2 = size(FIRA.ecodes.data, 1);
    tmpFIRA.header.numTrials  = num_trials1 + num_trials2;

    %%%
    % ECODES
    %%%
    %
    % check that the ecode matrices match
    % we're just checking the sizes, not the actual
    % column names
    if size(tmpFIRA.ecodes.data, 2) ~= size(FIRA.ecodes.data, 2)
        error('combineFIRA_files: different numbers of ecode columns')
    end
    tmpFIRA.ecodes.data = [tmpFIRA.ecodes.data; FIRA.ecodes.data];
    
    %%%
    % SPIKES
    %%%
    %
    % check if there are spikes
    if isfield(tmpFIRA, 'spikes') && isfield(FIRA, 'spikes') && ...
            ~(isempty(tmpFIRA.spikes.id) && isempty(FIRA.spikes.id))

        % might have different units
        [new_ids, id1, id2] = union(tmpFIRA.spikes.id, FIRA.spikes.id);
        [tf, ids1]          = ismember(tmpFIRA.spikes.id, new_ids);
        [tf, ids2]          = ismember(FIRA.spikes.id,    new_ids);

        % update id, channel, unit using id1/id2 (non-overlapping)
        tmpFIRA.spikes.id      = new_ids;
        tmpFIRA.spikes.channel = [tmpFIRA.spikes.channel(id1), FIRA.spikes.channel(id2)];
        tmpFIRA.spikes.unit    = [tmpFIRA.spikes.unit(id1),    FIRA.spikes.unit(id2)];

        % update the data using ids1/ids2 (separate for FIRA and FIRA2)
        data = cell(tmpFIRA.header.numTrials, length(new_ids));
        ids1_inds = 1:length(ids1);
        for i = 1:num_trials1
            data(i, ids1) = tmpFIRA.spikes.data(i, ids1_inds);
        end
        ids2_inds = 1:length(ids2);
        for i = 1:num_trials2
            data(num_trials1+i, ids2) = FIRA.spikes.data(i, ids2_inds);
        end
        tmpFIRA.spikes.data = data;
    end

    %%%
    % ANALOG
    %%%
    %
    % check if there is analog data
    if isfield(tmpFIRA, 'analog') && isfield(FIRA, 'analog') && ...
            ~(isempty(tmpFIRA.analog.name) & isempty(FIRA.analog.name))

        % check store rates
        [L1,L2] = ismember(tmpFIRA.analog.name, FIRA.analog.name);
        if any(tmpFIRA.analog.store_rate(L1) ~= FIRA.analog.store_rate(L2(L2~=0)))
            error('combineFIRA_files: different store rates')
        end

        % might have different channels
        [new_names, n1, n2] = union(tmpFIRA.analog.name, FIRA.analog.name);
        [tf, na1]           = ismember(tmpFIRA.analog.name,  new_names);
        [tf, na2]           = ismember(FIRA.analog.name, new_names);

        % update names, store_rates using id1/id2 (non-overlapping)
        tmpFIRA.analog.name       = new_names;
        tmpFIRA.analog.store_rate = ...
            [tmpFIRA.analog.store_rate(n1), FIRA.analog.store_rate(n2)];

        % update the data using ids1/ids2 (separate for FIRA and FIRA2)
        data = struct( ...
            'start_time', cell(tmpFIRA.header.numTrials, length(new_names)), ...
            'length',     0, ...
            'values',     []);
        for i = 1:num_trials1
            for j = 1:length(na1)
                data(i, j).start_time = tmpFIRA.analog.data(i, na1(j)).start_time;
                data(i, j).length     = tmpFIRA.analog.data(i, na1(j)).length;
                data(i, j).values     = tmpFIRA.analog.data(i, na1(j)).values;
            end
        end
        for i = 1:num_trials2
            for j = 1:length(na2)
                data(num_trials1+i, j).start_time = FIRA.analog.data(i, na2(j)).start_time;
                data(num_trials1+i, j).length     = FIRA.analog.data(i, na2(j)).length;
                data(num_trials1+i, j).values     = FIRA.analog.data(i, na2(j)).values;
            end
        end
        tmpFIRA.analog.data = data;
    end

    %%%
    % MATLAB
    %%%
    %
    % ignore for now

    %%%
    % DIO
    %%%
    %
    % ignore for now
end

% revert to FIRA
FIRA = tmpFIRA;

%%%
% SAVE THE FILE
%%%
%
if ~isempty(fileout)    
    saveFIRA(fileout);
end
