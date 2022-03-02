function bFile(file_in, file_type, spm, file_out, spike_list, ...
    sig_list, keep_matCmds, keep_dio, flags, messageH, rawFlag)
%function bFile(file_in, file_type, spm, file_out, spike_list, ...
%    sig_list, keep_matCmds, keep_dio, flags, messageH)
%
% Convenience function for building FIRA from a data file

if nargin < 10
    error('bFile requires 10 arguments')
end

% default data types to include
include_list = {'trial', 'ecodes'};

% keep_spikes is list of spike channels/units or keyword 'all' (default)
if ~isempty(spike_list)
    include_list = [include_list, 'spikes', {{'keep_spikes', spike_list}}];
end

% keep sigs is list of channels or keyword 'all' (default)
if ~isempty(sig_list)
    if iscell(sig_list)
        include_list = [include_list, 'analog', ...
            {{'keep_sigs', sig_list{1}, 'names', sig_list{2}}}];
    else
        include_list = [include_list, 'analog', {{'keep_sigs', sig_list}}];
    end
end

% keep_matCmds is just a flag (default false)
if keep_matCmds
    include_list = [include_list, 'matCmds'];
end

if keep_dio
    include_list = [include_list, 'dio'];
end

% INIT FIRA
buildFIRA_init(spm, include_list, [], flags, messageH);

% READ THE FILE(s)
% either (char) filename or cell array of string names
if ischar(file_in)
    buildFIRA_read(file_in, file_type);
elseif iscell(file_in)
    for ff = 1:length(file_in)
        buildFIRA_read(file_in{ff}, file_type);
    end
end

if nargin < 11 || ~rawFlag

    % ALLOC MEM IN FIRA
    buildFIRA_alloc;
    
    % parse data
    buildFIRA_parse;
    
    % cleanup
    buildFIRA_cleanup(true);
end

% save, if necessary
if ~isempty(file_out)
    saveFIRA(file_out);
end
