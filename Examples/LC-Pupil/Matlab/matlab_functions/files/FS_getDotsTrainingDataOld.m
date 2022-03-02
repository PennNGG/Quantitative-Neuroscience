function dat_ = FS_getDotsTrainingDataOld(monk)
%
% Collects data from Patrick & Jeff's data matrices.
%   If no monk given, creates and saves to disk
%   a cell array with data from each monkey. If monkey
%   given, finds the cell array and returns the monkey-
%   specific matrix, with columns:
%
%   1   Session (days since first session)
%   2   task (1=dots;2=novar dots;3=1 target;4=msac;5=osac;6=fix)
%   3   Cor (0=err;1=cor)
%   4   number of rewards
%   5   Dot Coh (0...1)
%   6   View time (sec)
%   7   Dot Dir (angle)
%   8   Dot Dir (-1=left;1=right;0=0%coh)
%   9   Choice  (-1=left;1=right)
%   10  Saccade latency (ms)
%   11  trial gap (ms since last trial)
%   12  time to attain fixation (ms)
%   13  number of bad trials since last good trial
%   14  voluntary saccade vavg
%   15  voluntary saccade vmax
%   16  voluntary saccade accuracy
%
%% Att, Ava
%
%   17  Stim flag (0=none; 1=ineffective; 2=effective)
%   18  Deviation (raw)
%   19  Deviation (z-score)
%   20  Deviation (not detrended)
%   21  raw end x
%   22  raw end y
%   23  rms end x
%   24  rms end y
%   25  stim lat
%   26  vol2 flag
%   27  stim curve
%   28  eye velocity during dots
%   29  eye velocity during dots in direction of motion
%

if nargin < 1
    monk = [];
end

% get lab dirname
% [home_dir, lab_dir] = dirnames;

% make full filename
%       fullfile(lab_dir, 'Data', 'Projects', 'DotsTrainingData');
dirname = '/Users/jigold/GoldWorks/Local/Data/Projects/DotsTrainingData';

% cell array of file names, etc
mC = { ...
    'Ava',     'av', 'AvaData', 'AvaNew',    @read_Patrick_data; ...
    'Atticus', 'at', 'AttData', 'AttNew',    @read_Patrick_data; ...
    'Cyrus',   'cy', 'CyData',  'CyNew',     @read_Jeff_data; ...
    'Zsa Zsa', 'zz', 'ZZData',  'ZZNew',     @read_Jeff_data; ...    
    'Samson',  'sa', 'Samson',  'SamsonNew', @read_UW_data; ...
    'Isaiah',  'is', 'Isaiah',  'IsaiahNew', @read_UW_data; ...
    };

% loop through the monks
for ii = 1:size(mC, 1)

    dataFile = fullfile(dirname, [mC{ii, 3} '.mat']);
    newFile  = fullfile(dirname, [mC{ii, 4} '.mat']);

    if isempty(monk) || (ischar(monk) && strcmp(monk, 'redo')) || ...
            (strncmpi(monk, mC{ii,1}, 2) && ...
            (~exist(newFile, 'file') || ...
            isempty(whos('-file', newFile))))
        % make data file
        disp(['Loading data from ' mC{ii, 1} '...'])
        dat_ = feval(mC{ii, 5}, dataFile);
        save(newFile, 'dat_');
        if ~isempty(monk)
            return
        end

    elseif strncmpi(monk, mC{ii, 2}, 2)
        % just get data from file
        load(newFile);
        return
    end
end

%%%
%
% LOAD DATA FROM PATRICK
%
%%%
%   1   Session
%   2   Cor
%   3   Dot Dir (angle)
%   4   Dot Coh (pct)
%   5   View time (sec)
%   6   Choice (-1=left;1=right)
%   7   Task    (2=fix; 3=1 target; 4=dots; 5=novar dots)
%   8   Stim flag
%   9   Deviation (raw)
%   10  Deviation (z-score)
%   11  raw end x
%   12  raw end y
%   13  rms end x
%   14  rms end y
%   15  vol lat
%   16  stim lat
%   17  vol2 flag
%   18  stim curve
%   19  num rewards
%   20  trial gap
%   21  fix time
%   22  vol v max
%   23  vol v avg
%   24  stim v max
%   25  stim v avg
%   26  t1 x
%   27  t1 y
%   28  t2 x
%   29  t2 y
%   30  vol end x
%   31  vol end y
%   32  all off to fp off
%   32  fp x
%   34  fp y
%   35  eye velocity during dots
%   36  eye velocity during dots in direction of motion

function dat_ = read_Patrick_data(file_in)

load(file_in);

% get good trials (only error/correct)
Lgood = data_(:,2) >= 0 & ~isnan(data_(:,6));
dat_  = data_(Lgood, [1 7 2 19 4 5 3 3 6 15 20 21 21 23 22 22 8 9 9 10 11:14 16:18 35:36]);

% re-set task type index
Lfix = dat_(:,2) == 2;
L1t  = dat_(:,2) == 3;
Ld   = dat_(:,2) == 4;
Ldnv = dat_(:,2) == 5;
dat_(Lfix,2) = 6;
dat_(L1t,2)  = 3;
dat_(Ld,2)   = 1;
dat_(Ldnv,2) = 2;

% max num rewards
dat_(dat_(:,4)>5,4) = 5;

% cohs are 0 ... 1, nan for task == 3
dat_(:,5) = dat_(:,5)./100;
dat_(dat_(:,2)==3,5) = nan;

% view time is in seconds
dat_(:,6) = dat_(:,6)./1000;

% For all 0% coherence trials, dir = nan, cor = 1,
% save dirs for below
dirs          = dat_(:, 7);
L0            = dat_(:,5) == 0;
dat_(L0, 3)   = 1;
dat_(L0, 7:8) = nan;

% make dir -1/1, 0 on 0% coh trials
dat_(:,8)  = sign(cos(dat_(:,8).*pi/180));
dat_(L0,8) = 0;

% Count the number of bad trials since last good trial
inds       = (1:size(data_,1))';
dat_(:,13) = [1; diff(inds(Lgood))];

% compute deviations on non de-trended data
dat_(:,20) = nan;
sessions   = nonanunique(dat_(:,1));
for ss = 1:length(sessions)
    Lses   = dat_(:,1) == sessions(ss) & isfinite(dat_(:,15));
    dat_(Lses, 20) = dot( ...
        [cos(dirs(Lses)*pi/180) sin(dirs(Lses)*pi/180)], ...
        [dat_(Lses,21)-nanmean(dat_(Lses,21)) dat_(Lses,22)-nanmean(dat_(Lses,22))], 2);
end
dat_(dat_(:,3)==0, 20) = -dat_(dat_(:,3)==0, 20);

% compute accuracy
ts          = data_(Lgood, [30 31 26:29]);
Lc          = dat_(:,3) == 1;
Le          = dat_(:,3) == 0;
dat_(Lc,16) = sqrt((ts(Lc,1)-ts(Lc,3)).^2 + (ts(Lc,2)-ts(Lc,4)).^2);
dat_(Le,16) = sqrt((ts(Le,1)-ts(Le,5)).^2 + (ts(Le,2)-ts(Le,6)).^2);

%%%
%
% LOAD DATA FROM JEFF
%
%%%
%%% The columns are as follow:

% 1   ... session
% 2   ... session (in "days since first session")
% 3   ... correct (-2=broken fix, -1=no choice, 0 = error, 1 = correct)
% 4   ... dot dir (angle, in degrees)
% 5   ... coherence (pct)
% 6   ... viewing time (ms)
% 7   ... saccade latency
% 8   ... saccade velocity (avg)
% 9   ... saccade velocity (max)
% 10  ... saccade accuracy (dist. from target)
% 11  ... trial begin time
% 12  ... time to attain fixation
% 13  ... # rewards (beeps)
function dat_ = read_Jeff_data(file_in)

load(file_in);
data_ = BigFIRA;
clear BigFIRA;

% get good trials (only error/correct)
Lgood = data_(:,3) >= 0;
dat_  = data_(Lgood, [1 1 3 13 5 6 4 4 4 7 11 12 12 8 9 10]);

% all are dots task
dat_(:, 2) = 1;

% max num rewards
dat_(dat_(:,4)>5,4) = 5;

% cohs are 0 ... 1
dat_(:,5) = dat_(:,5)./100;

% view time is in seconds
dat_(:,6) = dat_(:,6)./1000;

% make dir -1/1
dat_(:,8:9) = sign(cos(dat_(:,[8 8]).*pi./180));

% calculate choice
Lerr         = dat_(:,3) == 0;
dat_(Lerr,9) = -dat_(Lerr,9);

% For all 0% coherence trials, dir = nan, cor = 1
L0          = dat_(:,5) == 0;
dat_(L0, 3) = 1;
dat_(L0, 7) = nan;
dat_(L0, 8) = 0;

% Count the number of bad trials since last good trial
inds       = (1:size(data_,1))';
dat_(:,13) = [1; diff(inds(Lgood))];

%%%
%
% LOAD DATA FROM UW
%
%%%
%%% The columns are as follows:
%	1  ... ind
%	2  ... monk
%	3  ... task
%	4  ... targets on? (0=no, 1=yes)
%	5  ... correct
%	6  ... instruction (dots) duration
%	7  ... dot coherence
%	8  ... dot direction
%	9  ... voluntary saccade latency
%	10 ... voluntary saccade v_max
%	11 ... voluntary saccade v_average
%	12 ... stim_flag (0=no stim, 1=effective stim, 2=non-effective stim
%	13 ... stimulus-evoked saccade latency
%	14 ... stimulus-evoked saccade v_max
% 	15 ... stimulus-evoked saccade v_average
%	16 ... stimulus_evoked saccade deviation
%	17 ... stimulus_evoked saccade raw x
%	18 ... stimulus_evoked saccade raw y
%	19 ... stimulus_evoked saccade rms-subtracted x
%	20 ... stimulus_evoked saccade rms-subtracted y
%  21 ... pause between stim & vol saccade
function dat_ = read_UW_data(file_in)

load('/Users/jigold/GoldWorks/Mirror_lab/Data/Archive/UW/fefstim/pro/misc/pro_data.mat');
[p,n,e,v] = fileparts(file_in);
if strcmp(n, 'Isaiah')
    Lm = data_(:,2) == 1;
else
    Lm = data_(:,2) == 2;
end

% get good trials (only error/correct)
Lgood = Lm & data_(:,3) == 8 & data_(:,5) >= 0;
dat_  = data_(Lgood, [1 1 5 5 7 6 8 8 8 9 1 1 1 11 10 1 12 16 16 16 17 18 19 20 13 1 1 1 1]);

% all are dots task
dat_(:, 2) = 1;

% cohs are 0 ... 1
dat_(:,5) = dat_(:,5)./1000;

% view time is in seconds
dat_(:,6) = dat_(:,6)./1000;

% make dir -1/1
dat_(:,8:9) = sign(cos(dat_(:,[8 8]).*pi./180));

% calculate choice
Lerr = dat_(:,3) == 0;
dat_(Lerr,9) = -dat_(Lerr,9);

% For all 0% coherence trials, dir = nan, cor = 1
% save dirs for below
dirs        = dat_(:, 7);
L0          = dat_(:,5) == 0;
dat_(L0, 3) = 1;
dat_(L0, 7) = nan;
dat_(L0, 8) = 0;

% no trial gap, time to attain fixation, vol2 flag, stim curve
%   eye velocity during dots
dat_(:,[11 12 26 27 28 29]) = nan;

% Count the number of bad trials since last good trial
inds       = (1:size(data_,1))';
dat_(:,13) = [1; diff(inds(Lgood))];

% make stim flag consistent with Atticus/Ava
%    1 = stim given but not effective
%    2 = stim given and effective
Lstim                   = dat_(:,17) == 1;
dat_(dat_(:,17)==2, 17) = 1;
dat_(Lstim,         17) = 2;

% compute z-score deviations per session, deviations on non
%   de-trended data, accuracy
sessions    = nonanunique(dat_(:,1));
dat_(:,20)  = nan;
tdirs       = dirs;
tdirs(Lerr) = tdirs(Lerr) + 180;
txy         = 8.*[cos(tdirs*pi/180) sin(tdirs*pi/180)];
for ss = 1:length(sessions)
    Lses = dat_(:,1) == sessions(ss) & isfinite(dat_(:,18));
    dat_(Lses,19) = zscore(dat_(Lses,18));
    dat_(Lses,20) = dot( ...
        [cos(dirs(Lses)*pi/180) sin(dirs(Lses)*pi/180)], ...
        [dat_(Lses,21)-nanmean(dat_(Lses,21)) dat_(Lses,22)-nanmean(dat_(Lses,22))], 2);
    dat_(Lses,16) = sqrt(sum((txy(Lses,:)-dat_(Lses,21:22)).^2,2));
end
dat_(Lstim&dat_(:,3)==0,20) = -dat_(Lstim&dat_(:,3)==0,20);
