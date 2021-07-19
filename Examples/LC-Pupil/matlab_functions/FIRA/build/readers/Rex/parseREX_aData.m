function parseREX_aData
% function parseREX_aData
%
% uses FIRA.raw.adata
%      FIRA.raw.aparams
%      FIRA.trial.index
%      FIRA.trial.start
%      FIRA.trial.wrt
%      FIRA.trial.end
%      FIRA.trial.ecodes
% to find the appropriate analog data for the given trial
%
% fills in the array of structures in FIRA.analog.data associated
%   with the current trial (FIRA.tria.index). These structures
%   have already been created with the following fields:
%       start_time
%       values
%
% adapted by jig 10/2/00 from ComposeAnalog4trial & ComposeRaster4trial
%
% from ComposeAnalog4trial:
%  newtrial_ = ComposeAnalog4trial(e0, header, Avect)
%  Given an efile snippet for the trial, the afile vector, the current
%  version of the trial cell array and the experiment's data header struct, this
%  routine returns an improved version of the trial array, with atim, the total
%  number of stored data points in all the records, and the signal data
%  itself, divided into channels as filtered through the store_order array. 
%
%  The older version of this routine called two subsidiary routines,
%  getAstrip and getAcont, whose functionality have been incorporated into
%  this routine.

%  updated again by jig, 1/25/02 -- biggest change is removing the
%     extremely inefficient nested loop to get the data, replacing it
%     with matrix indexing
%  updated by jig, 10/2/00
%  jpg - 4/14/98

global FIRA

% Find all the -112s in e0
Efound = find(FIRA.raw.trial.ecodes(:,2)==-112);
Afound = [Efound FIRA.raw.trial.ecodes(Efound,1)];

% didn't find any records
if ~size(Afound, 1)
    FIRA.analog.error{FIRA.raw.trial.good_count,1} = 'no records in trial';
    return
end

% skip to offset within Afile vector
aoff = (Afound(1,2)/2)+1;

% check the magic number
mtop = FIRA.raw.analog.data(aoff);
mbot = FIRA.raw.analog.data(aoff+1);

% If the conditions for the check look funny, it's because the two
% numbers, 18475 and -10319, are what you get when you take the original
% 32bit signed integer magic number, 1210832817, and chop it into two
% signed 16bit integers. If there was ever a need to rebuild this number,
% we'd use the same algorithm as the one used later to constitute ectim.
if mtop~=18475 & mbot ~=-10319
    % that's it, record shouldn't be read any further...
    FIRA.analog.error{FIRA.raw.trial.good_count,1} = 'first record has bad magic number';
    return
end

% calibrating time of ADATACD wrt FPONCD
ectop = FIRA.raw.analog.data(aoff+4);
ecbot = FIRA.raw.analog.data(aoff+5);
if ecbot<=0
    ecbot=ecbot+65536;
end
ectim=ecbot+(ectop*65536);
% save the beginning time, relative to wrt (of course)
[FIRA.analog.data(FIRA.raw.trial.good_count,:).start_time] = ...
    deal(ectim-FIRA.raw.trial.wrt);

% get the array of offsets
aoffs = Afound(:,2)/2+1;

% magic number checks for continuation records - if the magic number
% for a record is bad, the magflag gets flipped on & error message is saved
magflags = FIRA.raw.analog.data(aoffs)~=18475 & FIRA.raw.analog.data(aoffs+1)~=-10319;
if sum(magflags)
    FIRA.analog.error{FIRA.trial.index,1} = ...
        ['continuation record(s) ' find(magflags) ' are corrupt'];
    aoffs = aoffs(~magflags);
end

%% We used to store the "number of records" ... I honestly
%% don't remember why
recnums = FIRA.raw.analog.data(aoffs+9)/2;
% Acells_{1, wh_num} = sum(recnums);

% now it's time to acquire the data
acqd = [];
for i = 1:length(aoffs)
    acqd = [acqd;FIRA.raw.analog.data(aoffs(i)+10:aoffs(i)+recnums(i)+9)];
end

% now that we have the data, we trim it, beautify it, and collate
% it... trimming: does the data end on a frame boundary? if not, 
% remove the last few data points...		
lenso = length(FIRA.raw.analog.params.store_order);
if rem(length(acqd),lenso)~=0
        
    FIRA.analog.error{FIRA.raw.trial.good_count,1} = strvcat( ...
        FIRA.analog.error{FIRA.raw.trial.good_count,1}, ...
        'Record data did not end on frame boundary and was truncated');

    rdiff = rem(length(acqd),lenso)-1;
    len   = length(acqd);
    for rx = len:-1:(len-rdiff)
        acqd(rx)=[];
    end
end

% beautification: converting the data so it's in useful form		
acqd = (acqd-base2dec('4000',8))/40; % from mns

% now cycle through the channels, getting the appropriate data 
% from each channel
frames     = 0:lenso:length(acqd)-lenso;
num_frames = length(frames);
ind        = 1;
for ns = FIRA.raw.analog.params.keep_sigs
    these = find(FIRA.raw.analog.params.store_order==ns)'; % take data from these channels
    tt    = repmat(frames,length(these),1)+repmat(these,1,num_frames);
    FIRA.analog.data(FIRA.raw.trial.good_count, ind).values = acqd(tt(:));
    FIRA.analog.data(FIRA.raw.trial.good_count, ind).length = length(tt(:));
    ind   = ind + 1;
end
