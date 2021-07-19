function spm724j(func)
% function spm724(func)
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
% modified by jcl on 9/15/05 to parse universal task

global FIRA
declareEC_ecodes;

%% if called with empty FIRA.spm, fill it and return
if strcmp(func, 'init')
    
    % useful ecode markers
    cb = 7500;
    cm = 7000;
    cx = 7999;

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
        'anycd',   [EC.CORRECTCD EC.WRONGCD EC.NOCHCD EC.FIX1CD], ...
        'allcd',   [] ...
        }}, ...
        'ecodes', {{  ...
        'extract', {   ...  % values to extract & save in FIRA{2}: <name> <type> <method> <args>
            'trg_on'    'time'     @getEC_time      {EC.TARGC1CD 1}; ...
            'trg_off'   'time'     @getEC_time      {EC.TARGC2CD 1}; ...        
            'dot_on'    'time'     @getEC_time      {EC.GOCOHCD  1}; ...
            'dot_off'   'time'     @getEC_time      {EC.STOFFCD  1}; ...
            'fp_off'    'time'     @getEC_time      {EC.FPOFFCD  1}; ...
            'sac_on'    'time'     @getEC_time      {EC.SACMAD   1}; ...
            'all_off'   'time'     @getEC_time      {EC.ALLOFFCD 1}; ...
            'fp_x'      'value'    @getEC_tagged    {EC.I_FIXXCD    cb    cm    cx  0.1};   ...
            'fp_y'      'value'    @getEC_tagged    {EC.I_FIXYCD    cb    cm    cx  0.1};   ...
            't1_x'      'value'    @getEC_tagged    {EC.I_TRG1XCD   cb    cm    cx  0.1};   ...
            't1_y'      'value'    @getEC_tagged    {EC.I_TRG1YCD   cb    cm    cx  0.1};   ...
            't2_x'      'value'    @getEC_tagged    {EC.I_TRG2XCD   cb    cm    cx  0.1};   ...
            't2_y'      'value'    @getEC_tagged    {EC.I_TRG2YCD   cb    cm    cx  0.1};   ...
            'sb'        'value'    @getEC_tagged    {8027   7000  7000  8000};              ...
            'taskcd'    'id'       @getEC_tagged    {EC.I_TRIALIDCD 7000  7000  8000};      ...
            'dot_dir'   'id'       @getEC_tagged    {EC.I_DOTDIRCD  cb    cm    cx  };      ...
            'dot_coh'   'id'       @getEC_tagged    {EC.I_COHCD     7000  7000  8000 0.1};  ...
            'crtcd'     'id'       @getEC_fromList  {[EC.CORRECTCD EC.WRONGCD EC.NOCHCD EC.FIX1CD]}; ...
        }, ...
        'compute', { ...            % names/types of fields to compute & save later in FIRA{2}
        'nv'          'id';    ...  % parse novar trials, 1=nv 0=otherwise
        'task'        'id';    ...  % universal trials
        'correct'     'id';    ...  % 1=correct, 0=error, -1=nc, -2=brfix
        'trg1_dir'    'value'; ...  % direction of correct target
        'trg1_bdir'   'id';    ...  % binned direction of correct target
        'trg2_dir'    'value'; ...  % direction of incorrect target
        'trg2_bdir'   'id';    ...  % binned direction of incorrect target
        }, ...
        'tmp', { ...  % values to extract & use temporarily: <name> <type> <method> <args>
        }}}, ...
        'spikes',  [], ...
        'analog',  []);
        
    return
    
% parse the trial ... check whether anything is given in FIRA.trial
elseif strcmp(func, 'trial')
    
    % get this trial index
    tti = FIRA.raw.trial.good_count;
    
    %%%
    % compute trg1_dir, trg2_dir from target x,y
    %   for now assume that T1 is always correct target
    %%%
    vals  = getFIRA_ec(tti, {'fp_x', 'fp_y', 't1_x', 't1_y', 't2_x', 't2_y'});
    t1ang = ang(vals(3:4) - vals(1:2));
    t2ang = ang(vals(5:6) - vals(1:2));
    setFIRA_ec(tti, {'trg1_dir', 'trg1_bdir', 'trg2_dir', 'trg2_bdir'}, ...
        [t1ang round(t1ang/10)*10 t2ang round(t2ang/10)*10]);
    
    %%%% ANALOG DATA %%%%
    %%%%%%%%%%%%%%%%%%%%%
        
    % re-calibrate eye position to last 10 ms of fixation
    % IF flag = 1
    
    if ~isempty(FIRA.header.flags) && FIRA.header.flags(1) == 1    
        getFIRA_saccades(tti, 0, true);
    end
     
% cleanup
else

    % collapse angles in range 0 -> 360
    if ~isempty(FIRA.ecodes.data)
        col = getFIRA_ecodeColumnByName('dot_dir');
        FIRA.ecodes.data(:, col) = mod(FIRA.ecodes.data(:, col), 360);
    end
    
    
    
    %%%
    % compute values for the field 'nv'
    % nv trials=1, non-nv trials = 0
    %
    % compute novar trials in two ways.
    %
    % In early experiments, when novar trials are mixed in
    % the same task with var trials, find the sb that occured most
    % frequently and define those trials as nv (nv=1). This sb is usually
    % the sb that I use in Rex.
    %
    % In later experiments, all novar trials are in the same task.
    % All trials in that task will be considered as nv.
    %
    % add by jcl on 9/15/05
    %%%
    if ~isempty(FIRA.header.flags)
        sb  = getFIRA_ecc('sb');
        Lsb = ~isnan(FIRA.ecodes.data(:,sb)); 
        if any(Lsb)     % only change trials with dots
            if FIRA.header.flags < 4
                nv  = getFIRA_ecc('nv');
                msb = nanmode(FIRA.ecodes.data(:,sb));
                Lnv = FIRA.ecodes.data(:,sb)==msb(1);
                FIRA.ecodes.data(Lnv,nv)  = 1;
                FIRA.ecodes.data(~Lnv,nv) = 0;
            else
                taskcd = getFIRA_ecc('taskcd');
                nv    = getFIRA_ecc('nv');
                Ltsk0 = FIRA.ecodes.data(:,taskcd)==0;  % assume novar trials are in task 0
                FIRA.ecodes.data(Ltsk0,nv)  = 1;
                FIRA.ecodes.data(~Ltsk0,nv) = 0;
            end
        end
    end
     
    
    
        
    %%%
    % Change tasks to "Universal" tasks
    % task 3 = passive fixation, 4 = visually-guided saccade,
    %      5 = delayed saccade,
    %      6 = dots training (novar trials is defined in field 'nv'
    %      99= undefined tasks
    %
    %%%
    task   = getFIRA_ecc('task');
    taskcd = getFIRA_ecc('taskcd');
    
    if ~isempty(FIRA.header.flags)
        %Changed this to access taskcd column instead of task - PMC
        %7/20/05
        
        if FIRA.header.flags == 1   
            % pre-training, old way to encode task
            Ltsk0 = FIRA.ecodes.data(:, taskcd) == 8;   % fixation with dots
            Ltsk1 = FIRA.ecodes.data(:, taskcd) == 2;   % visually guided saccade
            Ltsk2 = FIRA.ecodes.data(:, taskcd) == 1;   % fixation with no dots
            FIRA.ecodes.data(Ltsk0, task) = 3;
            FIRA.ecodes.data(Ltsk1, task) = 4;
            FIRA.ecodes.data(Ltsk2, task) = 99;
        elseif FIRA.header.flags == 2
            % searching paradigm used during training.
            %   task 0 = passive fixation, task 1 = delayed saccade,
            %   task 2 = undefined
            % used for getting ROC of a few MT neurons
            Ltsk0 = FIRA.ecodes.data(:, taskcd) == 0;
            Ltsk1 = FIRA.ecodes.data(:, taskcd) == 1;
            Ltsk2 = FIRA.ecodes.data(:, taskcd) == 2;
            FIRA.ecodes.data(Ltsk0, task) = 3;
            FIRA.ecodes.data(Ltsk1, task) = 4;
            FIRA.ecodes.data(Ltsk2, task) = 99;
        elseif FIRA.header.flags == 3
            % paradigm used early in training.
            %   task 0 = delayed saccade, task 1 = high coh dots,
            %   task 2 = low coh dots
            Ltsk0 = FIRA.ecodes.data(:, taskcd) == 0;
            Ltsk1 = FIRA.ecodes.data(:, taskcd) == 1;
            Ltsk2 = FIRA.ecodes.data(:, taskcd) == 2;
            FIRA.ecodes.data(Ltsk0, task) = 5;
            FIRA.ecodes.data(Ltsk1, task) = 6;
            FIRA.ecodes.data(Ltsk2, task) = 6;    
        elseif FIRA.header.flags == 4
            % paradigm used later in training.
            %   task 0 = novar dots, task 1 = all coh dots,
            %   task 2 = delayed saccade
            Ltsk0 = FIRA.ecodes.data(:, taskcd) == 0;
            Ltsk1 = FIRA.ecodes.data(:, taskcd) == 1;
            Ltsk2 = FIRA.ecodes.data(:, taskcd) == 2;
            FIRA.ecodes.data(Ltsk0, task) = 6;
            FIRA.ecodes.data(Ltsk1, task) = 6;
            FIRA.ecodes.data(Ltsk2, task) = 5;  
        elseif FIRA.header.flags == 5
            % paradigm used later in training.
            %   task 0 = novar dots, task 1 = high coh dots,
            %   task 2 = low coh dots
            Ltsk0 = FIRA.ecodes.data(:, taskcd) == 0;
            Ltsk1 = FIRA.ecodes.data(:, taskcd) == 1;
            Ltsk2 = FIRA.ecodes.data(:, taskcd) == 2;
            FIRA.ecodes.data(Ltsk0, task) = 6;
            FIRA.ecodes.data(Ltsk1, task) = 6;
            FIRA.ecodes.data(Ltsk2, task) = 6;  
        else
        end
    end


    %%%
    % Recomputer correct/error
    % 1=correct, 0=error, -1=nc, -2=brfix
    %
    %%%
    crtcd = getFIRA_ecc('crtcd');
    crt   = getFIRA_ecc('correct');
    Lcrt1  = FIRA.ecodes.data(:, crtcd) == 4905;
    Lcrt0  = FIRA.ecodes.data(:, crtcd) == 4906;
    Lcrtm1 = FIRA.ecodes.data(:, crtcd) == 4907;
    Lcrtm2 = FIRA.ecodes.data(:, crtcd) == 4913;
    FIRA.ecodes.data(Lcrt1,  crt) = 1;
    FIRA.ecodes.data(Lcrt0,  crt) = 0;
    FIRA.ecodes.data(Lcrtm1, crt) = -1;
    FIRA.ecodes.data(Lcrtm2, crt) = -2;

        
    % make all 0% coherence trials correct
%    FIRA.ecodes.data(:, ...
%        getFIRA_ecodeColumnByName('dot_coh') == 0 & ...
%        getFIRA_ecodeColumnByName('correct') == EC.WRONGCD) = EC.CORRECTCD;
end