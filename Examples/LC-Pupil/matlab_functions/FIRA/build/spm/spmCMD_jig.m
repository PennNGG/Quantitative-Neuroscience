function spmRKcmd(func)
% function spmRKcmd(func)
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

% created by jig 10/21/04
% modified from Sharath's spm724rg.m
% LD 2-21-2007
% modified from Long's spmLDdots.m
% RK 3-19-2007
global FIRA
declareEC_ecodes_RKcmd;


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
        'startcd', 1005,                             ...
        'anycd',   [EC.CORRECTCD EC.WRONGCD EC.NOCHCD EC.BRFIXCD], ...
        'allcd',   [] ...
        }}, ...
        'ecodes', {{  ...
        'extract', {   ...  % values to extract & save in FIRA{2}: <name> <type> <method> <args>
        'fp_on'      'time'      @getEC_time         {EC.FPONCD      1};   ...
        'fp_set'     'time'      @getEC_time         {EC.FPONCD      inf}; ...
        'fp_off'     'time'      @getEC_time         {EC.FPOFFCD     1};   ...
        'tgt_on'     'time'      @getEC_time         {EC.TRGC1CD     1};   ...
        'cmdon'      'time'      @getEC_time         {EC.CNTRMNDCD   1};   ...
        'fp_x'       'value'     @getEC_tagged       {EC.I_FIXXCD    cb    cm    cx  0.1};   ...
        'fp_y'       'value'     @getEC_tagged       {EC.I_FIXYCD    cb    cm    cx  0.1};   ...
        'tgt_x'      'value'     @getEC_tagged       {EC.I_TRG1XCD   cb    cm    cx  0.1};   ...
        'tgt_y'      'value'     @getEC_tagged       {EC.I_TRG1YCD   cb    cm    cx  0.1};   ...
        'taskid'     'id'        @getEC_tagged       {EC.I_TASKIDCD  cb    cm    cx  1};     ...
        'trialid'    'id'        @getEC_tagged       {EC.I_TRIALIDCD cb    cm    cx  1};     ...
        'corcd'      'id'        @getEC_fromList     {[EC.CORRECTCD, EC.WRONGCD, EC.NOCHCD EC.BRFIXCD]}; ...
        }, ...
        'compute', { ...             % names/types of fields to compute & save later in FIRA{2}
        'task'       'id'; ...       % 0=fixation; 1=saccade; 2=cmd
        'cor_object' 'id'; ...       % 0=fix; 1=target
        'correct'    'id'; ...       % -2=brfix; -1=nc; 0=error; 1=correct
        'choice'     'id'; ...       % which object was chosen:  0=fixation point, 1=target 1, -1=no choice
        'ssd'        'value'; ...    % stop-signal delay
        'fix_time'   'value' ; ...   % time to attain fixation from beginning of trial (first fp_on)
        'sac_lat'    'value' ; ...
        'sac_dur'    'value' ; ...
        'sac_vmax'   'value' ; ...
        'sac_vavg'   'value' ; ...
        'sac_endx'   'value' ; ...
        'sac_endy'   'value' ; ...
        'sac_amp1'   'value' ; ...
        'sac_amp2'   'value' ; ...
        }, ...
        'tmp', { ...  % values to extract & use temporarily: <name> <type> <method> <args>
        }}}, ...
        'spikes',  [], ...
        'analog',  {{ ...
        'resample',  {'horiz_eye', 240; 'vert_eye', 240}, ...
        'rezero',    {'horiz_eye', 'fp_off', 'fp_x'; 'vert_eye', 'fp_off', 'fp_y'}}});

    % parse the trial ... check whether anything is given in FIRA.trial
elseif strcmp(func, 'trial')

    % get this trial index
    tti = FIRA.raw.trial.good_count;

    % find saccades
    [sacs, choice] = getFIRA_saccadesA(tti, {'horiz_eye', 'vert_eye'}, ...
        {'fp_off', 0; 'fp_off', 800}, 1, 80, {'tgt_x' 'tgt_y'}, 4);

    % found a saccade -- save params
    if size(sacs, 1) > 1
        setFIRA_ec(tti, 'sac_lat', sacs(end-1,:));
    end

    % save other stuff
    task    = ceil(getFIRA_ec(tti, 'taskid')./2);
    corobj  = double(isnan(getFIRA_ec(tti, 'cmdon')));
    correct = choice;
    if choice >= 0
        correct = double(corobj==choice);
    else
        correct = choice;
    end
    setFIRA_ec(tti, {'task', 'choice', 'cor_object', 'correct'}, ...
        task, choice, corobj, correct);
     
    % compute stop-signal delay
    if task == 2 && corobj == 0
        setFIRA_ec(tti, 'ssd', diff(getFIRA_ec(tti, {'cmdon' 'fp_off'})));
    end

    %cleanup
else

end
