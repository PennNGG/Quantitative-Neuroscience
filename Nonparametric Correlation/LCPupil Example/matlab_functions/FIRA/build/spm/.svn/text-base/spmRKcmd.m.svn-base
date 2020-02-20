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
try
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
            'fp_on'     'time'      @getEC_time         {EC.FPONCD      1}; ...
            'eyefix'    'time'      @getEC_time         {EC.EYINWD      1}; ...
            'fp_change' 'time'      @getEC_time         {EC.FPCHG       1}; ...
            'tgt_on'    'time'      @getEC_time         {EC.TRGC1CD     1}; ...
            'tgt_off'   'time'      @getEC_time         {EC.TARGOFFCD   1}; ...
            'fp_off'    'time'      @getEC_time         {EC.FPOFFCD     1}; ...
            'fdbkon'    'time'      @getEC_time         {EC.FDBKONCD    1}; ...
            'cmdon'     'time'      @getEC_time         {EC.CNTRMNDCD    1}; ...
            'sac_on'    'time'      @getEC_time         {EC.SACMAD      1}; ...
            'OLcorrect' 'time'      @getEC_time         {EC.CORRECTCD    1}; ...
            'OLerror'   'time'      @getEC_time         {EC.WRONGCD    1}; ...
            'OLncerr'   'time'      @getEC_time         {EC.NOCHCD    1}; ...
            'OLbrfix'   'time'      @getEC_time         {EC.BRFIXCD    1}; ...
            'fp_x'      'value'     @getEC_tagged       {EC.I_FIXXCD    cb    cm    cx  0.1};   ...
            'fp_y'      'value'     @getEC_tagged       {EC.I_FIXYCD    cb    cm    cx  0.1};   ...
            't1_x'      'value'     @getEC_tagged       {EC.I_TRG1XCD   cb    cm    cx  0.1};   ...
            't1_y'      'value'     @getEC_tagged       {EC.I_TRG1YCD   cb    cm    cx  0.1};   ...
            't2_x'      'value'     @getEC_tagged       {EC.I_TRG2XCD   cb    cm    cx  0.1};   ...
            't2_y'      'value'     @getEC_tagged       {EC.I_TRG2YCD   cb    cm    cx  0.1};   ...
            'taskid'    'id'        @getEC_tagged       {EC.I_TASKIDCD  cb    cm    cx  1};     ...
            'trialid'   'id'        @getEC_tagged       {EC.I_TRIALIDCD cb    cm    cx  1};     ...
            'seed_base' 'value'     @getEC_tagged       {EC.I_DTVARCD   cb    cm    cx  1};     ...
            }, ...
            'compute', { ...                % names/types of fields to compute & save later in FIRA{2}
            'cor_object',   'id'; ...       % whether target is correct or fixation point
            'choice'        'id'; ...       % which object was chosen:  0=fixation point, 1=target 1, -1=no choice
            'correct'       'id'; ...       % offline score: 1=correct, 0=error, -1=nc, -2=brfix
            'OLscore'       'value'; ...    % online score: 1=correct, 0=error, -1=nc, -2=brfix
            'scorematch'    'value' ; ...
            'stopsigdelay'  'value' ; ...
            'fix_time'      'value' ; ...   % time to attain fixation from beginning of trial (first fp_on)
            'sac_endx'      'value' ; ...
            'sac_endy'      'value' ; ...
            'sac_lat'       'value' ; ...
            'sac_dur'       'value' ; ...
            'sac_vmax'      'value' ; ...
            'sac_amp1'       'value' ; ...
            'sac_amp2'       'value' ; ...
            'sac_on_offline'       'value' ; ...
            }, ...
            'tmp', { ...  % values to extract & use temporarily: <name> <type> <method> <args>
            }}}, ...
            'spikes',  [], ...
            'analog',  {{'resample', {'horiz_eye', 240; 'vert_eye', 240}}});

        % parse the trial ... check whether anything is given in FIRA.trial
    elseif strcmp(func, 'trial')

        % get this trial index
        tti = FIRA.raw.trial.good_count;
        taskid = getFIRA_ec(tti, {'taskid'});

        % compute the saccade-related values
        [sacs_, bf_] = getFIRA_saccades(tti, 2, true , 'horiz_eye', 'vert_eye', 'fp_off', 'fp_x', 'fp_y', 1000);

        if bf_ == false && ~isempty(sacs_);

            % set the reaction time
            setFIRA_ec(tti, 'sac_lat', sacs_(1,1));

            % set the x-coord of the saccade end point
            setFIRA_ec(tti, 'sac_endx', sacs_(1,5));

            % set the y-coord of the saccade end point
            setFIRA_ec(tti, 'sac_endy', sacs_(1,6));

            % set the saccade maximum velocity
            setFIRA_ec(tti, 'sac_vmax', sacs_(1,3));

            % set the saccade amplitude (raw distance)
            setFIRA_ec(tti, 'sac_amp1', sacs_(1,7));

            % set the saccade amplitude (linear vector)
            setFIRA_ec(tti, 'sac_amp2', sacs_(1,8));

            % set the total time the saccade is on
            setFIRA_ec(tti, 'sac_on_offline', getFIRA_ec(tti, 'fp_off')+ sacs_(1,1));
        end


        %set the correct object
        if getFIRA_ec(tti, {'taskid'}) == 2;
            setFIRA_ec(tti, {'cor_object'}, 1);
        elseif getFIRA_ec(tti, {'taskid'}) == 3;
            setFIRA_ec(tti, {'cor_object'}, 0);
        end

        %sacs_(1001:1200, :)

        %set the choice & offline score
        if ~isempty('fp_off')
            t_eyeshift = 0; d_eyeshift = 0;
            if bf_ || isempty(sacs_);
                setFIRA_ec(tti, {'choice'}, -1);    %fixbreak or other errors
                setFIRA_ec(tti, {'correct'}, -2);
            else
                [nSacs,m] = size(sacs_);
                if nSacs>1 && ~isinf( sacs_(2,1) ) && ~isnan( sacs_(2,1) )
                    t_eyeshift = sacs_(2,1) - sacs_(1,1);
                    d_eyeshift = sqrt( (sacs_(2,5) - sacs_(1,5))*(sacs_(2,5) - sacs_(1,5)) + (sacs_(2,6) - sacs_(1,6))*(sacs_(2,6) - sacs_(1,6)) );
                end

                switch taskid
                    case 2  % visually guided saccade
                        %getFIRA_ec(tti, {'taskid'}) == 2;
                        t1_x = getFIRA_ec(tti, {'t1_x'});
                        t1_y = getFIRA_ec(tti, {'t1_y'});
                        delta = sqrt( (t1_x - sacs_(1,5))*(t1_x - sacs_(1,5)) + (t1_y - sacs_(1,6))*(t1_y - sacs_(1,6)) );
                        tarwin = sqrt(t1_x*t1_x + t1_y*t1_y)/1.5;
                        if delta<tarwin && t_eyeshift<=150 && d_eyeshift<=tarwin
                            setFIRA_ec(tti, {'choice'}, 1);
                            setFIRA_ec(tti, {'correct'}, 1);

                            % elseif
                            %     setFIRA_ec(tti, {'choice'}, -1);      %error
                            %     setFIRA_ec(tti, {'correct'}, 0);

                        else
                            setFIRA_ec(tti, {'choice'}, -1);      % fixbreak or other errors
                            setFIRA_ec(tti, {'correct'}, -2);
                        end
                    case 3  % countermanding
                        %getFIRA_ec(tti, {'taskid'}) == 3;
                        t1_x = getFIRA_ec(tti, {'t1_x'});
                        t1_y = getFIRA_ec(tti, {'t1_y'});
                        fp_x = getFIRA_ec(tti, {'fp_x'});
                        fp_y = getFIRA_ec(tti, {'fp_y'});
                        delta1 = sqrt( (t1_x - sacs_(1,5))*(t1_x - sacs_(1,5)) + (t1_y - sacs_(1,6))*(t1_y - sacs_(1,6)) );
                        delta2 = sqrt( (fp_x - sacs_(1,5))*(fp_x - sacs_(1,5)) + (fp_y - sacs_(1,6))*(fp_y - sacs_(1,6)) );
                        tarwin = sqrt(t1_x*t1_x + t1_y*t1_y)/1.5;
                        if delta1<tarwin && delta2>tarwin && t_eyeshift<=100 && d_eyeshift<=tarwin  %choice target 1
                            setFIRA_ec(tti, {'choice'}, 1);
                            setFIRA_ec(tti, {'correct'}, 0);
                        elseif delta1>tarwin && delta2<tarwin && t_eyeshift<=100 && d_eyeshift<=tarwin  %choice fixation point
                            setFIRA_ec(tti, {'choice'}, 0);
                            setFIRA_ec(tti, {'correct'}, 1);
                        elseif delta1>tarwin && delta2>tarwin   % no choice
                            setFIRA_ec(tti, {'choice'}, 0);
                            setFIRA_ec(tti, {'correct'}, -1);
                        else
                            setFIRA_ec(tti, {'choice'}, -1);    % fixbreak or other errors
                            setFIRA_ec(tti, {'correct'}, -2);
                        end
                end
            end
        end

        currentscore = getFIRA_ec(tti,{'correct'});
        if ~isnan(getFIRA_ec(tti, {'OLcorrect'}))
            OLscore = 1;
        elseif ~isnan(getFIRA_ec(tti, {'OLerror'}))
            OLscore = 0;
        elseif ~isnan(getFIRA_ec(tti, {'OLncerr'}))
            OLscore = -1;
        elseif ~isnan(getFIRA_ec(tti, {'OLbrfix'}))
            OLscore = -2;
        else
            OLscore = -3;   %will this ever happen?
        end
        setFIRA_ec(tti, {'OLscore'}, OLscore);
        if currentscore == OLscore
            setFIRA_ec(tti, {'scorematch'}, 1);
        else
            setFIRA_ec(tti, {'scorematch'}, 0);
        end

        %compute stop-signal delay
        fpofftime = getFIRA_ec(tti, {'fp_off'});
        cmdontime = getFIRA_ec(tti, {'cmdon'});
        if getFIRA_ec(tti, {'taskid'}) == 3
            stopsigdelay = cmdontime - fpofftime;
            setFIRA_ec(tti, {'stopsigdelay'}, stopsigdelay);
        end


        % %cleanup
    else


    end

catch
    evalin('base', 'e=lasterror')
end