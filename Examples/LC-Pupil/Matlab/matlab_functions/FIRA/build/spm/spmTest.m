function spm(func)
% function spm(func)
%
% File describing how to interpret data for FIRA
% Use input argument "func" to switch functions:
%   'init'      ... fills FIRA.spm
%   'trial'     ... parse current trial (in FIRA.trial)
%   'cleanup'   ... whatever you need to do at the end
%
% Returns:
%   nada, but can change FIRA
%

% created by jig 11/17/04

% we read/change FIRA
global FIRA

%% if called with empty FIRA.spm, fill it and return
if strcmp(func, 'init')
    
    % headerS_ is a big structure containing information defining
    % how to make a FIRA structure from the data
    FIRA.spm = struct( ...
        'startcd', [],          ...  % startcd, delimits trial
        'anycd',   [],          ...  % need to find ANY of these for a good trial
        'allcd',   [],          ...  % need to find ALL of these for a good trial
        'nocd',    [],          ...  % need to find NONE of these for a good trial
        'tminmax', [-1000 inf], ...  % min/max times to save for spikes/analog
        'wrt',     {{}},        ...  % timecode others are wrt
        'extract', {{           ...  % values to extract & save in FIRA{2}: <name> <type> <method> <args>
        }}, ...
        'compute', {{           ...  % names/types of fields to compute & save later in FIRA{2}
        }}, ...
        'tmp',    {{            ...  % values to extract & use temporarily: <name> <type> <method> <args>
        }});
    
    return
    
% parse the trial ... 
elseif strcmp(func, 'trial')
    
% cleanup
else
    
end
