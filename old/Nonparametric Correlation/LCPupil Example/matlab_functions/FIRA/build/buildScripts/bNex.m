function bNex(file_in, spm, file_out, spike_list, ...
    sig_list, keep_matCmds, keep_dio, flags, messageH)
%function bNex(file_in, spm, file_out, spike_list, ...
%    sig_list, keep_matCmds, keep_dio, flags, messageH)
%
% Convenience function for building FIRA from a Nex file

if nargin < 2
    error('bNex requires at least 2 arguments')
end

if nargin < 3
    file_out = [];
end

if nargin < 4
    spike_list = [];
end

if nargin < 5
    sig_list = [];
end

if nargin < 6 || isempty(keep_matCmds)
    keep_matCmds = false;
end

if nargin < 7 || isempty(keep_dio)
    keep_dio = false;
end

if nargin < 8
    flags = [];
end

if nargin < 9
    messageH = [];
end

% call bFile to do the work
bFile(file_in, 'nex', spm, file_out, spike_list, sig_list, ...
    keep_matCmds, keep_dio, flags, messageH);
