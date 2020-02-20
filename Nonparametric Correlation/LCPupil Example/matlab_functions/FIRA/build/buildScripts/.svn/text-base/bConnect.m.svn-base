function bConnect(spm, spike_list, sig_list, ...
    keep_matCmds, keep_dio, flags)
%function bConnect(spm, spike_list, sig_list, ...
%    keep_matCmds, keep_dio, flags)
%
% Convenience function for building FIRA from 
% a connection to the Plexon server.
% Call bConnect_loop afterwards to grab data
%   and fill FIRA

if nargin < 1
    spm = [];
end

% default data types to include
include_list = {'trial', 'ecodes'};

% keep_spikes is list of spike channels/units or keyword 'all' (default)
if nargin < 2
    include_list = {include_list{:}, 'spikes'};
elseif spike_list
    include_list = {include_list{:}, 'spikes', {'keep_spikes', spike_list}};
end

% keep sigs is list of channels or keyword 'all' (default)
if nargin < 3
    include_list = {include_list{:}, 'analog'};
else
    include_list = {include_list{:}, 'analog', {'keep_sigs', sig_list}};
end

% keep_matCmds is just a flag (default false)
if nargin >= 4 && keep_matCmds
    include_list = {include_list{:}, 'matCmds'};
end

if nargin >= 5 && keep_dio
    include_list = {include_list{:}, 'dio'};
end

if nargin < 6
    flags = [];
end

% INIT FIRA
buildFIRA_init(spm, include_list, [], flags);

% call connect reader
connectPLX;