function spm700(func)
% function spm700(func)
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

% Copyright 2004 by Joshua I. Gold
%   University of Pennsylvania
%
% created by jig 10/21/04
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

    if FIRA.header.flags == 9 || FIRA.header.flags == 10

        coh_args = {EC.I_COHCD, 6000, 6000, 6999, 0.1};
        tca      = {0, 0, 100};
        
    elseif FIRA.header.flags == 13

        coh_args = {EC.I_COHCD, 6000, 6000, 6999, 0.1};
        tca      = {cb, cm, cx};

    else
        
        coh_args = {EC.I_COHCD, 7000, 7000, 7999, 0.1};
        tca      = {cb, cm, cx};
    end

    fpcd = 1025;
    if FIRA.header.flags == 16
        fpcd = [];
    end
    
    FIRA.spm = struct( ...
        'trial',  ...
        {{ ...
        'startcd', 1005, ...
        'anycd',   fpcd, ...
        }}, ...
        'ecodes', ...
        {{'extract', { ... % to save in FIRA{2}: <name> <type> <method> <args>
        'fp_off'    'time'     @getEC_time      {EC.FPOFFCD,    1};               ...
        'ins_on'    'time'     @getEC_time      {EC.GOCOHCD,    1};               ...
        'ins_off'   'time'     @getEC_time      {EC.STOFFCD,    2};               ...
        'trg_on'    'time'     @getEC_time      {EC.TARGONCD,   1};               ...
        'all_off'   'time'     @getEC_time      {EC.ALLOFFCD,   1};               ...
        'fp_x'      'value'    @getEC_tagged    {EC.I_FIXXCD,   cb, cm, cx, 0.1}; ...
        'fp_y'      'value'    @getEC_tagged    {EC.I_FIXYCD,   cb, cm, cx, 0.1}; ...
        't1_x'      'value'    @getEC_tagged    {EC.I_TRG1XCD,  cb, cm, cx, 0.1}; ...
        't1_y'      'value'    @getEC_tagged    {EC.I_TRG1YCD,  cb, cm, cx, 0.1}; ...
        't1_c'      'value'    @getEC_tagged    {8025,          tca{:}};      ...
        't2_x'      'value'    @getEC_tagged    {EC.I_TRG2XCD,  cb, cm, cx, 0.1}; ...
        't2_y'      'value'    @getEC_tagged    {EC.I_TRG2YCD,  cb, cm, cx, 0.1}; ...
        't2_c'      'value'    @getEC_tagged    {8026,          tca{:}}; ...
        'cor_code'  'id'       @getEC_fromList  {[EC.CORRECTCD EC.WRONGCD EC.NOCHCD]};  ...
        'dot_dir'   'id'       @getEC_tagged    {EC.I_DOTDIRCD, cb, cm, cx};      ...
        'dot_coh'   'id'       @getEC_tagged    coh_args;                         ...
        }, ...
        'compute', { ...  % names/types of fields to compute & save later in FIRA{2}
        'task',     'id';    ...    % 1=fix; 2=sac; 8=dots
        'correct',  'id';    ...    % 1=correct; 0=error; -1=NC; -2=BR Fix
        'cor_trg',  'id';    ...    % 1=T1, 2=T2
        'ins_dur',  'value'; ...    % dot/fpchange duration (ins_off - ins_on)
        'trgc_dir'  'value'; ...    % direction (angle, in degrees) of correct target
        'trge_dir'  'value'; ...    % direction (angle, in degrees) of incorrect target
        'trgc_bdir' 'id';    ...    % binned direction (angle, in degrees) of correct target
        'trge_bdir' 'id';    ...    % binned direction (angle, in degrees) of incorrect target
        'vol_lat'   'value'; ...    % latency to voluntary saccade
        'vol_dur'   'value'; ...    % duration of voluntary saccade
        'vol_vmx'   'value'; ...    % max saccade velocity
        'vol_vav'   'value'; ...    % average saccade velocity
        'vol_endx'  'value'; ...    % eye position x end-point
        'vol_endy'  'value'; ...    % eye position y end-point
        'sac_begin' 'time';  ...
        }, ...
        'tmp', { ...  % values to extract & use temporarily: <name> <type> <method> <args>
        'sid'       'id'        @getEC_range     {5000 5100}; ...
        }}}, ...
        'spikes',  [], ...
        'analog',  []);

    return

    % parse the trial ... check whether anything is given in FIRA.trial
elseif strcmp(func, 'trial')

    % get this trial index
    tti = FIRA.raw.trial.good_count;

    if FIRA.header.flags == 16 && isnan(getFIRA_ec(tti, 'fp_off'))

        %%% jig added 3/6/02
        %%% for bug in ike2008a -> ike2011c
        setFIRA_ec(tti, 'fp_off', getEC_time(FIRA.raw.trial.ecodes, EC.EYINWD, -150));
    end

    %%
    % parse task id
    %%
    if FIRA.header.flags > 14
        
        % new style (722) ... task stored as tagged code
        % also note ins_on, ins_off ALWAYS as GOCOHCD and STOFFCD
        task = getEC_tagged(FIRA.raw.trial.ecodes, EC.I_TRIALIDCD, 7000, 7000, 7999);
        
    elseif FIRA.raw.trial.tmp_ecodes(1) >= 71

        % dots task
        task = 8;

        % fix trg_on, if necessary
        if FIRA.header.flags == 9 || FIRA.header.flags == 10

            % trg_on = fp_off - 100
            setFIRA_ec(tti, 'trg_on', getFIRA_ec(tti, 'fp_off') - 100);

        elseif FIRA.header.flags == 13

            % trg_on = code 4918 (GOTRGONCD)
            setFIRA_ec(tti, 'trg_on', getEC_time(FIRA.raw.trial.ecodes, 4918, 1));
        end

    elseif FIRA.raw.trial.tmp_ecodes(1) >= 31 && ...
            FIRA.raw.trial.tmp_ecodes(1) < 40

        % saccade task
        task = 2;

        % fix ins_on, ins_off
        if FIRA.header.flags == 9

            % bug in 712old -- always showed red fp blink
            setFIRA_ec(tti, 'dot_dir', 0);

            % use pair of "FPONBLINKCD" codes for ins_on, ins_off
            setFIRA_ec(tti, {'ins_on', 'ins_off'}, ...
                getEC_time(FIRA.raw.trial.ecodes, EC.FPONBLINKCD, [1 2]) - ...
                FIRA.raw.trial.wrt);

        else

            % use fpflsh for ins_in, "FPONBLINKCD" for ins_off
            eind = find(FIRA.raw.trial.ecodes(:,2) >= 5100 & ...
                FIRA.raw.trial.ecodes(:,2) <= 5200, 1);

            if ~isempty(eind)

                % FIRA.raw.trial.ecodes(eind(1), 2) - 5100))
                setFIRA_ec(tti, {'ins_on', 'ins_off'}, ...
                    [FIRA.raw.trial.ecodes(eind, 1), ...
                    getEC_time(FIRA.raw.trial.ecodes, EC.FPONBLINKCD, 1)] - ...
                    FIRA.raw.trial.wrt);

                % for flag==10, use fpflsh offset (tc clut) to
                % determine "direction"
                if FIRA.header.flags == 10
                    if FIRA.raw.trial.ecodes(eind, 2)-5100 == getFIRA_ec(tti, 't1_c')
                        setFIRA_ec(tti, 'dot_dir', 0);
                    else
                        setFIRA_ec(tti, 'dot_dir', 180);
                    end
                end
            end
        end
    else

        % fixation task
        task = 1;
    end

    % set task
    setFIRA_ec(tti, 'task', task);

    %%
    % compute trg[ce]_[b]dir
    %%
    vals  = getFIRA_ec(tti, {'fp_x', 'fp_y', 't1_x', 't1_y', 't2_x', 't2_y'});
    t1ang = ang(vals(3:4) - vals(1:2));
    t2ang = ang(vals(5:6) - vals(1:2));
    cind  = getFIRA_ecc('trgc_dir');

    % figure out correct/error target (t1/t2)
    % flags == 9 or 10: 712 old style - parse from dot direction
    % flags == 13: 712 new style, use code that marks sac begin
    %           (5400 + gl_tc_clut + gl_tsk)
    % flags >= 14: use I_GOLUMCD (8024)
    if ...
            ((FIRA.header.flags == 9 || FIRA.header.flags == 10) && ...
            cos(0.0174533 * getFIRA_ec(tti, 'dot_dir')) >= 0) || ...
            (FIRA.header.flags == 13 && ...
            getEC_range(FIRA.raw.trial.ecodes, 5400, 5600) - ...
            task == getFIRA_ec(tti, 't1_c')) || ...
            (FIRA.header.flags >= 14 && ...
            getEC_tagged(FIRA.raw.trial.ecodes, 8024, 7500, 7000, 7999) == ...
            getFIRA_ec(tti, 't1_c'))

        % right: t1 is correct
        setFIRA_ec(tti, 'cor_trg', 1);
        
        tc = vals(3:4);
        te = vals(5:6);

        FIRA.ecodes.data(tti, [cind:cind+3]) = ...
            [t1ang, t2ang, round(t1ang/10)*10, round(t2ang/10)*10];

    else

        % left: t2 is correct
        setFIRA_ec(tti, 'cor_trg', 2);

        te = vals(3:4);
        tc = vals(5:6);

        FIRA.ecodes.data(tti, [cind:cind+3]) = ...
            [t2ang, t1ang, round(t2ang/10)*10, round(t1ang/10)*10];
    end

    %%
    % Get eye data for non-fixation trials
    %%
    if task ~= 1

        % get saccade data
        [sacs, bf] = getFIRA_saccades(tti, 1, true);
        
        % set sac begin time
        if ~isempty(sacs)
            setFIRA_ec(tti, 'sac_begin', sacs(1) + getFIRA_ec(tti, 'fp_off'));
        end
        
        if bf

            % flag for broken fixation
            setFIRA_ec(tti, 'correct', -2);

        elseif isempty(sacs)

            % no choice
            setFIRA_ec(tti, 'correct', -1);

        else

            % save params
            ind = getFIRA_ecc('vol_lat');
            FIRA.ecodes.data(tti, ind:ind+5) = sacs(1:6);

            % re-calculate correct/error/nc from eye position
            d_from_tc = sqrt((sacs(5)-(tc(1)))^2 + (sacs(6)-(tc(2)))^2);
            d_from_ti = sqrt((sacs(5)-(te(1)))^2 + (sacs(6)-(te(2)))^2);
            win_size  = 3.5; % min distance from target for good trial
            if d_from_tc <= d_from_ti && d_from_tc < win_size
                setFIRA_ec(tti, 'correct', 1);
            elseif d_from_ti < win_size
                setFIRA_ec(tti, 'correct', 0);
            else
                setFIRA_ec(tti, 'correct', -1);
            end
        end

        % also compute ins_dur
        setFIRA_ec(tti, 'ins_dur', ...
            diff(getFIRA_ec(tti, {'ins_on', 'ins_off'})));
    end

    % cleanup
else

    % collapse angles in range 0 -> 360
    if ~isempty(FIRA.ecodes.data)
        col = getFIRA_ecc('dot_dir');
        FIRA.ecodes.data(:, col) = mod(FIRA.ecodes.data(:, col), 360);
    end

    % make all 0% coherence trials correct
    % FIRA.ecodes.data(:, ...
    %     getFIRA_ecodeColumnByName('dot_coh') == 0 & ...
    %     getFIRA_ecodeColumnByName('correct') == 0) = 1;
end