function spm001(func)
% function spm001(func)
%
% File describing how to interpret data for FIRA
% Use input argument "func" to switch functions:
%   'init'      ... fills FIRA.spm
%   'trial'     ... parse current trial (in FIRA.raw.trial)
%   'cleanup'   ... whatever you need to do at the end
%
% Returns:
%   nada, but can change FIRA

% created by jig 11/17/04

% we read/change FIRA
global FIRA

%% if called with empty FIRA.spm, fill it and return
if strcmp(func, 'init')
    
    % FIRA.spm is a struct with fields corresponding to "dataTypes"
    % that have values that are argument lists to the given dataType
    % constructor method (empty means use defaults).
    % (or, if you prefer, an nx2 cell array, with the first column corresponding
    % to the fieldnames, the second to the arglist.)
    %
    % Thus, to create FIRA with dataType "ecodes" including a list of 
    % computed values called "one" and "two", use:
    % spm.ecodes = {'compute', {'one' 'value'; 'two' 'value}}
    %
    % buildFIRA_init then converts these descriptors into actual dataType
    % objects used to parse data. Note that the arglists to buildFIRA_init
    % can override the choices of dataTypes here (so you can use the same
    % base spm file to create different FIRAs)
    %
    % see FIRA/build/dataTypes for possible dataTypes
    %     FIRA/build/buildFIRA_init.m for details of how the spm struct is
    %       used 
    FIRA.spm = struct( ...
        'trial',  ...
        {{'startcd', 1005}}, ...
        'ecodes', ...
        {{'extract', {   ...  % values to extract & save in FIRA{2}: <name> <type> <method> <args>
            'trg_on'    'time'     @getEC_time      [TARGC1CD 1]; ...
        'compute', { ...            % names/types of fields to compute & save later in FIRA{2}
        'trg1_dir'    'value'; ...  % direction of correct target
        }, ...
        'tmp', { ...  % values to extract & use temporarily: <name> <type> <method> <args>
        }}}, ...
        'matCmds', [], ...
        'spikes',  [], ...
        'analog',  []);
    return
    
% parse the trial ... 
elseif strcmp(func, 'trial')
    
% cleanup
else
    
end
