function [data_, labels_] = later_getData(subjectTag, dataDirectory, expressCutoff)
% function [data_, labels_] = later_getData(subjectTag, dataDirectory, expressCutoff)
%
%   Each raw data file in data/data_mgl/F has the following vectors (in 
%    each case, columns are individual trials):
%     - decisionSum takes -1 if the decision was left side, and 1 if the 
%        decision was right side.
%     - labelSum takes 1 for trials after change point (TACP) 0, and 2 
%        for TACP 1, and 3 for TACP 2, and 4 for TACP 3, and 5 for TACP 4, 
%        and 0 for the rest. [NOTE FROM JIG: THIS IS HOW MY STUDENT TIM KIM
%        CODED THE DATA, SO I WANT TO KEEP IT IN THIS RAW FORMAT. HOWEVER, 
%        PLEASE NOTE THAT THIS CODING SCHEME SEEMS OVERLY CONFUSING; I
%        WOULD HAVE CODED IT AS 0 FOR TACP=0, 1 FOR TACP=1, ETC]
%     - numdirSum takes -1 if the sound was left side, and 1 if the sound 
%        was right side.
%     - percorrSum is 0 if the subject's answer was incorrect, and 1 
%        if the subject's answer was correct.
%     - syncSum is 1 if the current trial is a "pupil trial" and 0 if 
%        the current trial is "RT trial" [NOTE FROM JIG: IGNORED HERE]
%     - tRxnSum is RT measured by mglGetSecs, where the RT is defined 
%        as the time when the eyes leave the fixation window. 
%        The fixation window was defined as 30% of the height and width of 
%        the screen (32.31cm x 51.69cm).

% Use a particular subject tag
if nargin < 1 || isempty(subjectTag)
    subjectTag = 'JT';
end

% Data directory 
% MODIFY THIS TO FIND THE DATA ON YOUR MACHINE
if nargin < 2 || isempty(dataDirectory)
    dataDirectory = fullfile('~jigold', 'Library', 'CloudStorage', ...
        'Box-Box', 'QNC', 'LATERdata');
end

% Value (in sec) to define upper RT bound for express saccades
if nargin < 3 || isempty(expressCutoff)
    expressCutoff = 0.0;
end

% Load the data from that subject, given the base directory
load(fullfile(dataDirectory, 'data_mgl', 'F', [subjectTag '_RT.mat']));

% Define selection criteria ("L" for "logical array"):
%  1. Correct trials only (basic LATER model doesn't account for errors)
%  2. Remove outlier RTs (need to check with Tim Kim about the conditions
%        that gave rise to super-long RTs)
Ltrials = percorrSum == 1 & tRxnSum > expressCutoff(1) & tRxnSum < 1.2;

% Now loop through and get 4 data sets (see Fig. 2
%  in Kim et al):
%  C_L,0:  Left choices, change-point trials
%  C_L,1+: Left choices, non-change-point trials
%  C_R,0:  Right choices, change-point trials
%  C_R,1+: Right choices, non-change-point trials
data_ = { ...
    tRxnSum(Ltrials & numdirSum == -1 & labelSum == 1), ...
    tRxnSum(Ltrials & numdirSum == -1 & labelSum ~= 1), ...
    tRxnSum(Ltrials & numdirSum ==  1 & labelSum == 1), ...
    tRxnSum(Ltrials & numdirSum ==  1 & labelSum ~= 1)};
    
if nargout > 1
    labels_ = {'Left Choice, No CP', 'Left Choice, CP', 'Right Choice, No CP', 'Right Choice, CP'};
end