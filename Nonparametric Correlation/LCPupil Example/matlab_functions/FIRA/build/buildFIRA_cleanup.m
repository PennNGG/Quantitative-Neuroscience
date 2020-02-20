function buildFIRA_cleanup(call_spm)
% function buildFIRA_cleanup(call_spm)
%
%   calls dataType cleanup methods
%
% Argument:
%   call_spm ... flag to force call to spm 'cleanup' routine

% created by jig 11/01/04

global FIRA

% cleanup
for fn = fieldnames(FIRA.spm)'
    cleanup(FIRA.spm.(fn{:}));
end

if nargin > 0 && call_spm && ~isempty(FIRA.header.spmF)
    feval(FIRA.header.spmF, 'cleanup');
end
