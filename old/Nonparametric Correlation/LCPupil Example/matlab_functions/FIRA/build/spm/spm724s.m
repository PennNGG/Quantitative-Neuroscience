function spm724s(func)
% function spm724s(func)
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
        'anycd',   [EC.CORRECTCD EC.WRONGCD EC.NOCHCD EC.FIX1CD], ...
        'allcd',   [] ...
        }}, ...
        'ecodes', ...
        {{'extract', {   ...  % values to extract & save in FIRA{2}: <name> <type> <method> <args>
        'fp_set'    'time'   @getEC_time     {EC.TARGC1CD,    1}; ...  %Fixation attained
        'trg_on'    'time'   @getEC_time     {EC.TARGC1CD,    2}; ...
        'dot_on'    'time'   @getEC_time     {EC.GOCOHCD,     1}; ...
        'dot_off'   'time'   @getEC_time     {EC.STOFFCD,     1}; ...
        'fp_off'    'time'   @getEC_time     {EC.FPOFFCD,     1}; ...
        'stim_on'   'time'   @getEC_time     {EC.ELESTM,      1}; ...
        'all_off'   'time'   @getEC_time     {EC.ALLOFFCD,    1}; ...
        'fp_x'      'value'  @getEC_tagged   {EC.I_FIXXCD,    cb,   cm,   cx,  0.1}; ...
        'fp_y'      'value'  @getEC_tagged   {EC.I_FIXYCD,    cb,   cm,   cx,  0.1}; ...
        't1_x'      'value'  @getEC_tagged   {EC.I_TRG1XCD,   cb,   cm,   cx,  0.1}; ...
        't1_y'      'value'  @getEC_tagged   {EC.I_TRG1YCD,   cb,   cm,   cx,  0.1}; ...
        't2_x'      'value'  @getEC_tagged   {EC.I_TRG2XCD,   cb,   cm,   cx,  0.1}; ...
        't2_y'      'value'  @getEC_tagged   {EC.I_TRG2YCD,   cb,   cm,   cx,  0.1}; ...
        'dot_dir'   'id'     @getEC_tagged   {EC.I_DOTDIRCD,  cb,   cm,   cx}; ...
        'dot_coh'   'id'     @getEC_tagged   {EC.I_COHCD,     7000, 7000, 7999, 0.1}; ...
        'taskcd'    'id'     @getEC_tagged   {EC.I_TRIALIDCD, 7000, 7000, 7999}; ...
        'base'      'value'  @getEC_tagged   {8027,           7000, 7000, 7999}; ...
        'var'       'value'  @getEC_tagged   {8028,           7000, 7000, 7999}; ...
        'corcd'     'id'     @getEC_fromList {[EC.CORRECTCD, EC.WRONGCD, EC.NOCHCD EC.FIX1CD]}},       ...
        'compute', { ...              % names/types of fields to compute & save later in FIRA{2}
        'task'         'id'    ; ...  % see cleanup, below
        'correct'      'id'    ; ...  % 1=correct, 0=error, -1=nc, -2=brfix
        'choice'       'id'    ; ...  % duh
        'vol2_flag'    'id'    ; ...  % true if "correct" computed from second voluntary saccade
        'stim_flag'    'id'    ; ...  % 0=no stim; 1=stim but not effective; 2=effective stim
        'vol_lat'      'value' ; ...
        'vol_dur'      'value' ; ...
        'vol_vmax'     'value' ; ...
        'vol_vavg'     'value' ; ...
        'vol_endrx'    'value' ; ...
        'vol_endry'    'value' ; ...
        'stim_lat'     'value' ; ...
        'stim_dur'     'value' ; ...
        'stim_vmax'    'value' ; ...
        'stim_vavg'    'value' ; ...
        'stim_endrx'   'value' ; ...
        'stim_endry'   'value' ; ...
        'stim_distraw' 'value' ; ...
        'stim_distvec' 'value' ; ...
        'stim_endmx'   'value' ; ...
        'stim_endmy'   'value' ; ...
        'stim_dev'     'value' ; ...
        'stim_zdev'    'value' ; ...  % z-scores of deviations
        'stim_curve'   'value' ; ...  % calculate ratio of distraw and distvec PMC added 5/13/05
        'num_rewards'  'value' ; ...  % number of reward dio
        'trial_gap'    'value' ; ...  % time between end of last trial (all_off or last beep) and beginning of this trial
        'fix_time'     'value' ; ...  % time to attain fixation from beginning of trial (first fp_on)
        'stim_sac'     'time'  ; ...  % time of end of stim sac
        'vol_sac'      'time'  ; ...
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

    % FOR PATRICK - number of beeps
    if isempty(FIRA.dio{tti})
        setFIRA_ec(tti, 'num_rewards' , 0);
    else
        num_rewards = length(find(FIRA.dio{tti}(:,3)==2));
        setFIRA_ec(tti, 'num_rewards', num_rewards);
    end
    
    %Time between trials
    if tti > 2 
        if  getFIRA_ec(tti-1,'correct') == 1 && ~isempty(FIRA.dio{tti-1}) && FIRA.dio{tti-1}(end,3) == 2 
            beep_time = FIRA.dio{tti-1}(end,1) + getFIRA_ec(tti-1, 'trial_wrt');
            trial_start = getFIRA_ec(tti, 'trial_begin') + getFIRA_ec(tti, 'trial_wrt');
            setFIRA_ec(tti, 'trial_gap', trial_start - beep_time);
        else 
            trial_end = getFIRA_ec(tti-1, 'trial_end') + getFIRA_ec(tti-1, 'trial_wrt');
            trial_start = getFIRA_ec(tti, 'trial_begin') + getFIRA_ec(tti, 'trial_wrt');
            setFIRA_ec(tti, 'trial_gap', trial_start - trial_end);
        end
    else
        setFIRA_ec(tti,'trial_gap', nan);
    end
    
    %Time to attain fixation
    fix_time = getFIRA_ec(tti, 'fp_set') - getFIRA_ec(tti, 'trial_begin');
    setFIRA_ec(tti, 'fix_time', fix_time);
    
    % display some stuff
    % disp(FIRA.ecodes.data(tti, strmatch('correct', FIRA.ecodes.name, 'exact')))

    %%%
    % ANALOG DATA
    %%%
    % parse differently if stim or no stim given
    if isnan(getFIRA_ec(tti, 'stim_on'))

        % check for TWO saccades
        [sacs, bf] = getFIRA_saccades(tti, 2, true);

        % set stim flag = 0 (no stim given)
        sf = 0;

    else

        % check for FOUR saccades
        [sacs, bf] = getFIRA_saccades(tti, 4, true);

        if bf || isempty(sacs) || sacs(1,1) < 15 || sacs(1,1) > 90

            % set stim_flag = 1 (stim given but not effective)
            sf = 1;

            if ~isempty(sacs) && sacs(1, 1) < 15
                sacs(1, :) = [];
            end

        else

            % set stim flag = 2 (stim given and effective)
            sf = 2;

            % set stim params
            setFIRA_ec(tti, 'stim_lat',   sacs(1, :));
            setFIRA_ec(tti, 'stim_curve', sacs(1, 8)/sacs(1, 7));

            % remove, checking that the next one doesn't immediately follow
            if size(sacs, 1) > 2 && sacs(3, 1) < 300 && ...
                    sacs(2, 1) - sacs(1, 1) - sacs(1, 2) < 10
                sacs(1:2, :) = [];
            else
                sacs(1,   :) = [];
            end
        end
    end

    %%%
    % targets, saccade end points wrt fix
    %%%
    fp = getFIRA_ec(tti, {'fp_x', 'fp_y'});
    setFIRA_ec(tti, {'t1_x', 't1_y', 't2_x', 't2_y'}, [ ...
        getFIRA_ec(tti, {'t1_x', 't1_y'}) - fp, ...
        getFIRA_ec(tti, {'t2_x', 't2_y'}) - fp]);

    d_from_tc = inf;
    d_from_ti = inf;

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
    if bf || (size(sacs, 1) >= 1 && sacs(end, 1) < MIN_LAT)

        % broken fixation
        setFIRA_ec(tti, 'correct', -2);

    elseif isempty(sacs)

        % no choice (this happens when monkey stays on fp)
        setFIRA_ec(tti, 'correct', -1);

    else

        % re-calculate correct/error/nc from eye position
        win_size  = 5.5;
        tc        = getFIRA_ec(tti, {'t1_x', 't1_y'});
        te        = getFIRA_ec(tti, {'t2_x', 't2_y'});
        d_from_tc = sqrt((sacs(1,5)-(tc(1)))^2 + (sacs(1,6)-(tc(2)))^2);
        d_from_ti = sqrt((sacs(1,5)-(te(1)))^2 + (sacs(1,6)-(te(2)))^2);

        if sacs(1, 1) >= MIN_LAT && d_from_tc <= d_from_ti && d_from_tc < win_size

            % correct, 1st voluntary saccade
            setFIRA_ec(tti, 'correct',   1);
            setFIRA_ec(tti, 'vol_lat',   sacs(1, 1:6));

        elseif sacs(1, 1) >= MIN_LAT && d_from_ti < win_size

            % error, 1st voluntary saccade
            setFIRA_ec(tti, 'correct',   0);
            setFIRA_ec(tti, 'vol_lat',   sacs(1, 1:6));

        elseif size(sacs, 1) > 1 && sacs(2, 1) >= MIN_LAT && ...
                (sf == 2 || sacs(1, 8) < 2)

            d_from_tc = sqrt((sacs(2,5)-(tc(1)))^2 + (sacs(2,6)-(tc(2)))^2);
            d_from_ti = sqrt((sacs(2,5)-(te(1)))^2 + (sacs(2,6)-(te(2)))^2);

            if d_from_tc <= d_from_ti && d_from_tc < win_size

                % correct, 2nd voluntary saccade
                setFIRA_ec(tti, 'correct',   1);
                setFIRA_ec(tti, 'vol_lat',   sacs(2, 1:6));
                v2f = true;

            elseif d_from_ti < win_size

                % error, 2nd voluntary saccade
                setFIRA_ec(tti, 'correct',   0);
                setFIRA_ec(tti, 'vol_lat',   sacs(2, 1:6));
                v2f = true;

            else
                setFIRA_ec(tti, 'correct', -1);
            end
        else
            setFIRA_ec(tti, 'correct', -1);
        end
    end

    % set stuff
    setFIRA_ec(tti, 'stim_flag', sf);
    setFIRA_ec(tti, 'vol2_flag', v2f);

    if false% && getFIRA_ec(tti, 'dot_coh')==99.9 % getFIRA_ec(tti, 'correct') == -1
             % CHANGE THIS CASE FOR DEBUG PLOT, E.G., 
             %  true 
             %  getFIRA_ec(tti, 'correct') == -1
        
        plotFIRA_trial([FIRA.analog.data(tti, 1:2).values], ...
            FIRA.analog.data(tti, 1).start_time, FIRA.analog.store_rate(1), ...
            getFIRA_ec(tti, {'dot_on', 'fp_off', 'all_off'}) - [100 0 0], ...
            getFIRA_ec(tti, {'dot_on', 'dot_off'}), ...
            getFIRA_ec(tti, {'stim_lat', 'stim_dur', 'vol_lat', 'vol_dur'}), ...
            getFIRA_ec(tti, {'t1_x', 't1_y', 't2_x', 't2_y'}), ...
            getFIRA_ec(tti, {'stim_endrx', 'stim_endry', 'vol_endrx', 'vol_endry'}));

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
        
        a = input(sprintf('Outcome (stim=%d) is %s ... next?', sf, ss), 's');
        if a == 'q'
            error('done')
        end
    end
    
    % cleanup
else

    % Add session id and subject id to header -PMC
    % done in cleanup because filename is not accessible
    %   in init (not until 'read')
    FIRA.header.subject = FIRA.header.filename{1}(1:3);
    FIRA.header.session = FIRA.header.filename{1}(8:end-4);

    if ~isempty(FIRA.ecodes.data)

        % useful variables
        t1x = getFIRA_ecc('t1_x');
        t1y = getFIRA_ecc('t1_y');
        t2x = getFIRA_ecc('t2_x');
        t2y = getFIRA_ecc('t2_y');
        dir = getFIRA_ecc('dot_dir');
        coh = getFIRA_ecc('dot_coh');
        tsk = getFIRA_ecc('task');
        stf = getFIRA_ecc('stim_flag');
        erx = getFIRA_ecc('stim_endrx');
        ery = getFIRA_ecc('stim_endry');
        emx = getFIRA_ecc('stim_endmx');
        emy = getFIRA_ecc('stim_endmy');
        dev = getFIRA_ecc('stim_dev');
        cor = getFIRA_ecc('correct');
        %PMC added 8/21/06
        bas = getFIRA_ecc('base');
        var = getFIRA_ecc('var');
        
        % jig added 9/21/06
        % time of stim, vol saccades
        FIRA.ecodes.data(:,getFIRA_ecc('stim_sac')) = 5 + ...
            FIRA.ecodes.data(:, getFIRA_ecc('fp_off')) + ...
            FIRA.ecodes.data(:, getFIRA_ecc('stim_lat')) + ...
            FIRA.ecodes.data(:, getFIRA_ecc('stim_dur'));        
        FIRA.ecodes.data(:,getFIRA_ecc('vol_sac')) = 5 + ...
            FIRA.ecodes.data(:, getFIRA_ecc('fp_off')) + ...
            FIRA.ecodes.data(:, getFIRA_ecc('vol_lat')) + ...
            FIRA.ecodes.data(:, getFIRA_ecc('vol_dur'));

        %%%
        % Change tasks to "Universal" tasks
        %   task 3 = dots, Single Target
        %   task 4 = dots, two targets
        %   task 5 = NoVar dots, two targets
        %%%
        task   = getFIRA_ecc('task');
        taskcd = getFIRA_ecc('taskcd');

        if ~isempty(FIRA.header.flags)
            %Changed this to access taskcd column instead of task - PMC
            %7/20/05
            Ltsk0 = FIRA.ecodes.data(:, taskcd) == 0;
            Ltsk1 = FIRA.ecodes.data(:, taskcd) == 1;
            Ltsk2 = FIRA.ecodes.data(:, taskcd) == 2;

            if FIRA.header.flags == 0
                FIRA.ecodes.data(Ltsk0, task) = 2;
                FIRA.ecodes.data(Ltsk1, task) = 4;
                FIRA.ecodes.data(Ltsk2, task) = 4;
            elseif FIRA.header.flags == 1
                FIRA.ecodes.data(Ltsk0, task) = 3;
                FIRA.ecodes.data(Ltsk1, task) = 4;
                FIRA.ecodes.data(Ltsk2, task) = 4;
            elseif FIRA.header.flags == 2
                FIRA.ecodes.data(Ltsk0, task) = 3;
                FIRA.ecodes.data(Ltsk1, task) = 4;
                FIRA.ecodes.data(Ltsk2, task) = 3;
            elseif FIRA.header.flags == 3                
                FIRA.ecodes.data(Ltsk0, task) = 3;
                FIRA.ecodes.data(Ltsk1, task) = 4;
                FIRA.ecodes.data(Ltsk2, task) = 5;
            elseif FIRA.header.flags == 3.5
                % SPECIAL CASE FOR ATT_10_19_05 (ST + TR files)
                % started with task0 == one target (incorrectly)
                %   later changed to two targets
                FIRA.ecodes.data(Ltsk0, task)  = 4;
                FIRA.ecodes.data(Ltsk1, task)  = 4;
                FIRA.ecodes.data(Ltsk2, task)  = 5;                
                FIRA.ecodes.data(1:find(Ltsk1|Ltsk2,1)-1, task) = 3;
            elseif FIRA.header.flags == 4
                % special "ST" files added ...
                % First x trials are task 0 (one target)
                % Remaining are 0=4, 1=4, 2=5
                % keep these in this order!
                FIRA.ecodes.data(Ltsk0, task)  = 4;
                FIRA.ecodes.data(Ltsk1, task)  = 4;
                FIRA.ecodes.data(Ltsk2, task)  = 5;                
                FIRA.ecodes.data(...
                    1:find(Ltsk1|Ltsk2,1)-1, task) = 3;
                %|FIRA.ecodes.data(:,coh)~=6.4 - removed from ST algorithm
            elseif FIRA.header.flags == 5 %PMC added 8/21/06
                % Still special "ST" files added, but now
                % we have rearranged cohs so that novars are
                % mixed with vars in task 1 so ...
                % First x trials are task 0 (one target)
                % Remaining are 0=4, 1=4 OR 5, 2=4
                % keep these in this order!
                FIRA.ecodes.data(Ltsk0, task) = 4;
                %Initially assign all of task 1 to var dots
                FIRA.ecodes.data(Ltsk1, task) = 4;
                FIRA.ecodes.data(Ltsk2, task) = 4;
                %Find mode of seed base
                md = mode(FIRA.ecodes.data(:, bas));
                %Get indices of trials with that mode
                Lmd = find(FIRA.ecodes.data(:, bas) == md);
                %Using mode of base find novars based on var column
                Lnvar = FIRA.ecodes.data(Lmd, var) == ...
                    round(FIRA.ecodes.data(Lmd,coh)) + (cos(pi/180*(FIRA.ecodes.data(Lmd,dir)))>=0);
                %Change codes where appropriate
                FIRA.ecodes.data(Lmd(Lnvar), task) = 5;
                
                %Now find single targ trials like before
                FIRA.ecodes.data(...
                    1:find(Ltsk1|Ltsk2,1)-1, task) = 3;
            else
                disp('bad flag')
            end
        end

        % find all 0% coh trials marked as errors
        Le0 = FIRA.ecodes.data(:, cor) == 0 & ...
            FIRA.ecodes.data(:, coh) == 0;

        % label all 0% trials as correct
        FIRA.ecodes.data(Le0, cor) = 1;

        % flip dot dir, T1/T2 on 0% coh "error" trials
        FIRA.ecodes.data(Le0, dir)       = FIRA.ecodes.data(Le0, dir) + 180;
        txy                              = FIRA.ecodes.data(Le0, [t1x t1y]);
        FIRA.ecodes.data(Le0, [t1x t1y]) = FIRA.ecodes.data(Le0, [t2x t2y]);
        FIRA.ecodes.data(Le0, [t2x t2y]) = txy;

        %%%
        % collapse all angles to range 0 -> 360
        %%%
        FIRA.ecodes.data(:, dir) = mod(FIRA.ecodes.data(:, dir), 360);

        % fold in nearby angles, if necessary
        udirs = nonanunique(FIRA.ecodes.data(:,dir));
        if length(udirs) == 4
            [ns, I] = sort(hist(FIRA.ecodes.data(:,dir), udirs));
            for ii = 1:2
                FIRA.ecodes.data(FIRA.ecodes.data(:,dir)==udirs(I(ii)), ...
                    dir) = udirs(I(ii+2));
            end
        end

        % get correct, error selection arrays
        % jig moved these here 8/15/05 -- previous
        % bug had problems with choice computation, below
        Lcor = FIRA.ecodes.data(:, cor) == 1;
        Lerr = FIRA.ecodes.data(:, cor) == 0;

        %%%
        % choice
        %%%
        choice = FIRA.ecodes.data(:, dir);
        choice(~(Lcor | Lerr)) = nan;
        choice(Lerr)           = choice(Lerr) + 180;
        choice(choice>=360)     = choice(choice>=360)-360;
        FIRA.ecodes.data(:, getFIRA_ecc('choice')) = choice;

        %%%
        % compute run-mean subtracted endpoints for stim saccade - PMC
        % changed 5/18/05
        %%%
        Ldot = (Lerr | Lcor) & FIRA.ecodes.data(:, stf) > 1; %%& FIRA.ecodes.data(:,tsk) ~= 0;  -removed because I switched
        %the tasks around 6/9/05 so that tasks 0 & 2 were single target, and 1
        %has all cohs now

        if any(Ldot)

            % first compute run-mean subtracted ends for each CHOSEN
            % direction (target location)
            fd    = find(Ldot);
            angs  = choice(fd);
            uangs = nonanunique(angs);

            % jig fixed bug 8/17/05
            rms   = nans(length(fd), length(uangs), 2);
            for ii = 1:length(uangs)
                rms(angs==uangs(ii), ii, :) = ...
                    FIRA.ecodes.data(fd(angs==uangs(ii)), [erx ery]);
            end
            FIRA.ecodes.data(Ldot, emx) = FIRA.ecodes.data(Ldot, erx) - ...
                mean(nanrunmean(rms(:,:,1), 75), 2);
            FIRA.ecodes.data(Ldot, emy) = FIRA.ecodes.data(Ldot, ery) - ...
                mean(nanrunmean(rms(:,:,2), 75), 2);

            % compute deviations wrt CHOSEN direction
            FIRA.ecodes.data(Ldot, dev) = ...
                dot([cos(angs*pi/180) sin(angs*pi/180)], ...
                [FIRA.ecodes.data(Ldot, emx) FIRA.ecodes.data(Ldot, emy)], 2);
            
            % z-score of deviations
            FIRA.ecodes.data(Ldot, getFIRA_ecc('stim_zdev')) = ...
                zscore(FIRA.ecodes.data(Ldot, dev));

%            % compute z-score of deviations, separately for each choice
%            for ii = 1:length(uangs)
%                Lz = Ldot & choice == uangs(ii);
%                FIRA.ecodes.data(Lz, getFIRA_ecc('stim_zdev')) = ...
%                    zscore(FIRA.ecodes.data(Lz, dev));
%            end
        end
    end
end