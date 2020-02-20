function tr_ = trial(varargin)
% function tr_ = trial(varargin)
%
% Constructor method for class trial. Creates:
%   FIRA.spm.trial = trial_object
%   FIRA.raw.trial = trial_struct, described below
%
% Reads FIRA.spm.trial, which stores a cell array 
%   of <property>, <value> pairs
%
% this routine also makes sure that FIRA.spm.trial is listed
%   first, so that it is always called first
%
% Input:
%   varargin ... optional property value pairs
%                also looks in FIRA.spm.trial for
%                optional list of property/value pairs
%
% Output:
%   tr_ ... the trial object, to be stored in FIRA.spm.trial
%   Also creates FIRA.raw.trial

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

% fills FIRA
global FIRA

% declare global ecodes
declareEC_ecodes;

% make the trialParams struct
%%
%% NOTE FROM JIG AND SJ:
% added startcd_offset and endcd_offset to be able to pick ecodes
%   different from startcd to delimit beginning and end of trial
tr = struct( ...
    'startcd',  1005,                       ... % startcd, delimits trial
    'startcd_offset', 0,                    ... % offset to start code
    'endcd_offset', -1,                      ... % offset to end code
    'anycd',    [EC.CORRECTCD EC.WRONGCD EC.NOCHCD], ... % need to find ANY of these for a good trial
    'allcd',    [EC.FPONCD 4904],              ... % need to find ALL of these for a good trial
    'nocd',     [],                         ... % need to find NONE of these for a good trial
    'tminmax',  [-1000 inf],                ... % min/max times to save for spikes/analog
    'textra',   [],                         ... % extra time for spikes/analog data at the end of each trial
    'wrt',      EC.FPONCD,                     ... % timecode others are wrt
    'raw',      'true');                        % ignored

if isempty(FIRA)
    tr_ = class(tr, 'trial');
    return
end

% check FIRA.spm.analog, varargin for varargin
if isfield(FIRA.spm, 'trial') && iscell(FIRA.spm.trial)
    varargin = cat(2, FIRA.spm.trial, varargin);
end

% loop through the varargin
for i = 1:2:size(varargin, 2)
    tr.(varargin{i}) = varargin{i+1};
end

% always make FIRA.raw.trial, which will hold the trial data
FIRA.raw.trial = struct( ...
    'startcds',         [], ...     % array of start codes from FIRA.raw.ecodes
    'num_startcds',     0,  ...     % length of startcds - 1 (last is actually just an endcd)
    'startcd_index',    0,  ...     % to loop through startcds; see parse
    'total_count',      0,  ...     % total number of trials found
    'good_count',       0,  ...     % total number of good trials found
    'start_time',       [], ...     % begin time of this trial (time of STARTCD)
    'end_time',         [], ...     % time of last ecode of this trial
    'next_time',        [], ...     % begin time of next trial
    'wrt',              [], ...     % time
    'ecodes',           [], ...     % array of <time> <ecode> from this trial
    'tmp_ecodes',       []);        % array of values for FIRA.spm.tmp ecodes

% make and store object in FIRA.spm
tr_ = class(tr, 'trial');

% make sure "trial" is the first field of FIRA.spm
% and therefore always evaluated first (mostly for alloc)
fn = fieldnames(FIRA.spm);
if ~strcmp(fn{1}, 'trial')
    tdi      = strmatch('trial', fn, 'exact');
    fn{tdi}  = fn{1};
    fn{1}    = 'trial';
    FIRA.spm = orderfields(FIRA.spm, fn);
end
