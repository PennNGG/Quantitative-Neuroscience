function addTrial(d, data)
% function addTrial(d, data)
%
% addTrial method for class distrData
%
% Input:
%   d    ... the distrData object
%   data  ... cell array of data from gamepad
%
% Output:
%   squat and a half, but fills FIRA.distrData(trial) with given data

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% check that there are trials
if size(FIRA.distrData, 1) < FIRA.header.numTrials
    FIRA.distrData(end+1:FIRA.header.numTrials,1) = {[]};
end

% data is cell array, just save it
FIRA.distrData{end,1} = data;