function spm735(func)
% function spm735(func)
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

% created by jig 8/04/06
global FIRA
declareEC_ecodes;

%% if called with empty FIRA.spm, fill it and return
if strcmp(func, 'init')

    % useful ecode markers
    cb = 7500;
    cm = 7000;
    cx = 7999;

    % FIRA.spm is a struct with fields corresponding to "dataOutTypes"
    %   (see FIRA/build/dataOutTypes) ... listing them here is the
    %   preferred method of adding the particular data type to FIRA.
    %
    %   subfields are property/value pairs used when creating each
    %       data type (default overrides)
    %   an empty struct means just use defaults
    FIRA.spm = struct( ...
        'trial',  ...
        {{'startcd', 1005,  ...
        % 'startcd_offset', -1, ...
        'anycd',   [EC.CORRECTCD EC.WRONGCD EC.NOCHCD EC.BRFIXCD], ...
        'nocd',    [EC.ACCEPTCAL], ...
        }}, ...
        'ecodes', ...
        {{'extract', {   ...  % values to extract & save in FIRA{2}: <name> <type> <method> <args>
        'trg_on'    'time'   @getEC_time     {EC.TARGC1CD,    1}; ...
        'trg_off'   'time'   @getEC_time     {EC.TARGC2CD,    1}; ...
        'fp_off'    'time'   @getEC_time     {EC.FPOFFCD,     1}; ...
        'fp2_on'    'time'   @getEC_time     {EC.CNTRMNDCD,   1}; ...
        'all_off'   'time'   @getEC_time     {EC.ALLOFFCD,    1}; ...
        'fp_x'      'value'  @getEC_tagged   {EC.I_FIXXCD,    cb,   cm,   cx,  0.1}; ...
        'fp_y'      'value'  @getEC_tagged   {EC.I_FIXYCD,    cb,   cm,   cx,  0.1}; ...
        'fp_clut'   'value'  @getEC_tagged   {EC.I_FIXLCD,    cb,   cm,   cx,  0.1}; ...
        't_x'       'value'  @getEC_tagged   {EC.I_TRG1XCD,   cb,   cm,   cx,  0.1}; ...
        't_y'       'value'  @getEC_tagged   {EC.I_TRG1YCD,   cb,   cm,   cx,  0.1}; ...
        'taskcd'    'id'     @getEC_tagged   {EC.I_TASKIDCD, 7000, 7000, 8000}; ...
        'trialcd'   'id'     @getEC_tagged   {EC.I_TRIALIDCD, 7000, 7000, 8000}; ...
        'corcd'     'id'     @getEC_fromList {[EC.CORRECTCD, EC.WRONGCD, EC.NOCHCD]};  ...
        'fixcd'     'id'     @getEC_fromList {EC.FIX1CD}}, ...
        'compute', { ...              % names/types of fields to compute & save later in FIRA{2}
        'task'         'id'    ; ...  % see cleanup, below
        'correct'      'id'    ; ...  % 1=correct, 0=error, -1=nc, -2=brfix
        'ssd',         'time'  ; ...  % stop-signal delay on countermand trials
        'sac_lat'      'value' ; ...
        'sac_dur'      'value' ; ...
        'sac_vmax'     'value' ; ...
        'sac_vavg'     'value' ; ...
        'sac_endrx'    'value' ; ...
        'sac_endry'    'value' ; ...
        'num_rewards'  'value' ; ...  % number of reward dio
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

    % compute task type, fixonly flag
    % Task indices in REX paradigm 735 (i.e., 'taskcd') are:
    %   0       ... ASL
    %   1 and 2 ... fixation+target
    %   3 and 4 ... countermanding
    % Here ('task') indices are:
    %   0 ... fixation only
    %   1 ... overlap saccade
    %   2 ... memory saccade
    %   3 ... countermand
    taskcd = getFIRA_ec(tti, 'taskcd');
    if taskcd == 0 || ((taskcd == 1 || taskcd == 2) && ...
            ~isnan(getFIRA_ec(tti, 'fixcd')))
        
        % fixation only
        task = 0;
        
    elseif (taskcd == 1 || taskcd == 2) && ~isnan(getFIRA_ec(tti, 'trg_on')) && ...
            isnan(getFIRA_ec(tti, 'trg_off'))
        
        % overlap saccade -- target on but no target off
        task = 1;
        
    elseif (taskcd == 1 || taskcd == 2) && ~isnan(getFIRA_ec(tti, 'trg_on')) && ...
            ~isnan(getFIRA_ec(tti, 'trg_off'))

        % overlap saccade -- target on and target off
        task = 2;

    elseif taskcd == 3 || taskcd == 4
        
        % Countermand
        task = 3;

    else    
        disp('Bad task specification!!!')
    end
    setFIRA_ec(tti, 'task', task);
    
    % compute number of rewards
    if ~isfield(FIRA, 'dio') || isempty(FIRA.dio{tti})
        setFIRA_ec(tti, 'num_rewards', 0);
    else
        setFIRA_ec(tti, 'num_rewards', length(find(FIRA.dio{tti}(:,3)==2)));
    end

    % ANALOG DATA: parse saccades
    [sacs, bf] = getFIRA_saccades(tti, 1, true);

    % set saccade parameters
    setFIRA_ec(tti, 'sac_lat', sacs(1, 1:6));
    
    %%%
    % re-compute correct, error
    %
    %   1: correct
    %   0: error
    %  -1: no choice
    %  -2: broken fixation
    %%%
    v2f     = false;
    MIN_LAT = 70;
    if bf || (~isempty(sacs) && sacs(1,1) < MIN_LAT)

        % broken fixation
        setFIRA_ec(tti, 'correct', -2);

    elseif isempty(sacs)
        
        if task == 0 || task == 3
            
            % fixation-only or countermanding task -- CORRECT!
            setFIRA_ec(tti, 'correct', 1);
        else
            
            % no choice (this happens when monkey stays on fp)
            setFIRA_ec(tti, 'correct', -1);
        end
        
    else

        if task == 0 || task == 3

            % fixation-only or countermanding task -- ERROR
            setFIRA_ec(tti, 'correct', 0);            
        else
            
            % check for near target
            win_size  = 4.5;
            txy       = getFIRA_ec(tti, {'t_x', 't_y'});
            d_from_t  = sqrt((sacs(1,5)-(txy(1)))^2 + (sacs(1,6)-(txy(2)))^2);
                        
            if d_from_tc <= win_size

                % correct!
                setFIRA_ec(tti, 'correct',   1);                
            else
                
                % no choices
                setFIRA_ec(tti, 'correct',   -1);
            end
        end
    end

     if false% && getFIRA_ec(tti, 'dot_coh')==99.9 % getFIRA_ec(tti, 'correct') == -1
             % CHANGE THIS CASE FOR DEBUG PLOT, E.G., 
             %  true 
             %  getFIRA_ec(tti, 'correct') == -1
        
        plotFIRA_trial([FIRA.analog.data(tti, 1:2).values], ...
            FIRA.analog.data(tti, 1).start_time, FIRA.analog.store_rate(1), ...
            getFIRA_ec(tti, {'fp_off', 'fp_off', 'all_off'}) - [100 0 0], ...
            getFIRA_ec(tti, {'trg_on', 'trg_off'}), ...
            getFIRA_ec(tti, {'sac_lat', 'sac_dur'}), ...
            getFIRA_ec(tti, {'t_x', 't_y'}), ...
            getFIRA_ec(tti, {'sac_endrx', 'sac_endry'}));

        % wait for input
        switch getFIRA_ec(tti, 'correct')
            case -2
                ss = 'BROKEN FIXATION';
            case -1
                ss = 'NO CHOICE';
            case 0
                ss = 'ERROR';
            case 1
                ss = 'CORRECT';
        end
        
        a = input(sprintf('Outcome is %s ... next?', ss), 's');
        if a == 'q'
            error('done')
        end
    end
    
    % cleanup
else

    % compute stop-signal delay
    Ltask = getFIRA_ecc('task') == 3;
    FIRA.ecodes.data(Ltask, getFIRA_ecc('ssd')) = ...
        FIRA.ecodes.data(Ltask, getFIRA_ecc('fp2_on')) - ...
        FIRA.ecodes.data(Ltask, getFIRA_ecc('fp_off'));
end