function spmSpikes(func)
% function spmSpikes(func)
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

% created by jig 03/05/12
try
    global FIRA
    % declareEC_ecodes_RKcmd;


    %% if called with empty FIRA.spm, fill it and return
    if strcmp(func, 'init')

        % useful ecode markers for tagged ecodes
        cb = 7000;
        cm = 6000;
        cx = 8000;

        % FIRA.spm is a struct with fields corresponding to "dataTypes"
        % that have values that are argument lists to the given dataType
        % constructor method (empty means use defaults).
        % (or, if you prefer, an nx2 cell array, with the first column
        % corresponding to the fieldnames, the second to the arglist.)
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
            'trial',  {{ ...
            }}, ...
            'ecodes', {{  ...
            'extract', {   ...  % values to extract & save in FIRA{2}: <name> <type> <method> <args>
            }, ...
            'compute', { ...                % names/types of fields to compute & save later in FIRA{2}
            }, ...
            'tmp', { ...  % values to extract & use temporarily: <name> <type> <method> <args>
            }}}, ...
            'spikes',  [], ...
            'analog',  []);

        % parse the trial ... check whether anything is given in FIRA.trial
    elseif strcmp(func, 'trial')


        % %cleanup
    else


    end

catch
    evalin('base', 'e=lasterror')
end