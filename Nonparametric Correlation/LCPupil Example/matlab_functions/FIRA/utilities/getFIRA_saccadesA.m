function [sacs_, choice_] = getFIRA_saccadesA(trial, eyeXY, epoch, ...
    num_saccades, min_time, targetsXY, max_distance, show_fig)
%function [sacs_, choice_] = getFIRA_saccadesA(trial, eyeXY, epoch, ...
%    num_saccades, min_time, targetsXY, max_distance, show_fig)
%
% Find saccades, compare to target locations
%
% Arguments:
%   trial        ... trial number
%   eyeXY        ... {<name of analog channel X>, <Y>}
%   epoch        ... {<begin code> <offset>; <end code> <offset>}
%   num_saccades ... number to find
%   min_time     ... minimum latency for saccade (otherwise brfix)
%   targetsXY    ... {<t1 X ecode> <t1 Y ecode>; <t2 ...}
%   max_distance ... fix window size for target
%
% Returns:
%   sacs_  ... list of saccade parameters computed by parseSaccades
%               ([] if no saccade found)
%   score_ ... -2 brfix; -1 nc; 0 no sac; 1...n index of targetsXY nearest
%               to eye position at last sac

% 7/20/07 jig wrote from getFIRA_saccades
%       removed calibration stuff (moved to analog class)
%
% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

sacs_   = [];
choice_ = nan;

% check for analog data
if ~isfield(FIRA, 'analog')
    return
end

% parse args
if nargin < 2 || isempty(eyeXY)
    eyeXY = {'horiz_eye', 'vert_eye'};
end

if nargin < 3 || isempty(epoch)
    epoch = {'fp_off' 0; 'fp_off' 800};
end

if nargin < 4 || isempty(num_saccades)
    num_saccades = 1;
elseif num_saccades <= 0
    return
end

if nargin < 5 || isempty(min_time)
    min_time = 80;
end

if nargin < 6
    targetsXY = {};
end

if nargin < 7 || isempty(max_distance)
    max_distance = 4; % deg vis ang
end

% get indices of horizontal, vertical eye position data
eyeX = strcmp(eyeXY{1}, FIRA.analog.name);
eyeY = strcmp(eyeXY{2}, FIRA.analog.name);

% check that we have appropriate analog data
if ~any(eyeX) || isempty(FIRA.analog.data(trial, eyeX).values) || ...
        ~any(eyeY) || isempty(FIRA.analog.data(trial, eyeY).values)
    return
end

% check that store rate is the same for both channels
sr = FIRA.analog.store_rate(eyeX);
if sr ~= FIRA.analog.store_rate(eyeY)
    disp('getFIRA_saccades: bad store rates')
    return
end

% get the sample number in the analog data array corresponding
% to the begin, end times
len = FIRA.analog.data(trial, eyeX).length;
if isempty(epoch)
    sample_begin = 1;
    sample_end   = len;
else
    bval = FIRA.ecodes.data(trial, strcmp(epoch{1,1}, FIRA.ecodes.name));
    if size(epoch, 2) == 2 && isfinite(epoch{1,2})
        boff = epoch{1,2};
    else
        boff = 0;
    end
    sample_begin = ceil((bval+boff-FIRA.analog.data(trial,1).start_time)*sr/1000);
    if sample_begin < 1
        sample_begin = 1;
    end
    if sample_begin > len
        return
    end
    
    if size(epoch,1) == 1
        sample_end = FIRA.analog.data(trial, eyeX).length;
    else
        nval = FIRA.ecodes.data(trial, strcmp(epoch{2,1}, FIRA.ecodes.name));
        if size(epoch, 2) == 2 && isfinite(epoch{2,2})
            noff = epoch{2,2};
        else
            noff = 0;
        end
        sample_end = ceil((nval+noff-FIRA.analog.data(trial,1).start_time)*sr/1000);
        if sample_end < 1
            return
        end
        if sample_end > FIRA.analog.data(trial, eyeX).length
            sample_end = FIRA.analog.data(trial, eyeX).length;
        end
    end
end

if ~isfinite(sample_begin) || ~isfinite(sample_end) || sample_begin >= sample_end
    return
end

% get saccade parameters from analog/findSaccades
sacs_ = findSaccades(FIRA.spm.analog, ...
    FIRA.analog.data(trial, eyeX).values(sample_begin:sample_end), ...
    FIRA.analog.data(trial, eyeY).values(sample_begin:sample_end), ...
    sr, num_saccades, false);

% check for saccades
if size(sacs_,1) == 1
    choice_ = 0;
    return
end

% check min time
if isfinite(min_time) && sacs_(1, 1) < min_time
    choice_ = -2;
    return
end

% check targets
sx    = sacs_(end-1, 5);
sy    = sacs_(end-1, 6);
ds    = nans(size(targetsXY, 1));
for tt = 1:size(targetsXY, 1)
    tx = FIRA.ecodes.data(trial, strcmp(targetsXY{tt,1}, FIRA.ecodes.name));
    ty = FIRA.ecodes.data(trial, strcmp(targetsXY{tt,2}, FIRA.ecodes.name));
    ds(tt) = sqrt((tx-sx).^2 + (ty-sy).^2);
end
if ~any(ds<max_distance)
    choice_ = -1;
else
    choice_ = find(ds==min(ds),1);
end
