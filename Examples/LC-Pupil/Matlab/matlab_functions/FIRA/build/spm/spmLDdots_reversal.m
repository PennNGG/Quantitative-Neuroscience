function spmLDdots_reversal(func)
% function spmLDdots(func)
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
% LD 9-17-08 added returnsac, omitrew Omitrew only for data after 9/15/08
% LD 3-28-2016 modified from spmLDdots.m

% FOR DOTS REVERSAL TASK

global FIRA
declareEC_ecodes_LDdots_REVERSAL;

%% if called with empty FIRA.spm, fill it and return
if strcmp(func, 'init')
%     declareEC_ecodes_LDdots;
    declareEC_ecodes_LDdots_REVERSAL;

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
        'tgt_on'    'time'      @getEC_time         {EC.TARGONCD    1}; ...
        'tgt_off'   'time'      @getEC_time         {EC.TARGOFFCD   1}; ...
        'fp_off'    'time'      @getEC_time         {EC.FPOFFCD     1}; ...
        'targacq'    'time'     @getEC_time         {EC.TRGACQUIRECD    1}; ...
        'fdbkon'    'time'      @getEC_time         {EC.FDBKONCD    1}; ...
        'dot_on'    'time'      @getEC_time         {EC.GORANDCD    []}; ...
        'dot_off'   'time'      @getEC_time         {EC.ENDCD       1}; ...
        'sac_on'    'time'      @getEC_time         {EC.SACMAD      1}; ...
        'targoff'    'time'     @getEC_time         {EC.TARGOFFCD   1}; ...
%       LD, 10-11-2007, use DIO port 0 bit 2 signal instead
%        'rew_on'    'time'      @getEC_time         {EC.REWCD     1}; ...
%        'rew_off'   'time'      @getEC_time         {EC.REWOFFCD    1}; ...
%         'rew_on'     'time'     @getDIO_time        {0, 2, 1}; ...
%         'rew_off'    'time'     @getDIO_time        {0, 2, 2}; ...
        'OLcorrect' 'time'      @getEC_time         {EC.CORRECTCD    1}; ...
        'OLerror'   'time'      @getEC_time         {EC.WRONGCD    1}; ...
        'OLncerr'   'time'      @getEC_time         {EC.NOCHCD    1}; ...
        'OLbrfix'   'time'      @getEC_time         {EC.BRFIXCD    1}; ...
%         'estim_on'   'time'     @getEC_time         {EC.STIMCD    1}; ...
%         'estim_off'  'time'     @getEC_time         {EC.STOFFCD    1}; ...
%         'omitrew'   'time'      @getEC_time         {EC.OMITREWCD    1}; ...
%         'ar_cue'   'time'       @getEC_time         {EC.QONCD    1}; ...
        'fp_x'      'value'     @getEC_tagged       {EC.I_FIXXCD    cb    cm    cx  0.1};   ...
        'fp_y'      'value'     @getEC_tagged       {EC.I_FIXYCD    cb    cm    cx  0.1};   ...
        't1_x'      'value'     @getEC_tagged       {EC.I_TRG1XCD   cb    cm    cx  0.1};   ...
        't1_y'      'value'     @getEC_tagged       {EC.I_TRG1YCD   cb    cm    cx  0.1};   ...
        't2_x'      'value'     @getEC_tagged       {EC.I_TRG2XCD   cb    cm    cx  0.1};   ...
        't2_y'      'value'     @getEC_tagged       {EC.I_TRG2YCD   cb    cm    cx  0.1};   ...
        'taskid'    'id'        @getEC_tagged       {EC.I_TASKIDCD  cb    cm    cx  1};     ...
        'trialid'   'id'        @getEC_tagged       {EC.I_TRIALIDCD cb    cm    cx  1};     ...
        'dot_dir'   'id'        @getEC_tagged       {EC.I_DOTDIRCD  cb    cm    cx  1 Inf};     ...
        'dot_coh'   'id'        @getEC_tagged       {EC.I_COHCD     cb    cm    cx  0.1 Inf};   ...
        'dot_diam'  'id'        @getEC_tagged       {EC.I_STDIACD   cb    cm    cx  0.1}; ...
        'dot_sp'    'id'        @getEC_tagged       {EC.I_SPDCD     cb    cm    cx  0.1}; ...
        'dot_x'     'id'        @getEC_tagged       {EC.I_STXCD  cb    cm    cx  0.1}; ...
        'dot_y'     'id'        @getEC_tagged       {EC.I_STYCD  cb    cm    cx  0.1}; ...
%         'rewcont'   'id'        @getEC_tagged       {EC.I_REWCONTCD cb    cm    cx  1};     ...
%         'seed_base' 'value'     @getEC_tagged       {EC.I_DTVARCD   cb    cm    cx  1};     ...
%         'estim_type' 'value'    @getEC_tagged       {EC.I_ESTIMCD   cb    cm    cx  1};     ...
        }, ...
        'compute', { ...                % names/types of fields to compute & save later in FIRA{2}
        'rew_on'        'time'; ...     % LD added 10-11-2007, get reward times via dio
        'rew_off'       'time'; ...
        'reward'        'value' ; ...   % reward size
        'choice'        'id'; ...       % which target was chosen,  right-up = 1; left-down = 2; only meaningful for dots task
        'correct'       'id'; ...       % offline score: 1=correct, 0=error, -1=nc, -2=brfix
        'OLscore'       'value'; ...    % online score: 1=correct, 0=error, -1=nc, -2=brfix
        'scorematch'    'value' ; ...
        'fix_time'      'value' ; ...   % time to attain fixation from beginning of trial (first fp_on)
        'sac_endx'      'value' ; ...
        'sac_endy'      'value' ; ...
        'sac_lat'       'value' ; ...
        'sac_dur'       'value' ; ...
        'sac_vmax'      'value' ; ...
        'sac_amp'       'value' ; ...
        'sac_on_offline'       'value' ; ...
        'returnsac'       'value' ; ...
        't1_angle'       'id' ; ...     % correct target direction
        }, ...
        'tmp', { ...  % values to extract & use temporarily: <name> <type> <method> <args>
        }}}, ...
        'spikes',  [], ...
        'analog',  [], ...
        'dio',     []);

    return

    % parse the trial ... check whether anything is given in FIRA.trial
elseif strcmp(func, 'trial')

    % get this trial index
    tti = FIRA.raw.trial.good_count;
    taskid = getFIRA_ec(tti, {'taskid'});
  
    % compute the saccade-related values as defined in init and determine
    % the rest

    sfixoff = 'fp_off';
    
    sacs_ = []; bf_ = [];
    if ~isempty(sfixoff)
        [sacs_, bf_] = getFIRA_saccadesLD(tti, 1, false , 'horiz_eye',  'vert_eye', sfixoff, 'fp_x', 'fp_y', 5000); 
%         [sacs_, bf_] = getFIRA_saccadesLD_SACMAD(tti, 2, false , 'horiz_eye',  'vert_eye', 'sac_on', 'fp_x', 'fp_y', 5000); 
%         d_saconset = getFIRA_ec(tti, {'sac_on'}) - getFIRA_ec(tti, {sfixoff}) - 200;
%         if ~isempty(sacs_)
%             sacs_(:,1) = sacs_(:,1) + d_saconset;
%         end
        t_eyeshift = 0; d_eyeshift = 0;
        t1_x = getFIRA_ec(tti, {'t1_x'});
        t1_y = getFIRA_ec(tti, {'t1_y'});
        t1_angle = mod(atan2(t1_y, t1_x)*180/pi+ 360,360);
        setFIRA_ec(tti, {'t1_angle'}, t1_angle);
        if bf_
            setFIRA_ec(tti, {'choice'}, -1);    %fixbreak or other errors
            setFIRA_ec(tti, {'correct'}, -2);
        elseif isempty(sacs_)
            setFIRA_ec(tti, {'choice'}, -1);    %fixbreak or other errors
            setFIRA_ec(tti, {'correct'}, -1);
        else
            [nSacs,m] = size(sacs_);
            if nSacs>1 && ~isinf( sacs_(2,1) ) && ~isnan( sacs_(2,1) )
                t_eyeshift = sacs_(2,1) - sacs_(1,1);
                d_eyeshift = sqrt( (sacs_(2,5) - sacs_(1,5))*(sacs_(2,5) - sacs_(1,5)) + (sacs_(2,6) - sacs_(1,6))*(sacs_(2,6) - sacs_(1,6)) );
            end
            switch taskid
                case 1  % memory & visual
                    delta = sqrt( (t1_x - sacs_(1,5))*(t1_x - sacs_(1,5)) + (t1_y - sacs_(1,6))*(t1_y - sacs_(1,6)) );
                    tarwin = sqrt(t1_x*t1_x + t1_y*t1_y)/1.2;
                    if delta<tarwin && ~isnan(sacs_(1,1)) && (t_eyeshift>150 || d_eyeshift<=tarwin)
                        setFIRA_ec(tti, {'choice'}, 1);
                        setFIRA_ec(tti, {'correct'}, 1);
                    else
                        setFIRA_ec(tti, {'choice'}, 0);
                        setFIRA_ec(tti, {'correct'}, 0);
                    end
               case {3,4,5,6}  % dots reversal
                    t2_x = getFIRA_ec(tti, {'t2_x'});
                    t2_y = getFIRA_ec(tti, {'t2_y'});
                    delta1 = sqrt( (t1_x - sacs_(1,5))*(t1_x - sacs_(1,5)) + (t1_y - sacs_(1,6))*(t1_y - sacs_(1,6)) );
                    delta2 = sqrt( (t2_x - sacs_(1,5))*(t2_x - sacs_(1,5)) + (t2_y - sacs_(1,6))*(t2_y - sacs_(1,6)) );
                    tarwin = sqrt(t1_x*t1_x + t1_y*t1_y)/1.2;
                    if delta1<tarwin && delta2>tarwin && ~isnan(sacs_(1,1)) && ((d_eyeshift<=tarwin)|(t_eyeshift>200))  %choice target 1
                        setFIRA_ec(tti, {'choice'}, 1);
                        if ~isnan(getFIRA_ec(tti, {'OLerror'}))
                            setFIRA_ec(tti, {'correct'}, 0);
                        elseif ~isnan(getFIRA_ec(tti, {'OLcorrect'}))
                            setFIRA_ec(tti, {'correct'}, 1);
                        end
                    elseif delta1>tarwin && delta2<tarwin && ~isnan(sacs_(1,1)) && ((d_eyeshift<=tarwin)|(t_eyeshift>200))  %choice target 2
                        setFIRA_ec(tti, {'choice'}, 2);
                        if ~isnan(getFIRA_ec(tti, {'OLerror'}))
                            setFIRA_ec(tti, {'correct'}, 0);
                        elseif ~isnan(getFIRA_ec(tti, {'OLcorrect'}))
                            setFIRA_ec(tti, {'correct'}, 1);
                        end
                    elseif delta1>tarwin && delta2>tarwin   %no choice
                        setFIRA_ec(tti, {'choice'}, 0);
                        setFIRA_ec(tti, {'correct'}, -1);
                    else
                        setFIRA_ec(tti, {'choice'}, -1);    %fixbreak or other errors
                        setFIRA_ec(tti, {'correct'}, -2);
                    end    
                    
            end
            setFIRA_ec(tti, {'fix_time'}, getFIRA_ec(tti, {'eyefix'}) - getFIRA_ec(tti, {'fp_on'}));
            setFIRA_ec(tti, {'sac_lat'}, sacs_(1,1));
            setFIRA_ec(tti, {'sac_dur'}, sacs_(1,2));
            setFIRA_ec(tti, {'sac_vmax'}, sacs_(1,3));
            setFIRA_ec(tti, {'sac_endx'}, sacs_(1,5));
            setFIRA_ec(tti, {'sac_endy'}, sacs_(1,6));
            setFIRA_ec(tti, {'sac_amp'}, sacs_(1,7));
            setFIRA_ec(tti, {'sac_on_offline'}, getFIRA_ec(tti, sfixoff)+ sacs_(1,1));
        end    
        currentscore = getFIRA_ec(tti,{'correct'});
        if ~isnan(getFIRA_ec(tti, {'OLcorrect'}))
            OLscore = 1;
            if isfield(FIRA, 'dio')
                rewon = getDIO_time(FIRA.dio{tti}, 0, 2, 1);
                rewoff = getDIO_time(FIRA.dio{tti}, 0, 2, 2);
                rewsize = rewoff - rewon;
                setFIRA_ec(tti, {'rew_on'}, rewon);
                setFIRA_ec(tti, {'rew_off'}, rewoff);
                setFIRA_ec(tti, {'reward'}, rewsize);
            end
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

    end
    % cleanup
else

end
